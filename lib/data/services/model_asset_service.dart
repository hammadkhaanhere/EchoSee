import 'dart:io';

import 'package:eecho_see/core/constants.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies bundled Sherpa-ONNX models from Flutter assets to app documents
/// so native code can load them by filesystem path.
class ModelAssetService {
  static const _assetPrefix = 'assets/models';

  /// ONNX ASR files shipped in `assets/models/`.
  static const bundledAsrFiles = [
    AppConstants.offlineAsrEncoder,
    AppConstants.offlineAsrDecoder,
    AppConstants.offlineAsrJoiner,
    AppConstants.offlineAsrTokens,
  ];

  Future<String> ensureModelsOnDisk() async {
    final docs = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${docs.path}/models');
    if (!modelsDir.existsSync()) {
      await modelsDir.create(recursive: true);
    }

    for (final fileName in bundledAsrFiles) {
      final dest = File('${modelsDir.path}/$fileName');
      if (dest.existsSync() && dest.lengthSync() > 0) {
        continue;
      }

      final assetPath = '$_assetPrefix/$fileName';
      try {
        final data = await rootBundle.load(assetPath);
        await dest.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      } catch (_) {
        // Asset missing from bundle — skip (user may provide models manually).
      }
    }

    return modelsDir.path;
  }

  bool modelsExistOnDisk(String modelsRoot) {
    return bundledAsrFiles.every(
      (f) => File('$modelsRoot/$f').existsSync(),
    );
  }
}
