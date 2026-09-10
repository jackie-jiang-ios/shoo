import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 截图辅助类
class ScreenshotHelper {
  /// App 根 RepaintBoundary 的 key
  static final GlobalKey repaintBoundaryKey = GlobalKey();

  /// 捕获 App 根页面为 PNG 字节
  static Future<Uint8List?> captureAsBytes({double pixelRatio = 3.0}) async {
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('ScreenshotHelper: RepaintBoundary not found');
      return null;
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// 从给定的 GlobalKey 捕获截图
  static Future<Uint8List?> captureFromKey(GlobalKey key, {double pixelRatio = 3.0}) async {
    final boundary = key.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('ScreenshotHelper: RepaintBoundary not found for key $key');
      return null;
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
