import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eecho_see/core/constants.dart';
import 'package:eecho_see/data/services/asr/asr_result.dart';
import 'package:eecho_see/data/services/asr/asr_service.dart';
import 'package:eecho_see/data/services/audio_capture_service.dart';
import 'package:google_speech/endless_streaming_service.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart'
    hide RecognitionConfig, StreamingRecognitionConfig;
import 'package:google_speech/google_speech.dart';

class GoogleCloudAsrService implements AsrService {
  GoogleCloudAsrService(this._audioCapture);

  final AudioCaptureService _audioCapture;
  EndlessStreamingService? _speechToText;
  StreamSubscription<StreamingRecognizeResponse>? _responseSubscription;
  StreamSubscription<Uint8List>? _audioSubscription;
  void Function(AsrResult result)? _onResult;
  void Function(Uint8List pcm)? _onAudioChunk;
  String _languageCode = 'en-US';
  bool _configured = false;

  @override
  String get modeLabel => 'Google Cloud STT';

  @override
  bool get isAvailable => _configured;

  void configure(String serviceAccountPath) {
    if (serviceAccountPath.isEmpty || !File(serviceAccountPath).existsSync()) {
      _configured = false;
      _speechToText = null;
      return;
    }

    final serviceAccount = ServiceAccount.fromFile(File(serviceAccountPath));
    _speechToText = EndlessStreamingService.viaServiceAccount(serviceAccount);
    _configured = true;
  }

  @override
  Future<bool> initialize({
    required String languageCode,
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    _languageCode = languageCode;
    if (!_configured || _speechToText == null) {
      onError?.call(
        'Google Cloud credentials not configured. Add a service account JSON in Settings.',
      );
      return false;
    }

    onStatus?.call('ready');
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(AsrResult result) onResult,
    void Function(Uint8List pcm)? onAudioChunk,
  }) async {
    _onAudioChunk = onAudioChunk;
    if (_speechToText == null) {
      throw StateError('Google Cloud ASR is not configured.');
    }

    _onResult = onResult;
    final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      sampleRateHertz: AppConstants.sampleRateHz,
      languageCode: _languageCode,
      enableAutomaticPunctuation: true,
      model: RecognitionModel.latest_long,
    );

    final streamingConfig = StreamingRecognitionConfig(
      config: config,
      interimResults: true,
      singleUtterance: false,
    );

    final audioStream = await _audioCapture.startStream();
    if (audioStream == null) {
      throw StateError('Unable to start microphone capture.');
    }

    _responseSubscription = _speechToText!.endlessStream.listen(_handleResponse);
    _speechToText!.endlessStreamingRecognize(streamingConfig, audioStream);
    _audioSubscription = audioStream.listen((chunk) {
      _onAudioChunk?.call(chunk);
    });
  }

  void _handleResponse(StreamingRecognizeResponse response) {
    if (response.results.isEmpty || _onResult == null) {
      return;
    }

    final result = response.results.first;
    if (result.alternatives.isEmpty) {
      return;
    }

    final alternative = result.alternatives.first;
    final text = alternative.transcript.trim();
    if (text.isEmpty) {
      return;
    }

    _onResult!(
      AsrResult(
        text: text,
        isFinal: result.isFinal,
        confidence: alternative.confidence,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    await _audioSubscription?.cancel();
    await _responseSubscription?.cancel();
    _audioSubscription = null;
    _responseSubscription = null;
    await _audioCapture.stop();
  }

  @override
  Future<void> dispose() async {
    await stopListening();
    _speechToText = null;
    _configured = false;
  }
}
