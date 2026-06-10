import 'dart:typed_data';

import 'package:eecho_see/data/services/asr/asr_result.dart';

abstract class AsrService {
  Future<bool> initialize({
    required String languageCode,
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  });

  Future<void> startListening({
    required void Function(AsrResult result) onResult,
    void Function(Uint8List pcm)? onAudioChunk,
  });

  Future<void> stopListening();

  Future<void> dispose();

  bool get isAvailable;
  String get modeLabel;
}
