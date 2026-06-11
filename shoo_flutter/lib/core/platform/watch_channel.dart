import 'package:flutter/services.dart';
import '../../models/watch_command.dart';

/// 手表通信通道
///
/// 处理手机与手表之间的通信。
/// iOS: WatchConnectivity
/// Android: Wearable API
class WatchChannel {
  static const MethodChannel _channel = MethodChannel('com.shoo.app/watch');
  static const EventChannel _eventChannel = EventChannel('com.shoo.app/watch_events');

  static Stream<dynamic>? _watchEventStream;

  /// 监听手表端发来的命令
  static Stream<PhoneCommand> get watchEventStream {
    _watchEventStream ??= _eventChannel.receiveBroadcastStream();
    return _watchEventStream!.map((event) {
      if (event is Map) {
        return PhoneCommand.fromJson(Map<String, dynamic>.from(event));
      }
      throw FormatException('Invalid watch event format: $event');
    });
  }

  /// 检查手表是否已连接
  static Future<bool> isWatchConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isWatchConnected');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 发送命令到手表
  static Future<bool> sendCommand(WatchCommand command) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'sendCommand',
        command.toJson(),
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 同步声音列表到手表
  static Future<bool> syncSounds(List<SoundInfo> sounds) async {
    return sendCommand(WatchCommand.syncSounds(sounds));
  }

  /// 请求手表播放声音
  static Future<bool> requestPlay({
    required String soundId,
    required double volume,
    required String mode,
  }) async {
    return sendCommand(WatchCommand.play(
      soundId: soundId,
      volume: volume,
      mode: mode,
    ));
  }

  /// 请求手表停止声音
  static Future<bool> requestStop(String soundId) async {
    return sendCommand(WatchCommand.stop(soundId: soundId));
  }

  /// 请求手表停止所有声音
  static Future<bool> requestStopAll() async {
    return sendCommand(WatchCommand.stopAll());
  }
}
