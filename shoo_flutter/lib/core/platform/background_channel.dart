import 'package:flutter/services.dart';

/// 后台播放通道
///
/// 处理应用后台播放相关功能。
/// iOS: BGTaskScheduler
/// Android: ForegroundService
class BackgroundChannel {
  static const MethodChannel _channel = MethodChannel('com.shoo.app/background');

  /// 启动后台播放服务
  static Future<bool> startBackgroundPlayback({
    required String title,
    required String body,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'startBackgroundPlayback',
        {
          'title': title,
          'body': body,
        },
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 更新后台播放通知
  static Future<void> updateNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _channel.invokeMethod<void>(
        'updateNotification',
        {
          'title': title,
          'body': body,
        },
      );
    } on PlatformException {
      // ignore
    }
  }

  /// 停止后台播放服务
  static Future<void> stopBackgroundPlayback() async {
    try {
      await _channel.invokeMethod<void>('stopBackgroundPlayback');
    } on PlatformException {
      // ignore
    }
  }

  /// 检查后台播放是否正在运行
  static Future<bool> isBackgroundPlaybackRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBackgroundPlaybackRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
