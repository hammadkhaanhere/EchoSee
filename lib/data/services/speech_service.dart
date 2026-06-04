import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechInitializationResult {
  const SpeechInitializationResult({required this.isAvailable, this.message});

  final bool isAvailable;
  final String? message;
}

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  bool _isInitialized = false;
  void Function(String status)? _statusListener;
  void Function(String message)? _errorListener;

  bool get isListening => _speechToText.isListening;

  Future<SpeechInitializationResult> initialize({
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    _statusListener = onStatus;
    _errorListener = onError;

    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      final message = permissionStatus.isPermanentlyDenied
          ? 'Microphone permission is permanently denied. Enable it from app settings.'
          : 'Microphone permission is required to recognize speech.';
      return SpeechInitializationResult(isAvailable: false, message: message);
    }

    if (_isInitialized) {
      return const SpeechInitializationResult(isAvailable: true);
    }

    final isAvailable = await _speechToText.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
      debugLogging: false,
      options: [SpeechToText.androidNoBluetooth, SpeechToText.iosNoBluetooth],
    );

    _isInitialized = isAvailable;
    return SpeechInitializationResult(
      isAvailable: isAvailable,
      message: isAvailable
          ? null
          : 'Speech recognition is not available on this device.',
    );
  }

  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
  }) async {
    if (!_isInitialized) {
      throw StateError('Speech service must be initialized before listening.');
    }

    await _speechToText.listen(
      onResult: onResult,
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(seconds: 4),
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() => _speechToText.stop();

  Future<void> cancelListening() => _speechToText.cancel();

  void _handleStatus(String status) {
    _statusListener?.call(status);
  }

  void _handleError(SpeechRecognitionError error) {
    final message = error.errorMsg.isNotEmpty
        ? error.errorMsg
        : 'Speech recognition stopped unexpectedly.';
    _errorListener?.call(message);
  }
}
