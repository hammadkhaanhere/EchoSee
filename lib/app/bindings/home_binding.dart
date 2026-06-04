import 'package:get/get.dart';

import '../../data/services/speech_service.dart';
import '../../modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeechService>(SpeechService.new);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<SpeechService>()),
    );
  }
}
