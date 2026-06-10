import 'dart:async';
import 'dart:typed_data';

import 'package:eecho_see/core/app_settings.dart';
import 'package:eecho_see/core/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioCaptureService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;

  Future<bool> ensurePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  RecordConfig _configForQuality(AudioQuality quality) {
    final bitRate = switch (quality) {
      AudioQuality.low => 64000,
      AudioQuality.standard => 128000,
      AudioQuality.high => 256000,
    };

    return RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: AppConstants.sampleRateHz,
      numChannels: AppConstants.audioChannels,
      bitRate: bitRate,
    );
  }

  Future<Stream<Uint8List>?> startStream({AudioQuality quality = AudioQuality.standard}) async {
    if (!await ensurePermission()) {
      return null;
    }

    final stream = await _recorder.startStream(_configForQuality(quality));
    return stream;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
