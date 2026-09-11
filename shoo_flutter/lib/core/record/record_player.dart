import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/app.dart' show localeProvider, themeModeProvider, goRouterProvider, resolveLocale;
import 'package:shoo/core/purchase/purchase_manager.dart';
import 'package:shoo/l10n/app_localizations.dart' show S;
import 'record_automation.dart';

/// 进入录制模式后自动播放场景序列
class RecordPlayer {
  static Timer? _timer;
  static bool _playing = false;

  static Future<void> startIfRecording(BuildContext context, WidgetRef ref) async {
    final config = await getLaunchConfig();
    final isRecording = config['recordMode'] == true;
    if (!isRecording) return;

    final lang = (config['lang'] as String?) ?? 'en-US';
    debugPrint("[RecordPlayer] Starting recording mode for lang=$lang");

    // 切换语言
    final locale = _resolveLocaleFromTag(lang);
    ref.read(localeProvider.notifier).state = locale;
    ref.read(themeModeProvider.notifier).state = ThemeMode.light;

    // 等到 build 完成
    await Future.delayed(const Duration(seconds: 3));

    _playSequence(context, ref, lang);
  }

  static void _playSequence(BuildContext context, WidgetRef ref, String lang) {
    if (_playing) return;
    _playing = true;

    final router = ref.read(goRouterProvider);
    if (router == null) {
      debugPrint("[RecordPlayer] Router is null, aborting");
      return;
    }

    // 定义场景序列
    final scenes = [
      _Scene('Home: scroll', 2, (_) async {
        _scrollDown();
        await Future.delayed(const Duration(seconds: 1));
        _scrollUp();
      }),
      _Scene('Open beast category', 2, (_) async {
        _tapCategory('beast');
        await Future.delayed(const Duration(milliseconds: 500));
        _tapCategory('all');
      }),
      _Scene('Tap animal card', 3, (_) async {
        _tapFirstAnimalCard();
      }),
      _Scene('Close modal & open settings', 3, (_) async {
        _tapClose();
        await Future.delayed(const Duration(milliseconds: 500));
        _tapSettings();
      }),
    ];

    int sceneIndex = 0;
    void runNext() {
      if (sceneIndex >= scenes.length) {
        debugPrint("[RecordPlayer] All scenes complete");
        _playing = false;
        return;
      }
      final scene = scenes[sceneIndex];
      sceneIndex++;
      debugPrint("[RecordPlayer] ${scene.name}");
      scene.action(context).then(((_) {
        _timer = Timer(Duration(seconds: scene.duration), runNext);
      }) as FutureOr<void> Function(FutureOr<dynamic>?));
    }

    // 从首页开始
    router.go('/');
    runNext();
  }

  // === 元素定位辅助 ===

  static void _scrollDown() {
    // 找到第一个可滚动区域并向下滚动
    // 这部分需要在 widget 树定位时实现
  }

  static void _scrollUp() {}

  static void _tapCategory(String categoryId) {}

  static void _tapFirstAnimalCard() {}

  static void _tapClose() {}

  static void _tapSettings() {}

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _playing = false;
  }

  static Locale _resolveLocaleFromTag(String tag) {
    const map = {
      'zh-Hans': 'zh', 'zh-Hant': 'zh_TW',
      'en-US': 'en', 'en-AU': 'en_AU', 'en-CA': 'en_CA', 'en-GB': 'en_GB',
      'ja': 'ja', 'ko': 'ko', 'fr-FR': 'fr', 'fr-CA': 'fr_CA',
      'de-DE': 'de', 'es-ES': 'es', 'es-MX': 'es_MX',
      'ru': 'ru', 'pt-BR': 'pt', 'th': 'th', 'ar-SA': 'ar',
      'id': 'id', 'it': 'it', 'ms': 'ms', 'nl-NL': 'nl',
      'pl': 'pl', 'tr': 'tr', 'vi': 'vi',
      'hi': 'hi', 'da': 'da', 'fi': 'fi', 'gu': 'gu',
      'ca': 'ca', 'cs': 'cs', 'kn': 'kn', 'hr': 'hr',
      'ro': 'ro', 'mr': 'mr', 'ml': 'ml', 'bn': 'bn',
      'no': 'no', 'pa': 'pa', 'sv': 'sv', 'sk': 'sk',
      'sl': 'sl', 'te': 'te', 'ta': 'ta', 'uk': 'uk', 'ur': 'ur',
      'or': 'or', 'el': 'el', 'he': 'he', 'hu': 'hu',
    };
    final code = map[tag] ?? tag;
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }
}

class _Scene {
  final String name;
  final int duration;
  final Future<void> Function(BuildContext) action;
  _Scene(this.name, this.duration, this.action);
}
