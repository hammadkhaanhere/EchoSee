import 'package:eecho_see/core/app_settings.dart';
import 'package:eecho_see/data/models/language_model.dart';
import 'package:eecho_see/data/services/asr/asr_coordinator.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._settingsService,
    this._asrCoordinator,
    this._speakerService,
  );

  final SettingsService _settingsService;
  final AsrCoordinator _asrCoordinator;
  final SpeakerIdentificationService _speakerService;

  AppSettings get settings => _settingsService.settings.value;

  Future<void> setSpeechLanguage(String code) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(speechLanguageCode: code),
    );
  }

  Future<void> setTranslationLanguage(String code) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(translationLanguageCode: code),
    );
  }

  Future<void> setAsrMode(AsrMode mode) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(asrMode: mode),
    );
    _asrCoordinator.refreshConfiguration();
  }

  Future<void> setOfflinePreferred(bool value) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(offlineModePreferred: value),
    );
  }

  Future<void> setSpeakerIdentification(bool value) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(speakerIdentificationEnabled: value),
    );
  }

  Future<void> setSubtitleSize(double size) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(subtitleFontSize: size),
    );
  }

  Future<void> setAudioQuality(AudioQuality quality) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(audioQuality: quality),
    );
  }

  Future<void> setGoogleCredentialsPath(String path) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(googleServiceAccountPath: path),
    );
    _asrCoordinator.refreshConfiguration();
  }

  Future<void> setSherpaModelsPath(String path) async {
    await _settingsService.updatePartial(
      (current) => current.copyWith(sherpaModelsPath: path),
    );
    _asrCoordinator.refreshConfiguration();
    _speakerService.refreshModelsRoot();
  }

  List<LanguageModel> get translationLanguages =>
      LanguageModel.supportedLanguages;

  bool get isSherpaSpeakerReady => _speakerService.isReady;
}
