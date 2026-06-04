import 'package:translator/translator.dart';
import 'speech_service.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();
  final SpeechService _speechService = SpeechService();

  Future<String> translate(String text, {String to = 'en'}) async {
    if (text.isEmpty) return '';
    var translation = await _translator.translate(text, to: to);
    return translation.text;
  }

  Future<void> startListening(
      Function(String, bool) onResult,
      ) async {
    bool available = await _speechService.initialize();

    if (available) {
      _speechService.startListening(onResult);
    }
  }
  void stopListening() {
    _speechService.stopListening();
  }
}
