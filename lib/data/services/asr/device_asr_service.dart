import 'dart:typed_data';

import 'package:eecho_see/data/services/asr/asr_result.dart';
import 'package:eecho_see/data/services/asr/asr_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DeviceAsrService implements AsrService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  void Function(String status)? _statusListener;
  void Function(String message)? _errorListener;
  String _languageCode = 'en-US';

  @override
  String get modeLabel => 'Device ASR';

  @override
  bool get isAvailable => _isInitialized;

  @override
  Future<bool> initialize({
    required String languageCode,
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    _languageCode = languageCode;
    _statusListener = onStatus;
    _errorListener = onError;

    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      final message = permissionStatus.isPermanentlyDenied
          ? 'Microphone permission is permanently denied. Enable it from app settings.'
          : 'Microphone permission is required to recognize speech.';
      onError?.call(message);
      return false;
    }

    if (_isInitialized) {
      return true;
    }

    final isAvailable = await _speechToText.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
      debugLogging: false,
      options: [SpeechToText.androidNoBluetooth, SpeechToText.iosNoBluetooth],
    );

    _isInitialized = isAvailable;
    if (!isAvailable) {
      onError?.call('Speech recognition is not available on this device.');
    }
    return isAvailable;
  }

  @override
  Future<void> startListening({
    required void Function(AsrResult result) onResult,
    void Function(Uint8List pcm)? onAudioChunk,
  }) async {
    if (!_isInitialized) {
      throw StateError('Device ASR must be initialized before listening.');
    }

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(
          AsrResult(
            text: result.recognizedWords.trim(),
            isFinal: result.finalResult,
            confidence: result.confidence,
            timestamp: DateTime.now(),
          ),
        );
      },
      listenOptions: SpeechListenOptions(
        localeId: _languageCode,
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
        enableHapticFeedback: false,
      ),
    );
  }

  @override
  Future<void> stopListening() => _speechToText.stop();

  @override
  Future<void> dispose() async {
    await _speechToText.cancel();
    _isInitialized = false;
  }

  void _handleStatus(String status) => _statusListener?.call(status);

  void _handleError(SpeechRecognitionError error) {
    final message = error.errorMsg.isNotEmpty
        ? error.errorMsg
        : 'Speech recognition stopped unexpectedly.';
    _errorListener?.call(message);
  }
}
