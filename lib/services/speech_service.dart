import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText speech = SpeechToText();

  Future<bool> initialize() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) return false;
    }
    return await speech.initialize();
  }

  void startListening(Function(String, bool) onResult) {
    speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
    );
  }

  void stopListening() {
    speech.stop();
  }
}
