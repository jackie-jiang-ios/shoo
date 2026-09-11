// Single-compile multi-language App Store preview video
// 编译一次 -> for 循环遍历所有语言 -> 每个语言录屏 ~15s
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:shoo/app.dart"
    show localeProvider, themeModeProvider, goRouterProvider, resolveLocale;
import "package:shoo/main.dart" as app;
import "package:shoo/core/purchase/purchase_manager.dart";

const languages = [
  "zh-Hans", "zh-Hant", "en-US", "en-AU", "en-CA", "en-GB",
  "ja", "ko", "fr-FR", "fr-CA", "de-DE", "es-ES", "es-MX",
  "ru", "pt-BR", "th", "ar-SA", "id", "it", "ms", "nl-NL",
  "pl", "tr", "vi", "hi", "da", "fi", "gu", "ca", "cs",
  "kn", "hr", "ro", "mr", "ml", "bn", "no", "pa", "sv",
  "sk", "sl", "te", "ta", "uk", "ur", "or", "el", "he", "hu",
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Video Recording", () {
    testWidgets("Record all languages", (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element, listen: false);
      PurchaseManager.instance.debugSetPro(true);

      for (final lang in languages) {
        debugPrint("=== START: $lang ===");

        // 1. 切换语言
        final langCode = _getLangCode(lang);
        container.read(localeProvider.notifier).state = resolveLocale(langCode);
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 2. 回首页并确保完全显示
        final router = container.read(goRouterProvider);
        router?.go("/");
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 3. 通知 shell 开始录屏
        File("/tmp/shoo_video_lang").writeAsStringSync(lang);
        debugPrint("  Ready: $lang");

        // 4. 等待 shell 确认开始（最多 10s）
        bool started = false;
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (File("/tmp/shoo_video_start").existsSync()) {
            started = true;
            break;
          }
        }
        if (!started) {
          debugPrint("  No shell, skip recording for $lang");
        }

        // 5. 执行场景序列
        // Scene 1: 首页滚动展示 (5s)
        await _scroll(tester);
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
        }

        // Scene 2: 打开详情页 (5s)
        await _tapCard(tester);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
        }

        // Scene 3: 关闭弹窗 + 进入设置页 (5s)
        await _tapClose(tester);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await _tapSettings(tester);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
        }

        // 6. 通知 shell 停止录屏
        File("/tmp/shoo_video_done").writeAsStringSync(lang);
        debugPrint("  Done: $lang");

        // 7. 等 shell 停止
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (File("/tmp/shoo_video_stopped").existsSync()) break;
        }

        // 8. 清理信号
        router?.go("/");
        await tester.pump(const Duration(milliseconds: 500));

        debugPrint("=== END: $lang ===\n");
      }
    });
  });
}

Future<void> _scroll(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  if (list.evaluate().isNotEmpty) {
    await tester.fling(list, const Offset(0, -300), 1000);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.fling(list, const Offset(0, 300), 1000);
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _tapCard(WidgetTester tester) async {
  final cards = find.byType(InkWell);
  if (cards.evaluate().length > 1) {
    await tester.tap(cards.at(1), warnIfMissed: false);
    await tester.pump();
  }
}

Future<void> _tapClose(WidgetTester tester) async {
  final closeBtn = find.byIcon(Icons.close);
  if (closeBtn.evaluate().isNotEmpty) {
    await tester.tap(closeBtn.first, warnIfMissed: false);
    await tester.pump();
  }
}

Future<void> _tapSettings(WidgetTester tester) async {
  final settingsBtn = find.byIcon(Icons.settings);
  if (settingsBtn.evaluate().isNotEmpty) {
    await tester.tap(settingsBtn.first, warnIfMissed: false);
    await tester.pump();
  }
}

String _getLangCode(String locale) {
  const map = {
    "zh-Hans": "zh", "zh-Hant": "zh_TW",
    "en-US": "en", "en-AU": "en_AU", "en-CA": "en_CA", "en-GB": "en_GB",
    "ja": "ja", "ko": "ko", "fr-FR": "fr", "fr-CA": "fr_CA",
    "de-DE": "de", "es-ES": "es", "es-MX": "es_MX",
    "ru": "ru", "pt-BR": "pt", "th": "th", "ar-SA": "ar",
    "id": "id", "it": "it", "ms": "ms", "nl-NL": "nl",
    "pl": "pl", "tr": "tr", "vi": "vi",
    "hi": "hi", "da": "da", "fi": "fi", "gu": "gu",
    "ca": "ca", "cs": "cs", "kn": "kn", "hr": "hr",
    "ro": "ro", "mr": "mr", "ml": "ml", "bn": "bn",
    "no": "no", "pa": "pa", "sv": "sv", "sk": "sk",
    "sl": "sl", "te": "te", "ta": "ta", "uk": "uk", "ur": "ur",
    "or": "or", "el": "el", "he": "he", "hu": "hu",
  };
  return map[locale] ?? locale;
}
