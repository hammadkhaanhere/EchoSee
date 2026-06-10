import 'package:eecho_see/data/services/asr/asr_coordinator.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:eecho_see/modules/settings/controllers/settings_controller.dart';
import 'package:get/get.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<SettingsService>(),
        Get.find<AsrCoordinator>(),
        Get.find<SpeakerIdentificationService>(),
      ),
    );
  }
}
