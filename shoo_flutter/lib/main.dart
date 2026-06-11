import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'core/storage/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  prefs = Preferences();
  await prefs.init();

  // 配置音频会话 - 确保正确播放
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // 根据设置决定是否保持屏幕常亮
  if (prefs.keepScreenOn) {
    WakelockPlus.enable();
  }

  runApp(
    const ProviderScope(
      child: ShooApp(),
    ),
  );
}
