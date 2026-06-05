class LanguageModel {
  final String name;
  final String nativeName;
  final String code;
  final bool isRTL;

  const LanguageModel({
    required this.name,
    required this.nativeName,
    required this.code,
    this.isRTL = false,
  });

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(name: 'English', nativeName: 'English', code: 'en'),
    LanguageModel(name: 'Urdu', nativeName: 'اردو', code: 'ur', isRTL: true),
    LanguageModel(name: 'Arabic', nativeName: 'العربية', code: 'ar', isRTL: true),
    LanguageModel(name: 'French', nativeName: 'Français', code: 'fr'),
    LanguageModel(name: 'Spanish', nativeName: 'Español', code: 'es'),
    LanguageModel(name: 'Chinese', nativeName: '中文', code: 'zh-cn'),
  ];
}
