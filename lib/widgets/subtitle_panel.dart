import 'package:eecho_see/data/models/language_model.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubtitlePanel extends GetView<HomeController> {
  const SubtitlePanel({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  LanguageModel _languageForCode(String code) {
    return LanguageModel.supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => LanguageModel.supportedLanguages.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Obx(() {
          final translationLang = _languageForCode(
            settingsService.settings.value.translationLanguageCode,
          );
          final subtitleSize =
              settingsService.settings.value.subtitleFontSize;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...controller.transcriptHistory.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${item.speakerLabel}]',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        item.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (item.translation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Directionality(
                            textDirection: translationLang.isRTL
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Text(
                              item.translation,
                              style: TextStyle(
                                fontSize: subtitleSize - 4,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (controller.transcriptHistory.isNotEmpty)
                const Divider(height: 32),
              Text(
                controller.recognizedText.value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (controller.translatedText.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${translationLang.name.toUpperCase()} SUBTITLES',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Directionality(
                    textDirection: translationLang.isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Text(
                      controller.translatedText.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              if (controller.errorMessage.value != null) ...[
                const SizedBox(height: 20),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
