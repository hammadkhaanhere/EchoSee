import 'dart:async';

import 'package:eecho_see/data/models/language_model.dart';
import 'package:eecho_see/data/services/speech_service.dart';
import 'package:eecho_see/services/translation_service.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';


class HomeController extends GetxController {
  HomeController(this._speechService);

  final SpeechService _speechService;
  final TranslationService _translationService = TranslationService();

  final recognizedText = 'Press the microphone and start speaking.'.obs;
  final translatedText = ''.obs;
  final isListening = false.obs;
  final isInitializing = false.obs;
  final statusMessage = 'Ready'.obs;
  final errorMessage = RxnString();

  final selectedLanguage = LanguageModel.supportedLanguages[0].obs;
  final Map<String, String> _translationCache = {};
  Timer? _debounceTimer;

  void setLanguage(LanguageModel language) {
    if (selectedLanguage.value.code == language.code) return;
    selectedLanguage.value = language;
    if (recognizedText.value.isNotEmpty &&
        recognizedText.value != 'Press the microphone and start speaking.') {
      _translateText(recognizedText.value);
    }
  }

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
      final result = await _speechService.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );

      if (!result.isAvailable) {
        errorMessage.value = result.message;
        statusMessage.value = 'Unavailable';
        return;
      }

      await _speechService.startListening(onResult: _handleSpeechResult);
      isListening.value = true;
      statusMessage.value = 'Listening';
    } catch (error) {
      errorMessage.value = 'Unable to start speech recognition. $error';
      statusMessage.value = 'Error';
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    isListening.value = false;
    statusMessage.value = 'Stopped';
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isNotEmpty && words != recognizedText.value) {
      recognizedText.value = words;
      _translateText(words);
    }
  }

  Future<void> _translateText(String text) async {
    final langCode = selectedLanguage.value.code;
    final cacheKey = '$langCode:$text';

    if (_translationCache.containsKey(cacheKey)) {
      translatedText.value = _translationCache[cacheKey]!;
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final translation = await _translationService.translate(text, to: langCode);
        _translationCache[cacheKey] = translation;
        translatedText.value = translation;
      } catch (e) {
        // Fallback to recognized text if translation fails
        translatedText.value = text;
      }
    });
  }

  void _handleSpeechStatus(String status) {
    if (status == 'listening') {
      isListening.value = true;
      statusMessage.value = 'Listening';
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
    _speechService.cancelListening();
    super.onClose();
  }
}
