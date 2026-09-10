import 'dart:async';

import 'package:flutter/services.dart';

/// 原生系统音量控制器
/// 替代 volume_controller 插件，使用 MethodChannel 直接与 iOS 原生代码通信
class NativeVolumeController {
  static const MethodChannel _channel =
      MethodChannel('com.yangshiqin.shoo/volume');
  static StreamSubscription<dynamic>? _volumeSubscription;

  /// 设置是否显示系统音量 UI
  static Future<void> setShowSystemUI(bool show) async {
    try {
      await _channel.invokeMethod('setShowSystemUI', {'show': show});
    } catch (e) {
      // 忽略平台不支持的错误
    }
  }

  /// 获取当前系统音量 (0.0 - 1.0)
  static Future<double> getVolume() async {
    try {
      final volume = await _channel.invokeMethod<double>('getVolume');
      return volume ?? 1.0;
    } catch (e) {
      return 1.0;
    }
  }

  /// 设置系统音量 (0.0 - 1.0)
  static Future<void> setVolume(double volume, {bool showSystemUI = false}) async {
    try {
      await _channel.invokeMethod('setVolume', {
        'volume': volume.clamp(0.0, 1.0),
        'showSystemUI': showSystemUI,
      });
    } catch (e) {
      // 忽略平台不支持的错误
    }
  }

  /// 监听系统音量变化
  static void listen(void Function(double volume) onVolumeChanged) {
    _volumeSubscription?.cancel();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onVolumeChanged') {
        final volume = (call.arguments as num?)?.toDouble() ?? 1.0;
        onVolumeChanged(volume);
      }
    });
    // 开始监听
    _channel.invokeMethod('startVolumeListener').catchError((_) {});
  }

  /// 停止监听音量变化
  static void stopListening() {
    _channel.setMethodCallHandler(null);
    _channel.invokeMethod('stopVolumeListener').catchError((_) {});
    _volumeSubscription?.cancel();
    _volumeSubscription = null;
  }
}
