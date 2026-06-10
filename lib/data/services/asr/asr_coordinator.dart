import 'dart:async';
import 'dart:typed_data';

import 'package:eecho_see/core/app_settings.dart';
import 'package:eecho_see/data/services/asr/asr_result.dart';
import 'package:eecho_see/data/services/asr/asr_service.dart';
import 'package:eecho_see/data/services/asr/device_asr_service.dart';
import 'package:eecho_see/data/services/asr/google_cloud_asr_service.dart';
import 'package:eecho_see/data/services/asr/sherpa_offline_asr_service.dart';
import 'package:eecho_see/data/services/connectivity_service.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:get/get.dart';
import 'package:eecho_see/data/services/model_asset_service.dart';

class AsrCoordinator extends GetxService {
  AsrCoordinator({
    required SettingsService settingsService,
    required ConnectivityService connectivityService,
    required DeviceAsrService deviceAsr,
    required GoogleCloudAsrService googleAsr,
    required SherpaOfflineAsrService sherpaAsr,
    required SpeakerIdentificationService speakerService,
    required ModelAssetService modelAssetService,
  })  : _settings = settingsService,
        _connectivity = connectivityService,
        _deviceAsr = deviceAsr,
        _googleAsr = googleAsr,
        _sherpaAsr = sherpaAsr,
        _speakerService = speakerService,
        _modelAssetService = modelAssetService;

  final SettingsService _settings;
  final ConnectivityService _connectivity;
  final DeviceAsrService _deviceAsr;
  final GoogleCloudAsrService _googleAsr;
  final SherpaOfflineAsrService _sherpaAsr;
  final SpeakerIdentificationService _speakerService;
  final ModelAssetService _modelAssetService;

  AsrService? _activeService;
  final RxString activeModeLabel = 'None'.obs;

  Future<AsrCoordinator> init() async {
    final bundledRoot = await _modelAssetService.ensureModelsOnDisk();
    final customPath = _settings.settings.value.sherpaModelsPath;
    final modelsRoot = customPath.isNotEmpty &&
            _modelAssetService.modelsExistOnDisk(customPath)
        ? customPath
        : bundledRoot;
    _sherpaAsr.setModelsRoot(modelsRoot);
    _googleAsr.configure(_settings.settings.value.googleServiceAccountPath);
    return this;
  }

  void refreshConfiguration() {
    final settings = _settings.settings.value;
    _googleAsr.configure(settings.googleServiceAccountPath);
    if (settings.sherpaModelsPath.isNotEmpty) {
      _sherpaAsr.setModelsRoot(settings.sherpaModelsPath);
    }
  }

  Future<AsrService?> _resolveService() async {
    final settings = _settings.settings.value;
    final online = _connectivity.isOnline.value;

    switch (settings.asrMode) {
      case AsrMode.onlineGoogle:
        if (_googleAsr.isAvailable || settings.googleServiceAccountPath.isNotEmpty) {
          return _googleAsr;
        }
        return _deviceAsr;
      case AsrMode.onlineDevice:
        return _deviceAsr;
      case AsrMode.offlineSherpa:
        return _sherpaAsr;
      case AsrMode.auto:
        if (!online || settings.offlineModePreferred) {
          return _sherpaAsr;
        }
        if (settings.googleServiceAccountPath.isNotEmpty) {
          return _googleAsr;
        }
        return _deviceAsr;
    }
  }

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    refreshConfiguration();
    final languageCode = _settings.settings.value.speechLanguageCode;
    final candidates = <AsrService>[];

    final primary = await _resolveService();
    if (primary != null) {
      candidates.add(primary);
    }

    for (final service in [_googleAsr, _deviceAsr, _sherpaAsr]) {
      if (!candidates.contains(service)) {
        candidates.add(service);
      }
    }

    for (final service in candidates) {
      final ok = await service.initialize(
        languageCode: languageCode,
        onStatus: onStatus,
        onError: onError,
      );
      if (ok) {
        _activeService = service;
        activeModeLabel.value = service.modeLabel;
        return true;
      }
    }

    onError?.call('No speech recognition backend is available.');
    return false;
  }

  Future<void> startListening({
    required void Function(AsrResult result) onResult,
  }) async {
    if (_activeService == null) {
      throw StateError('ASR coordinator is not initialized.');
    }
    void Function(Uint8List pcm)? onAudioChunk;
    if (_settings.settings.value.speakerIdentificationEnabled &&
        _speakerService.isReady) {
      onAudioChunk = (pcm) {
        unawaited(_speakerService.identifyFromPcm(pcm));
      };
    }

    await _activeService!.startListening(
      onResult: onResult,
      onAudioChunk: onAudioChunk,
    );
  }

  Future<void> stopListening() => _activeService?.stopListening() ?? Future.value();

  Future<void> dispose() async {
    await _deviceAsr.dispose();
    await _googleAsr.dispose();
    await _sherpaAsr.dispose();
  }
}
