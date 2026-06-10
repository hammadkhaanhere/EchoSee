import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eecho_see/core/constants.dart';
import 'package:eecho_see/data/services/asr/asr_result.dart';
import 'package:eecho_see/data/services/asr/asr_service.dart';
import 'package:eecho_see/data/services/audio_capture_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

class SherpaOfflineAsrService implements AsrService {
  SherpaOfflineAsrService(this._audioCapture);

  final AudioCaptureService _audioCapture;
  OnlineRecognizer? _recognizer;
  OnlineStream? _stream;
  StreamSubscription<Uint8List>? _audioSubscription;
  void Function(AsrResult result)? _onResult;
  void Function(Uint8List pcm)? _onAudioChunk;
  String _modelsRoot = '';
  bool _initialized = false;
  String _lastText = '';

  @override
  String get modeLabel => 'Sherpa-ONNX Offline';

  @override
  bool get isAvailable => _initialized;

  bool _modelsExist(String root) {
    final files = [
      AppConstants.offlineAsrEncoder,
      AppConstants.offlineAsrDecoder,
      AppConstants.offlineAsrJoiner,
      AppConstants.offlineAsrTokens,
    ];
    return files.every((f) => File('$root/$f').existsSync());
  }

  @override
  Future<bool> initialize({
    required String languageCode,
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      onError?.call('Microphone permission is required.');
      return false;
    }

    if (_modelsRoot.isEmpty || !_modelsExist(_modelsRoot)) {
      onError?.call(
        'Sherpa-ONNX ASR models not found. Download models to: $_modelsRoot',
      );
      return false;
    }

    try {
      initBindings();
      final model = OnlineModelConfig(
        transducer: OnlineTransducerModelConfig(
          encoder: '$_modelsRoot/${AppConstants.offlineAsrEncoder}',
          decoder: '$_modelsRoot/${AppConstants.offlineAsrDecoder}',
          joiner: '$_modelsRoot/${AppConstants.offlineAsrJoiner}',
        ),
        tokens: '$_modelsRoot/${AppConstants.offlineAsrTokens}',
        modelType: 'zipformer2',
      );

      _recognizer?.free();
      _recognizer = OnlineRecognizer(OnlineRecognizerConfig(model: model));
      _initialized = true;
      onStatus?.call('ready');
      return true;
    } catch (error) {
      onError?.call('Failed to load Sherpa-ONNX ASR models: $error');
      _initialized = false;
      return false;
    }
  }

  void setModelsRoot(String path) {
    _modelsRoot = path;
    _initialized = false;
  }

  @override
  Future<void> startListening({
    required void Function(AsrResult result) onResult,
    void Function(Uint8List pcm)? onAudioChunk,
  }) async {
    _onAudioChunk = onAudioChunk;
    if (_recognizer == null) {
      throw StateError('Sherpa offline ASR is not initialized.');
    }

    _onResult = onResult;
    _stream?.free();
    _stream = _recognizer!.createStream();
    _lastText = '';

    final audioStream = await _audioCapture.startStream();
    if (audioStream == null) {
      throw StateError('Unable to start microphone capture.');
    }

    _audioSubscription = audioStream.listen(_processAudioChunk);
  }

  void _processAudioChunk(Uint8List pcmBytes) {
    _onAudioChunk?.call(pcmBytes);
    if (_recognizer == null || _stream == null || _onResult == null) {
      return;
    }

    final samples = _pcm16ToFloat32(pcmBytes);
    _stream!.acceptWaveform(
      samples: samples,
      sampleRate: AppConstants.sampleRateHz,
    );

    while (_recognizer!.isReady(_stream!)) {
      _recognizer!.decode(_stream!);
    }

    final text = _recognizer!.getResult(_stream!).text.trim();
    if (text.isEmpty || text == _lastText) {
      return;
    }

    final isFinal = text.endsWith('.') || text.endsWith('?') || text.endsWith('!');
    _lastText = text;
    _onResult!(
      AsrResult(
        text: text,
        isFinal: isFinal,
        timestamp: DateTime.now(),
      ),
    );
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final sampleCount = bytes.length ~/ 2;
    final samples = Float32List(sampleCount);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < sampleCount; i++) {
      samples[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return samples;
  }

  @override
  Future<void> stopListening() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _audioCapture.stop();
    _stream?.free();
    _stream = null;
    _lastText = '';
  }

  @override
  Future<void> dispose() async {
    await stopListening();
    _recognizer?.free();
    _recognizer = null;
    _initialized = false;
  }
}
