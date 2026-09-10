import 'package:flutter/services.dart';

/// 录制自动化控制器
/// 无需 flutter test 编译，通过运行时参数启动录制场景
class RecordAutomation {
  static const _channel = MethodChannel('com.shoo.app/platform');

  /// 从原生代码获取启动配置（录制模式标记 + 语言）
  static Future<Map<String, String>?> getLaunchConfig() async {
    try {
      return Map<String, String>.from(
        await _channel.invokeMapMethod<String, String>('getLaunchConfig') ?? {},
      );
    } catch (_) {
      return null;
    }
  }

  /// 检查是否在录制模式
  static Future<bool> isRecordMode() async {
    final config = await getLaunchConfig();
    return config?['recordMode'] == 'true';
  }

  /// 获取录制语言代码
  static Future<String?> getLaunchLang() async {
    final config = await getLaunchConfig();
    if (config != null && config['recordMode'] == 'true') {
      return config['lang'] ?? 'en';
    }
    return null;
  }
}
