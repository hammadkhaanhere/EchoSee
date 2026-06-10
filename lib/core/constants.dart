/// Audio and model configuration constants.
abstract final class AppConstants {
  static const int sampleRateHz = 16000;
  static const int audioChannels = 1;
  static const int translationDebounceMs = 300;
  static const double speakerSimilarityThreshold = 0.65;

  /// Bundled in `assets/models/` — streaming Zipformer EN+ZH (chunk-8-left-64).
  static const String offlineAsrEncoder =
      'encoder-epoch-13-avg-2-chunk-8-left-64.int8.onnx';
  static const String offlineAsrDecoder =
      'decoder-epoch-13-avg-2-chunk-8-left-64.onnx';
  static const String offlineAsrJoiner =
      'joiner-epoch-13-avg-2-chunk-8-left-64.int8.onnx';
  static const String offlineAsrTokens = 'tokens.txt';

  /// Not bundled yet — download from sherpa-onnx releases for speaker ID.
  static const String speakerEmbeddingModel =
      'speaker/3dspeaker_speech_eres2net_base_sv_zh-cn_3dspeaker_16k.onnx';
  static const String vadModel = 'vad/silero_vad.onnx';

  static const String modelsDownloadUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases';
}
