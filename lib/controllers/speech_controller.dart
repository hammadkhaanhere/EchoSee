import 'package:get/get.dart';
import '../services/speech_service.dart';
import '../services/translation_service.dart';

class SpeechController extends GetxController {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();

  var recognizedText = 'Press the button and start speaking'.obs;
  var translatedText = ''.obs;
  var isListening = false.obs;

  void toggleListening() async {
    if (isListening.value) {
      _speechService.stopListening();
      isListening.value = false;
    } else {
      bool available = await _speechService.initialize();
      if (available) {
        isListening.value = true;
        _speechService.startListening((text, isFinal) async {
          recognizedText.value = text;
          if (text.isNotEmpty) {
            var translation = await _translationService.translate(text, to: 'en');
            translatedText.value = translation;
          }
          if (isFinal) {
           }
        });
      } else {
        Get.snackbar('Error', 'Speech recognition not available');
      }
    }
  }
}
