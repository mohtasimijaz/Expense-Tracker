import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a widget wrapped in a [RepaintBoundary] as a PNG and opens the
/// system share sheet.
abstract final class ShareImage {
  static const double _pixelRatio = 3;
  static const String _mimeType = 'image/png';

  /// Shares the boundary behind [key]. [origin] anchors the share popover
  /// on iPad. Returns `false` if capturing or sharing failed.
  static Future<bool> share(
    GlobalKey key, {
    required String fileName,
    required String text,
    Rect? origin,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) return false;
      final file = XFile.fromData(
        data.buffer.asUint8List(),
        mimeType: _mimeType,
        name: fileName,
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: text,
          fileNameOverrides: [fileName],
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
