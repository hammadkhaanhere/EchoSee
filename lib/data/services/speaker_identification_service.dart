import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:eecho_see/core/constants.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

class SpeakerCluster {
  SpeakerCluster({
    required this.id,
    required this.label,
    required this.centroid,
  });

  final int id;
  final String label;
  Float32List centroid;
  int segmentCount = 1;
}

class SpeakerIdentificationService extends GetxService {
  SpeakerIdentificationService({
    required SettingsService settingsService,
  }) : _settings = settingsService;

  final SettingsService _settings;

  SpeakerEmbeddingExtractor? _extractor;
  SpeakerEmbeddingManager? _enrolledManager;
  VoiceActivityDetector? _vad;

  final List<SpeakerCluster> _clusters = [];
  int _nextClusterId = 1;
  String _modelsRoot = '';
  bool _ready = false;

  final RxString currentSpeakerLabel = 'Speaker 1'.obs;

  Future<SpeakerIdentificationService> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _modelsRoot = _settings.settings.value.sherpaModelsPath.isNotEmpty
        ? _settings.settings.value.sherpaModelsPath
        : '${docs.path}/models';
    await _tryInitialize();
    return this;
  }

  void refreshModelsRoot() {
    final path = _settings.settings.value.sherpaModelsPath;
    if (path.isNotEmpty) {
      _modelsRoot = path;
    }
    _disposeNative();
    _ready = false;
    _tryInitialize();
  }

  bool get isReady => _ready;

  Future<void> _tryInitialize() async {
    final embeddingPath = '$_modelsRoot/${AppConstants.speakerEmbeddingModel}';
    final vadPath = '$_modelsRoot/${AppConstants.vadModel}';

    if (!File(embeddingPath).existsSync()) {
      return;
    }

    try {
      initBindings();
      _extractor = SpeakerEmbeddingExtractor(
        config: SpeakerEmbeddingExtractorConfig(
          model: embeddingPath,
          numThreads: 2,
          debug: false,
        ),
      );
      _enrolledManager = SpeakerEmbeddingManager(_extractor!.dim);

      if (File(vadPath).existsSync()) {
        _vad = VoiceActivityDetector(
          config: VadModelConfig(
            sileroVad: SileroVadModelConfig(
              model: vadPath,
              minSilenceDuration: 0.25,
              minSpeechDuration: 0.5,
            ),
            numThreads: 1,
            debug: false,
          ),
          bufferSizeInSeconds: 30,
        );
      }

      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Process a PCM16 mono chunk and update the active speaker label.
  Future<String> identifyFromPcm(Uint8List pcmBytes) async {
    if (!_ready ||
        !_settings.settings.value.speakerIdentificationEnabled ||
        _extractor == null) {
      return currentSpeakerLabel.value;
    }

    final samples = _pcm16ToFloat32(pcmBytes);
    if (samples.isEmpty) {
      return currentSpeakerLabel.value;
    }

    if (_vad != null) {
      _vad!.acceptWaveform(samples);
      if (_vad!.isEmpty()) {
        return currentSpeakerLabel.value;
      }
    }

    final stream = _extractor!.createStream();
    stream.acceptWaveform(
      samples: samples,
      sampleRate: AppConstants.sampleRateHz,
    );

    while (_extractor!.isReady(stream)) {}

    final embedding = _extractor!.compute(stream);
    stream.free();

    if (embedding.isEmpty) {
      return currentSpeakerLabel.value;
    }

    final enrolled = _enrolledManager?.search(
      embedding: embedding,
      threshold: AppConstants.speakerSimilarityThreshold,
    );
    if (enrolled != null && enrolled.isNotEmpty) {
      currentSpeakerLabel.value = enrolled;
      return enrolled;
    }

    final label = _assignClusterLabel(embedding);
    currentSpeakerLabel.value = label;
    return label;
  }

  String _assignClusterLabel(Float32List embedding) {
    SpeakerCluster? best;
    var bestScore = -1.0;

    for (final cluster in _clusters) {
      final score = _cosineSimilarity(embedding, cluster.centroid);
      if (score > bestScore) {
        bestScore = score;
        best = cluster;
      }
    }

    if (best != null && bestScore >= AppConstants.speakerSimilarityThreshold) {
      _updateCentroid(best, embedding);
      return best.label;
    }

    final cluster = SpeakerCluster(
      id: _nextClusterId,
      label: 'Speaker $_nextClusterId',
      centroid: Float32List.fromList(embedding),
    );
    _nextClusterId += 1;
    _clusters.add(cluster);
    return cluster.label;
  }

  void _updateCentroid(SpeakerCluster cluster, Float32List embedding) {
    final n = cluster.segmentCount;
    for (var i = 0; i < cluster.centroid.length; i++) {
      cluster.centroid[i] =
          (cluster.centroid[i] * n + embedding[i]) / (n + 1);
    }
    cluster.segmentCount += 1;
  }

  double _cosineSimilarity(Float32List a, Float32List b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) {
      return 0;
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  bool enrollSpeaker(String name, Uint8List pcmBytes) {
    if (!_ready || _extractor == null || _enrolledManager == null) {
      return false;
    }

    final samples = _pcm16ToFloat32(pcmBytes);
    final stream = _extractor!.createStream();
    stream.acceptWaveform(
      samples: samples,
      sampleRate: AppConstants.sampleRateHz,
    );
    while (_extractor!.isReady(stream)) {}
    final embedding = _extractor!.compute(stream);
    stream.free();

    if (embedding.isEmpty) {
      return false;
    }

    return _enrolledManager!.add(name: name, embedding: embedding);
  }

  void resetSession() {
    _clusters.clear();
    _nextClusterId = 1;
    currentSpeakerLabel.value = 'Speaker 1';
    _vad?.clear();
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

  void _disposeNative() {
    _vad?.free();
    _vad = null;
    _enrolledManager?.free();
    _enrolledManager = null;
    _extractor?.free();
    _extractor = null;
  }

  @override
  void onClose() {
    _disposeNative();
    super.onClose();
  }
}
