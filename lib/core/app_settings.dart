enum AsrMode { auto, onlineGoogle, onlineDevice, offlineSherpa }

enum AudioQuality { low, standard, high }

class AppSettings {
  const AppSettings({
    this.speechLanguageCode = 'en-US',
    this.translationLanguageCode = 'ar',
    this.asrMode = AsrMode.auto,
    this.offlineModePreferred = false,
    this.speakerIdentificationEnabled = true,
    this.subtitleFontSize = 22,
    this.audioQuality = AudioQuality.standard,
    this.googleServiceAccountPath = '',
    this.sherpaModelsPath = '',
  });

  final String speechLanguageCode;
  final String translationLanguageCode;
  final AsrMode asrMode;
  final bool offlineModePreferred;
  final bool speakerIdentificationEnabled;
  final double subtitleFontSize;
  final AudioQuality audioQuality;
  final String googleServiceAccountPath;
  final String sherpaModelsPath;

  static const speechLanguages = <String, String>{
    'en-US': 'English',
    'ur-PK': 'Urdu',
  };

  AppSettings copyWith({
    String? speechLanguageCode,
    String? translationLanguageCode,
    AsrMode? asrMode,
    bool? offlineModePreferred,
    bool? speakerIdentificationEnabled,
    double? subtitleFontSize,
    AudioQuality? audioQuality,
    String? googleServiceAccountPath,
    String? sherpaModelsPath,
  }) {
    return AppSettings(
      speechLanguageCode: speechLanguageCode ?? this.speechLanguageCode,
      translationLanguageCode:
          translationLanguageCode ?? this.translationLanguageCode,
      asrMode: asrMode ?? this.asrMode,
      offlineModePreferred: offlineModePreferred ?? this.offlineModePreferred,
      speakerIdentificationEnabled:
          speakerIdentificationEnabled ?? this.speakerIdentificationEnabled,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      audioQuality: audioQuality ?? this.audioQuality,
      googleServiceAccountPath:
          googleServiceAccountPath ?? this.googleServiceAccountPath,
      sherpaModelsPath: sherpaModelsPath ?? this.sherpaModelsPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'speechLanguageCode': speechLanguageCode,
        'translationLanguageCode': translationLanguageCode,
        'asrMode': asrMode.index,
        'offlineModePreferred': offlineModePreferred,
        'speakerIdentificationEnabled': speakerIdentificationEnabled,
        'subtitleFontSize': subtitleFontSize,
        'audioQuality': audioQuality.index,
        'googleServiceAccountPath': googleServiceAccountPath,
        'sherpaModelsPath': sherpaModelsPath,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      speechLanguageCode: json['speechLanguageCode'] as String? ?? 'en-US',
      translationLanguageCode:
          json['translationLanguageCode'] as String? ?? 'ar',
      asrMode: AsrMode.values[json['asrMode'] as int? ?? 0],
      offlineModePreferred: json['offlineModePreferred'] as bool? ?? false,
      speakerIdentificationEnabled:
          json['speakerIdentificationEnabled'] as bool? ?? true,
      subtitleFontSize:
          (json['subtitleFontSize'] as num?)?.toDouble() ?? 22,
      audioQuality:
          AudioQuality.values[json['audioQuality'] as int? ?? 1],
      googleServiceAccountPath:
          json['googleServiceAccountPath'] as String? ?? '',
      sherpaModelsPath: json['sherpaModelsPath'] as String? ?? '',
    );
  }
}
