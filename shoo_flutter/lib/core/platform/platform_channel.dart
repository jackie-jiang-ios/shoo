import 'package:flutter/services.dart';
import '../../models/watch_command.dart';

/// 原生通道统一接口
///
/// 提供 Flutter 与原生平台之间的通信通道。
class PlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.shoo.app/platform');

  /// 调用原生方法
  static Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      print('Platform channel error: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// 检查是否支持超声波播放
  static Future<bool> isUltrasonicSupported() async {
    final result = await invokeMethod<bool>('isUltrasonicSupported');
    return result ?? false;
  }

  /// 播放超声波
  static Future<bool> playUltrasonic({
    required double frequency,
    required double volume,
    required String mode,
  }) async {
    final result = await invokeMethod<bool>('playUltrasonic', {
      'frequency': frequency,
      'volume': volume,
      'mode': mode,
    });
    return result ?? false;
  }

  /// 停止超声波
  static Future<void> stopUltrasonic() async {
    await invokeMethod<void>('stopUltrasonic');
  }

  /// 开始后台播放服务
  static Future<void> startBackgroundService() async {
    await invokeMethod<void>('startBackgroundService');
  }

  /// 停止后台播放服务
  static Future<void> stopBackgroundService() async {
    await invokeMethod<void>('stopBackgroundService');
  }

  /// 获取设备最大音量
  static Future<double> getDeviceMaxVolume() async {
    final result = await invokeMethod<double>('getDeviceMaxVolume');
    return result ?? 1.0;
  }

  /// 设置设备音量
  static Future<void> setDeviceVolume(double volume) async {
    await invokeMethod<void>('setDeviceVolume', {'volume': volume});
  }

  /// 请求必要权限
  static Future<bool> requestPermissions() async {
    final result = await invokeMethod<bool>('requestPermissions');
    return result ?? false;
  }

  /// 检查权限是否已授予
  static Future<bool> checkPermissions() async {
    final result = await invokeMethod<bool>('checkPermissions');
    return result ?? false;
  }
}
