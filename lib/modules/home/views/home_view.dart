import 'package:eecho_see/app/routes/app_routes.dart';
import 'package:eecho_see/data/models/language_model.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/modules/home/controllers/home_controller.dart';
import 'package:eecho_see/widgets/microphone%20button.dart';
import 'package:eecho_see/widgets/status_indicator.dart';
import 'package:eecho_see/widgets/subtitle_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _showLanguagePicker(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Translation Language',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: LanguageModel.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = LanguageModel.supportedLanguages[index];
                    return Obx(() {
                      final isSelected = settingsService
                              .settings.value.translationLanguageCode ==
                          lang.code;
                      return ListTile(
                        leading: Text(
                          lang.code.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        title: Text(lang.nativeName),
                        subtitle: Text(lang.name),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          controller.setTranslationLanguage(lang.code);
                          Get.back();
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSee'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: controller.clearHistory,
            tooltip: 'Clear History',
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => _showLanguagePicker(context),
            tooltip: 'Translation Language',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 680 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Obx(
                        () => StatusIndicator(
                          status: controller.statusMessage.value,
                          isListening: controller.isListening.value,
                          isInitializing: controller.isInitializing.value,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SubtitlePanel(
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => MicrophoneButton(
                          isListening: controller.isListening.value,
                          isInitializing: controller.isInitializing.value,
                          onPressed: controller.toggleListening,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
