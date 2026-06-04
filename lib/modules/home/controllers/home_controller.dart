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

  void _handleSpeechResult(SpeechRecognitionResult result) async {
    final words = result.recognizedWords.trim();
    if (words.isNotEmpty) {
      recognizedText.value = words;
      
      // Live Translation for Subtitles
      final translation = await _translationService.translate(words, to: 'en');
      translatedText.value = translation;
    }
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
