import 'package:eecho_see/data/services/asr/asr_coordinator.dart';
import 'package:eecho_see/data/services/asr/device_asr_service.dart';
import 'package:eecho_see/data/services/asr/google_cloud_asr_service.dart';
import 'package:eecho_see/data/services/asr/sherpa_offline_asr_service.dart';
import 'package:eecho_see/data/services/audio_capture_service.dart';
import 'package:eecho_see/data/services/connectivity_service.dart';
import 'package:eecho_see/data/services/model_asset_service.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:eecho_see/data/services/translation_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  static Future<void> initServices() async {
    await Get.putAsync<SettingsService>(() async => SettingsService().init());
    await Get.putAsync<ConnectivityService>(
      () async => ConnectivityService().init(),
    );

    Get.put(AudioCaptureService());
    Get.put(DeviceAsrService());
    Get.put(GoogleCloudAsrService(Get.find<AudioCaptureService>()));
    Get.put(SherpaOfflineAsrService(Get.find<AudioCaptureService>()));
    Get.put(TranslationService());
    Get.put(ModelAssetService());

    await Get.putAsync<SpeakerIdentificationService>(
      () async => SpeakerIdentificationService(
        settingsService: Get.find<SettingsService>(),
      ).init(),
    );

    await Get.putAsync<AsrCoordinator>(
      () async => AsrCoordinator(
        settingsService: Get.find<SettingsService>(),
        connectivityService: Get.find<ConnectivityService>(),
        deviceAsr: Get.find<DeviceAsrService>(),
        googleAsr: Get.find<GoogleCloudAsrService>(),
        sherpaAsr: Get.find<SherpaOfflineAsrService>(),
        speakerService: Get.find<SpeakerIdentificationService>(),
        modelAssetService: Get.find<ModelAssetService>(),
      ).init(),
    );
  }

  @override
  void dependencies() {}
}
