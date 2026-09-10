import 'package:flutter/services.dart';

/// 读取 Native 启动配置（RecordMode / Lang）
Future<Map<String, dynamic>> getLaunchConfig() async {
  const channel = MethodChannel('com.shoo.app/launch_config');
  try {
    final result = await channel.invokeMethod<Map<dynamic, dynamic>>('getLaunchConfig');
    return result?.cast<String, dynamic>() ?? {};
  } catch (_) {
    return {};
  }
}
