// Single-compile multi-language screenshot batch test
// 编译一次 -> for 循环遍历所有语言 -> 每个语言截 3 张图: 首页/详情/设置
import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/app.dart"
    show localeProvider, themeModeProvider, goRouterProvider, resolveLocale;
import "package:shoo/core/purchase/purchase_manager.dart";
import "package:shoo/core/screenshot/screenshot_helper.dart";
import "package:shoo/features/home/home_page.dart" show animalListKey;
import "package:shoo/main.dart" as app;

/// 默认所有支持的语言 (49 种)
const _allLanguages = [
  "en-US", "en-AU", "en-CA", "en-GB",
  "ar-SA", "bn", "ca", "cs", "da", "de-DE",
  "el", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR",
  "gu", "he", "hi", "hr", "hu",
  "id", "it", "ja", "kn", "ko",
  "ml", "mr", "ms", "nl-NL", "no",
  "or", "pa", "pl", "pt-BR", "ro",
  "ru", "sk", "sl", "sv", "ta",
  "te", "th", "tr", "uk", "ur",
  "vi", "zh-Hans", "zh-Hant",
];

/// 运行时支持 LANGS 环境变量做子集运行
/// 例: LANGS=en-US,ja,zh-Hans flutter test screenshot_batch_test.dart
List<String> get languages {
  const env = String.fromEnvironment("LANGS", defaultValue: "");
  if (env.isEmpty) return _allLanguages;
  return env.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

String get platform => const String.fromEnvironment("PLATFORM", defaultValue: "iphone");
double get pixelRatio => platform == "ipad" ? 2.0 : 3.0;
String get _outputDir => const String.fromEnvironment("OUTPUT_DIR", defaultValue: "");

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  debugPrint("[BATCH screenshot] languages: ${languages.length}");

  group("Shoo Screenshot Batch", () {
    testWidgets("Capture all languages, 3 screens each", (tester) async {
      app.main();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element, listen: false);

      // 解锁 Pro, 避免卡片 isLocked 弹 paywall
      PurchaseManager.instance.debugSetPro(true);

      for (final lang in languages) {
        debugPrint("=== LANG_START: $lang ===");

        // 1. 切语言
        final langCode = _getLangCode(lang);
        container.read(localeProvider.notifier).state = resolveLocale(langCode);
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 回到首页
        final router = container.read(goRouterProvider);
        router?.go("/");
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final outputDir = "${_outputDir}/$lang";
        Directory(outputDir).createSync(recursive: true);

        // 2. 截图 1: 首页
        await _capture(tester, "$outputDir/01_Home.png");
        debugPrint("  [HOME] $lang done");

        // 3. 截图 2: 详情弹框 (点击第一个动物卡片)
        final detailOk =
            await _tapFirstCardAndCapture(tester, "$outputDir/02_Detail.png");
        debugPrint("  [DETAIL] $lang done: ok=$detailOk");

        // 关弹窗 (如果有)
        final closeBtn = find.byIcon(Icons.close);
        if (closeBtn.evaluate().isNotEmpty) {
          await tester.tap(closeBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // 4. 截图 3: 设置页
        final settingsBtn = find.byIcon(Icons.settings);
        if (settingsBtn.evaluate().isNotEmpty) {
          await tester.tap(settingsBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await _capture(tester, "$outputDir/03_Settings.png");
          debugPrint("  [SETTINGS] $lang done");
          // 返回首页
          final backBtn = find.byIcon(Icons.arrow_back);
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn.first, warnIfMissed: false);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          } else {
            router?.go("/");
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }

        debugPrint("=== LANG_DONE: $lang ===");
      }
    });
  });
}

Future<void> _capture(WidgetTester tester, String path) async {
  final bytes = await ScreenshotHelper.captureAsBytes(pixelRatio: pixelRatio);
  if (bytes == null) {
    debugPrint("CAPTURE FAIL: $path");
    return;
  }
  File(path).writeAsBytesSync(bytes);
}

Future<bool> _tapFirstCardAndCapture(WidgetTester tester, String path) async {
  final cards = find.descendant(
    of: find.byKey(animalListKey),
    matching: find.byType(InkWell),
  );
  final count = cards.evaluate().length;
  debugPrint("  [TAP] cards found: $count");
  if (count == 0) return false;

  await tester.tap(cards.first, warnIfMissed: false);
  // 等弹框动画 (DraggableScrollableSheet 展开较慢)
  for (int i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // 检测弹窗出现
  final hasSheet = find.byType(DraggableScrollableSheet).evaluate().isNotEmpty;
  final hasClose = find.byIcon(Icons.close).evaluate().isNotEmpty;
  debugPrint("  [TAP] hasSheet=$hasSheet, hasClose=$hasClose");
  if (!hasSheet && !hasClose) return false;

  await _capture(tester, path);
  return true;
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
    "hi": "hi", "bn": "bn", "ca": "ca", "cs": "cs",
    "da": "da", "el": "el", "fi": "fi", "gu": "gu",
    "he": "he", "hr": "hr", "hu": "hu", "kn": "kn",
    "ml": "ml", "mr": "mr", "no": "no", "or": "or",
    "pa": "pa", "ro": "ro", "sk": "sk", "sl": "sl",
    "sv": "sv", "ta": "ta", "te": "te", "uk": "uk", "ur": "ur",
  };
  return map[locale] ?? locale;
}
