import 'package:eecho_see/core/app_settings.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/modules/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        final settings = settingsService.settings.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle(context, 'Speech Recognition'),
            DropdownMenu<String>(
              label: const Text('Speech language'),
              initialSelection: settings.speechLanguageCode,
              dropdownMenuEntries: AppSettings.speechLanguages.entries
                  .map(
                    (e) => DropdownMenuEntry(value: e.key, label: e.value),
                  )
                  .toList(),
              onSelected: (value) {
                if (value != null) controller.setSpeechLanguage(value);
              },
            ),
            const SizedBox(height: 12),
            DropdownMenu<AsrMode>(
              label: const Text('ASR mode'),
              initialSelection: settings.asrMode,
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: AsrMode.auto,
                  label: 'Auto (online/offline fallback)',
                ),
                DropdownMenuEntry(
                  value: AsrMode.onlineGoogle,
                  label: 'Google Cloud STT',
                ),
                DropdownMenuEntry(
                  value: AsrMode.onlineDevice,
                  label: 'Device speech recognition',
                ),
                DropdownMenuEntry(
                  value: AsrMode.offlineSherpa,
                  label: 'Sherpa-ONNX offline',
                ),
              ],
              onSelected: (value) {
                if (value != null) controller.setAsrMode(value);
              },
            ),
            SwitchListTile(
              title: const Text('Prefer offline mode'),
              subtitle: const Text('Use local models when available'),
              value: settings.offlineModePreferred,
              onChanged: controller.setOfflinePreferred,
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, 'Translation'),
            DropdownMenu<String>(
              label: const Text('Translation language'),
              initialSelection: settings.translationLanguageCode,
              dropdownMenuEntries: controller.translationLanguages
                  .map(
                    (lang) => DropdownMenuEntry(
                      value: lang.code,
                      label: '${lang.name} (${lang.nativeName})',
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value != null) controller.setTranslationLanguage(value);
              },
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, 'Speaker Identification'),
            SwitchListTile(
              title: const Text('Speaker identification'),
              subtitle: Text(
                controller.isSherpaSpeakerReady
                    ? 'Sherpa-ONNX models loaded'
                    : 'Models not found — using session labels',
              ),
              value: settings.speakerIdentificationEnabled,
              onChanged: controller.setSpeakerIdentification,
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, 'Display'),
            ListTile(
              title: const Text('Subtitle size'),
              subtitle: Slider(
                value: settings.subtitleFontSize,
                min: 14,
                max: 36,
                divisions: 11,
                label: settings.subtitleFontSize.round().toString(),
                onChanged: controller.setSubtitleSize,
              ),
            ),
            DropdownMenu<AudioQuality>(
              label: const Text('Audio quality'),
              initialSelection: settings.audioQuality,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: AudioQuality.low, label: 'Low'),
                DropdownMenuEntry(
                  value: AudioQuality.standard,
                  label: 'Standard',
                ),
                DropdownMenuEntry(value: AudioQuality.high, label: 'High'),
              ],
              onSelected: (value) {
                if (value != null) controller.setAudioQuality(value);
              },
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, 'Advanced'),
            ListTile(
              title: const Text('Google service account JSON path'),
              subtitle: Text(
                settings.googleServiceAccountPath.isEmpty
                    ? 'Not configured'
                    : settings.googleServiceAccountPath,
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _editPathDialog(
                context,
                title: 'Google credentials path',
                initial: settings.googleServiceAccountPath,
                onSave: controller.setGoogleCredentialsPath,
              ),
            ),
            ListTile(
              title: const Text('Sherpa-ONNX models directory'),
              subtitle: Text(
                settings.sherpaModelsPath.isEmpty
                    ? 'Default: app documents/models'
                    : settings.sherpaModelsPath,
              ),
              trailing: const Icon(Icons.folder),
              onTap: () => _editPathDialog(
                context,
                title: 'Sherpa models path',
                initial: settings.sherpaModelsPath,
                onSave: controller.setSherpaModelsPath,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _editPathDialog(
    BuildContext context, {
    required String title,
    required String initial,
    required Future<void> Function(String) onSave,
  }) async {
    final textController = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Absolute file or directory path',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await onSave(textController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
