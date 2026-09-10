import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'core/audio/audio_controller.dart';
import 'core/storage/preferences.dart';
import 'core/purchase/purchase_manager.dart';

/// 全局初始化完成信号，闪屏页等待此 Future 完成后再跳转
late final Future<void> appInitialized;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 必须同步初始化：Preferences（因为 Provider 状态依赖它）
  prefs = Preferences();
  await prefs.init();

  // 初始化系统音量控制器
  VolumeController().showSystemUI = false;

  // 异步初始化：音频会话、屏幕常亮等（不阻塞 runApp）
  appInitialized = _initAsync();

  final container = ProviderContainer();
  initProvidersFromPrefs(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ShooApp(),
    ),
  );
}

/// 后台异步初始化（不阻塞首帧渲染）
Future<void> _initAsync() async {
  debugPrint('>>> INIT_START');
  try {
    // 音频会话必须先初始化，然后才能预加载播放器
    await _initAudioSession();
    debugPrint('>>> INIT_AUDIO_SESSION_DONE');

    // 并行执行剩余的非阻塞初始化 + 预加载音频播放器
    debugPrint('>>> INIT_PARALLEL_START');
    await Future.wait([
      _initWakelock(),
      PurchaseManager.instance.init().timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('>>> INIT_PURCHASE_TIMEOUT');
      }),
      AudioController.instance.preload().timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('>>> INIT_AUDIO_PRELOAD_TIMEOUT');
      }),
    ]);
    debugPrint('>>> INIT_PARALLEL_DONE');

    // 初始化系统音量监听
    await AudioController.instance.initVolumeListener();
    debugPrint('>>> INIT_VOLUME_LISTENER_DONE');

    debugPrint('>>> INIT_ALL_DONE');
  } catch (e) {
    debugPrint('>>> INIT_ERROR: $e');
  }
}

/// 配置音频会话
///
/// 使用 playback 独占模式：
/// - playback: 不受静音开关影响，锁屏后可继续播放
/// - 不加 mixWithOthers: 独占音频焦点，打断其他音乐（驱赶场景必须如此）
/// - Android 端使用 alarm 优先级，确保系统不会降低音量
Future<void> _initAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      usage: AndroidAudioUsage.alarm,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  ));
}

/// 屏幕常亮设置
Future<void> _initWakelock() async {
  debugPrint('>>> INIT_WAKELOCK_START');
  if (prefs.keepScreenOn) {
    WakelockPlus.enable();
  }
  debugPrint('>>> INIT_WAKELOCK_DONE');
}
