// Shoo screenshot test - 3 screenshots per locale: Home, Detail, Settings
import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/app.dart"
    show localeProvider, resolveLocale, themeModeProvider;
import "package:shoo/features/home/home_page.dart" show animalListKey;
import "package:shoo/core/purchase/purchase_manager.dart";
import "package:shoo/core/screenshot/screenshot_helper.dart";
import "package:shoo/features/settings/settings_page.dart";
import "package:shoo/main.dart" as app;

String get targetLang =>
    const String.fromEnvironment("LANG", defaultValue: "en-US");

/// 平台类型：iphone 或 ipad，用于决定截图 pixelRatio
String get targetPlatform =>
    const String.fromEnvironment("PLATFORM", defaultValue: "iphone");

/// 根据平台获取截图 pixelRatio
/// - iPhone 使用 3.0（Super Retina 屏幕 scale factor 3x）
/// - iPad Pro 13-inch (M5) 使用 2.0（scale factor 2x, 物理分辨率 2064×2752）
double get screenshotPixelRatio => targetPlatform == "ipad" ? 2.0 : 3.0;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Shoo Screenshots - $targetLang", () {
    testWidgets("Capture all 3 screenshots", (tester) async {
      debugPrint('>>> TEST_START: $targetLang');
      final preferences = await SharedPreferences.getInstance();
      final languageSet = await preferences.setString(
        "language",
        _getLangCode(targetLang),
      );
      final themeModeSet = await preferences.setString("theme_mode", "light");
      if (!languageSet || !themeModeSet) {
        fail("Failed to persist screenshot test locale or theme settings.");
      }

      debugPrint('>>> TEST_APP_MAIN_START');
      app.main();
      debugPrint('>>> TEST_APP_MAIN_DONE, pumping...');
      // 逐步 pump，避免无限等待
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_PUMP_${i}');
        if (find.byType(MaterialApp).evaluate().isNotEmpty) {
          // 检测首页 AppBar 中的设置按钮是否出现
          if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
            debugPrint('>>> TEST_HOME_PAGE_FOUND');
            break;
          }
        }
      }
      debugPrint('>>> TEST_PUMP_DONE');

      final element = tester.element(find.byType(MaterialApp).first);
      final container = ProviderScope.containerOf(element, listen: false);
      final expectedLocale = resolveLocale(_getLangCode(targetLang));
      container.read(localeProvider.notifier).state = expectedLocale;
      container.read(themeModeProvider.notifier).state = ThemeMode.light;
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final actualLocale = container.read(localeProvider);
      final actualThemeMode = container.read(themeModeProvider);
      if (actualLocale != expectedLocale ||
          actualThemeMode != ThemeMode.light) {
        debugPrint(
          "Screenshot test provider initialization mismatch: "
          "locale=$actualLocale, themeMode=$actualThemeMode",
        );
        fail("Screenshot test locale or theme provider initialization failed.");
      }

      // Force Pro unlocked
      debugPrint('>>> TEST_SET_PRO');
      PurchaseManager.instance.debugSetPro(true);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_SET_PRO_PUMP_$i');
      }
      await Future.delayed(const Duration(seconds: 1));
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_AFTER_PRO_PUMP_$i');
      }

      // ============ 截图1: 主页 ============
      debugPrint('>>> TEST_CAPTURE_HOME');
      debugPrint('>>> TEST_HOME_PAGE_CHECK: ${find.byType(MaterialApp).evaluate().length}');
      await _capture("01_Home.png");
      debugPrint('>>> TEST_CAPTURE_HOME_DONE');

      // ============ 截图2: 详情底部弹出层 ============
      debugPrint('>>> TEST_CAPTURE_DETAIL_START');
      final animalCards = find.descendant(
        of: find.byKey(animalListKey),
        matching: find.byType(InkWell),
      );
      final cardCount = tester.widgetList(animalCards).length;
      debugPrint('>>> TEST_ANIMAL_CARDS_FOUND: $cardCount');
      debugPrint('>>> TEST_ANIMAL_LIST_KEY_EXISTS: ${find.byKey(animalListKey).evaluate().length}');
      for (int i = 0; i < cardCount; i++) {
        final card = animalCards.at(i);
        debugPrint('>>> TEST_TAP_CARD_$i');
        await tester.tap(card, warnIfMissed: false);
        // 逐步 pump 等待弹出层
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 500));
          debugPrint('>>> TEST_TAP_PUMP_$j');
        }
        await Future.delayed(const Duration(seconds: 1));

        final hasSheet = tester.any(find.byType(DraggableScrollableSheet));
        debugPrint('>>> TEST_HAS_SHEET: $hasSheet');
        if (hasSheet) {
          await _capture("02_Detail.png");
          debugPrint('>>> TEST_CAPTURE_DETAIL_DONE');
          // 关闭弹出层：点击底部弹出层的关闭按钮
          final closeBtn = find.byIcon(Icons.close);
          if (tester.any(closeBtn)) {
            debugPrint('>>> TEST_CLOSE_SHEET');
            await tester.tap(closeBtn, warnIfMissed: false);
            for (int k = 0; k < 6; k++) {
              await tester.pump(const Duration(milliseconds: 500));
              debugPrint('>>> TEST_CLOSE_PUMP_$k');
            }
          }
          break;
        } else {
          // paywall 关闭
          final closeBtn = find.byIcon(Icons.close);
          if (tester.any(closeBtn)) {
            debugPrint('>>> TEST_CLOSE_PAYWALL');
            await tester.tap(closeBtn, warnIfMissed: false);
            for (int k = 0; k < 4; k++) {
              await tester.pump(const Duration(milliseconds: 500));
              debugPrint('>>> TEST_PAYWALL_PUMP_$k');
            }
          }
        }
      }

      // ============ 截图3: 设置页 ============
      debugPrint('>>> TEST_CAPTURE_SETTINGS_START');
      // 确保底部弹出层已关闭，回到主页
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_SETTINGS_WAIT_$i');
      }

      final settingsButton = find.byIcon(Icons.settings);
      debugPrint('>>> TEST_SETTINGS_BTN_FOUND: ${tester.any(settingsButton)}');
      if (!tester.any(settingsButton)) {
        debugPrint('>>> TEST_SETTINGS_BTN_NOT_FOUND - listing icons');
        fail("Settings button not found in the localized home page.");
      }
      debugPrint('>>> TEST_TAP_SETTINGS');
      await tester.tap(settingsButton);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_SETTINGS_PUMP_$i');
      }
      final settingsOpened = tester.any(find.byType(SettingsPage));
      debugPrint('>>> TEST_SETTINGS_PAGE_OPENED: $settingsOpened');
      if (!settingsOpened) {
        fail("Settings page did not open.");
      }
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('>>> TEST_SETTINGS_FINAL_PUMP_$i');
      }
      await _capture("03_Settings.png");
      debugPrint('>>> TEST_CAPTURE_SETTINGS_DONE');

      print(">>> SCREENSHOT_COMPLETE:$targetLang");
    });
  });
}

Future<void> _capture(String filename) async {
  final Uint8List? bytes =
      await ScreenshotHelper.captureAsBytes(pixelRatio: screenshotPixelRatio);
  if (bytes == null) {
    fail("Failed to capture screenshot: $filename");
  }
  final outputDir = const String.fromEnvironment(
    "OUTPUT_DIR",
    defaultValue: "fastlane/screenshots",
  );
  final file = File("$outputDir/$targetLang/$filename");
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
  print(">>> PNG_SAVED:${file.path}");
}

String _getLangCode(String locale) {
  const map = {
    "zh-Hans": "zh",
    "zh-Hant": "zh_TW",
    "en-US": "en",
    "en-AU": "en_AU",
    "en-CA": "en_CA",
    "en-GB": "en_GB",
    "ja": "ja",
    "ko": "ko",
    "fr-FR": "fr",
    "fr-CA": "fr_CA",
    "de-DE": "de",
    "es-ES": "es",
    "es-MX": "es_MX",
    "ru": "ru",
    "pt-BR": "pt",
    "th": "th",
    "ar-SA": "ar",
    "id": "id",
    "it": "it",
    "ms": "ms",
    "nl-NL": "nl",
    "pl": "pl",
    "tr": "tr",
    "vi": "vi",
    "hi": "hi",
    "da": "da",
    "fi": "fi",
    "gu": "gu",
    "ca": "ca",
    "cs": "cs",
    "kn": "kn",
    "hr": "hr",
    "ro": "ro",
    "mr": "mr",
    "ml": "ml",
    "bn": "bn",
    "no": "no",
    "or": "or",
    "pa": "pa",
    "sv": "sv",
    "sk": "sk",
    "sl": "sl",
    "te": "te",
    "ta": "ta",
    "ur": "ur",
    "uk": "uk",
    "he": "he",
    "el": "el",
    "hu": "hu",
  };
  return map[locale] ?? "en";
}
