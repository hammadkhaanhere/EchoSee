import 'package:translator/translator.dart';

class TranslationService {
  TranslationService();

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _cache = {};

  Future<String> translate(
    String text, {
    required String to,
    String from = 'auto',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final cacheKey = '$from:$to:$trimmed';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final translation = await _translator.translate(
      trimmed,
      from: from,
      to: to,
    );
    _cache[cacheKey] = translation.text;
    return translation.text;
  }

  void clearCache() => _cache.clear();
}
