import 'dart:async';

import 'package:eecho_see/data/models/transcript_item.dart';
import 'package:eecho_see/data/services/asr/asr_coordinator.dart';
import 'package:eecho_see/data/services/asr/asr_result.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:eecho_see/data/services/translation_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController({
    required AsrCoordinator asrCoordinator,
    required TranslationService translationService,
    required SettingsService settingsService,
    required SpeakerIdentificationService speakerService,
  })  : _asrCoordinator = asrCoordinator,
        _translationService = translationService,
        _settingsService = settingsService,
        _speakerService = speakerService;

  final AsrCoordinator _asrCoordinator;
  final TranslationService _translationService;
  final SettingsService _settingsService;
  final SpeakerIdentificationService _speakerService;

  final recognizedText = 'Press the microphone and start speaking.'.obs;
  final translatedText = ''.obs;
  final isListening = false.obs;
  final isInitializing = false.obs;
  final statusMessage = 'Ready'.obs;
  final errorMessage = RxnString();
  final transcriptHistory = <TranscriptItem>[].obs;

  Timer? _debounceTimer;

  String get currentSpeakerLabel => _speakerService.currentSpeakerLabel.value;

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
      return;
    }
    await startListening();
  }

  Future<void> startListening() async {
    if (isInitializing.value || isListening.value) {
      return;
    }

    isInitializing.value = true;
    errorMessage.value = null;
    statusMessage.value = 'Preparing microphone...';

    try {
      final ok = await _asrCoordinator.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );

      if (!ok) {
        statusMessage.value = 'Unavailable';
        return;
      }

      await _asrCoordinator.startListening(onResult: _handleSpeechResult);
      isListening.value = true;
      statusMessage.value = 'Listening · ${_asrCoordinator.activeModeLabel.value}';
    } catch (error) {
      errorMessage.value = 'Unable to start speech recognition. $error';
      statusMessage.value = 'Error';
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> stopListening() async {
    await _asrCoordinator.stopListening();
    isListening.value = false;
    statusMessage.value = 'Stopped';
  }

  void _handleSpeechResult(AsrResult result) {
    final words = result.text.trim();
    if (words.isEmpty) {
      return;
    }

    final speaker = currentSpeakerLabel;
    recognizedText.value = '[$speaker]\n$words';
    _translateText(words);

    if (result.isFinal) {
      _addToHistory(words, translatedText.value, speaker);
      recognizedText.value = 'Press the microphone and start speaking.';
      translatedText.value = '';
    }
  }

  void _addToHistory(String text, String translation, String speaker) {
    if (transcriptHistory.isNotEmpty &&
        transcriptHistory.last.text == text &&
        transcriptHistory.last.speakerLabel == speaker) {
      return;
    }

    transcriptHistory.add(
      TranscriptItem(
        text: text,
        translation: translation,
        speakerLabel: speaker,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _translateText(String text) async {
    final langCode = _settingsService.settings.value.translationLanguageCode;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () async {
        try {
          final translation = await _translationService.translate(
            text,
            to: langCode,
          );
          translatedText.value = translation;
        } catch (_) {
          translatedText.value = text;
        }
      },
    );
  }

  void setTranslationLanguage(String code) {
    _settingsService.updatePartial(
      (current) => current.copyWith(translationLanguageCode: code),
    );
    if (recognizedText.value.isNotEmpty &&
        recognizedText.value != 'Press the microphone and start speaking.') {
      final lines = recognizedText.value.split('\n');
      if (lines.length > 1) {
        _translateText(lines.sublist(1).join('\n'));
      }
    }
  }

  void clearHistory() {
    transcriptHistory.clear();
    _speakerService.resetSession();
  }

  void _handleSpeechStatus(String status) {
    if (status == 'listening' || status == 'ready') {
      isListening.value = status == 'listening';
      if (status == 'listening') {
        statusMessage.value = 'Listening · ${_asrCoordinator.activeModeLabel.value}';
      }
      return;
    }

    if (status == 'notListening' || status == 'done') {
      isListening.value = false;
      statusMessage.value = 'Stopped';
    }
  }

  void _handleSpeechError(String message) {
    errorMessage.value = message;
    isListening.value = false;
    statusMessage.value = 'Error';
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _asrCoordinator.stopListening();
    super.onClose();
  }
}
