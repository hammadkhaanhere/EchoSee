import 'package:eecho_see/data/services/asr/asr_coordinator.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:eecho_see/data/services/speaker_identification_service.dart';
import 'package:eecho_see/data/services/translation_service.dart';
import 'package:eecho_see/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        asrCoordinator: Get.find<AsrCoordinator>(),
        translationService: Get.find<TranslationService>(),
        settingsService: Get.find<SettingsService>(),
        speakerService: Get.find<SpeakerIdentificationService>(),
      ),
    );
  }
}
