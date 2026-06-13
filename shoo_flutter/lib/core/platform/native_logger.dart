import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeLogger {
  NativeLogger._();

  static const MethodChannel _channel = MethodChannel('com.shoo.app/native_log');

  static Future<void> log({
    required String scope,
    required String message,
    String level = 'info',
    Map<String, Object?> data = const {},
  }) async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>('log', {
        'scope': scope,
        'message': message,
        'level': level,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Native logging is best-effort and must never break playback.
    }
  }
}
