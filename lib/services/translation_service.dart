import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate(String text, {String to = 'en'}) async {
    if (text.isEmpty) return '';
    try {
      var translation = await _translator.translate(text, to: to);
      return translation.text;
    } catch (e) {
      rethrow;
    }
  }
}
