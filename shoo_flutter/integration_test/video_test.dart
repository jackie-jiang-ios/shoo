// Shoo video test - single-compile multi-language App Store preview video
// 编译一次，test 内部 for 循环遍历所有语言，配合 shell 逐个录屏合并音频
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/main.dart" as app;
import "package:shoo/app.dart"
    show localeProvider, themeModeProvider, goRouterProvider, resolveLocale;
import "package:shoo/l10n/app_localizations.dart" show S;
import "package:shoo/core/purchase/purchase_manager.dart";

/// 所有要录制的语言（按 App Store 截图顺序）
const languages = [
  "ar-SA", "bn", "ca", "cs", "da", "de-DE", "el",
  "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX",
  "fi", "fr-CA", "fr-FR", "gu", "he", "hi", "hr",
  "hu", "id", "it", "ja", "kn", "ko", "ml", "mr",
  "ms", "nl-NL", "no", "or", "pa", "pl", "pt-BR",
  "ro", "ru", "sk", "sl", "sv", "ta", "te", "th",
  "tr", "uk", "ur", "vi", "zh-Hans", "zh-Hant",
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Shoo Video - All Languages", () {
    testWidgets("QUICK VERIFY - 3 langs (no recording)", (tester) async {
      app.main();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element, listen: false);

      // 解锁 Pro，避免动物卡片 isLocked 弹出 paywall
      PurchaseManager.instance.debugSetPro(true);
      debugPrint("[INIT] PurchaseManager.isPro = ${PurchaseManager.instance.isPro}");

      // Only first 3 languages for quick verification
      const quickLangs = ["ar-SA", "ja", "zh-Hans"];
      for (final lang in quickLangs) {
        debugPrint("============ QUICK VERIFY START: $lang ============");

        debugPrint("[1/8] Setting locale...");
        final langCode = _getLangCode(lang);
        container.read(localeProvider.notifier).state = resolveLocale(langCode);
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint("[1/8] Locale set OK");

        debugPrint("[2/8] Checking goRouterProvider...");
        final router = container.read(goRouterProvider);
        if (router == null) {
          debugPrint("[FAIL] goRouterProvider is null! App init incomplete.");
          break;
        }
        debugPrint("[2/8] goRouter at location: ${router.routerDelegate.currentConfiguration.uri}");

        debugPrint("[3/8] Navigating to /...");
        router.go("/");
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint("[3/8] Now at: ${router.routerDelegate.currentConfiguration.uri}");
        debugPrint("[3/8] MaterialApp count: ${find.byType(MaterialApp).evaluate().length}");
        debugPrint("[3/8] Scaffold count: ${find.byType(Scaffold).evaluate().length}");

        // Scene 1: scroll
        debugPrint("[4/8] Scene 1: Scrolling home...");
        await _scrollDown(tester);
        await tester.pump(const Duration(milliseconds: 500));
        await _scrollUp(tester);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint("[4/8] Scene 1 scroll done");

        // Scene 2: tap animal card
        debugPrint("[5/8] Scene 2: Tapping first animal card...");
        await _tapFirstAnimalCard(tester);
        await tester.pump(const Duration(seconds: 2));
        debugPrint("[5/8] Scene 2 tap done");

        // Detail modal 用 Icons.close 关闭
        final closeBtnList = find.byIcon(Icons.close);
        debugPrint("[6/8] Close button count: ${closeBtnList.evaluate().length}");
        if (closeBtnList.evaluate().isNotEmpty) {
          debugPrint("[6/8] Closing modal with close button");
          await tester.tap(closeBtnList.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        } else {
          debugPrint("[6/8] No close button - modal may not have opened");
        }

        // Scene 3: open settings
        final settingsBtn = find.byIcon(Icons.settings);
        debugPrint("[7/8] Settings button count: ${settingsBtn.evaluate().length}");
        if (settingsBtn.evaluate().isNotEmpty) {
          await tester.tap(settingsBtn.first, warnIfMissed: false);
          await tester.pump(const Duration(seconds: 1));
        } else {
          debugPrint("[7/8] No settings button found, trying router.go('/settings')...");
          router.go('/settings');
          await tester.pumpAndSettle();
        }

        // Verify settings page title in target language
        debugPrint("[8/8] Verifying i18n...");
        final scaffolds = find.byType(Scaffold).evaluate().length;
        debugPrint("[8/8] Scaffold count now: $scaffolds");
        if (scaffolds > 0) {
          try {
            final s = S.of(tester.element(find.byType(Scaffold).first));
            debugPrint("[VERIFY] settings title = '${s.settings}'");
            debugPrint("[VERIFY] themeMode title = '${s.themeMode}'");
            debugPrint("[VERIFY] language title = '${s.language}'");
          } catch (e) {
            debugPrint("[ERROR] S.of failed: $e");
          }
        }

        // Back to home
        router.go("/");
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint("============ QUICK VERIFY END: $lang ============");
      }
    });

    testWidgets("Record all preview videos in one run", (tester) async {
      // TEMP: skip to allow quick-only verification
      // Remove the return below when running full recording with shell script
      if (!Platform.environment.containsKey("FULL_RECORD")) return;
      // 启动 app
      app.main();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      final element = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(element, listen: false);

      for (final lang in languages) {
        debugPrint("=== LANG_START: $lang ===");

        // 1. 切换语言（直接改 Provider）
        final langCode = _getLangCode(lang);
        container.read(localeProvider.notifier).state = resolveLocale(langCode);
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 2. 确保在首页（GoRouter.go 回到根路径）
        final router = container.read(goRouterProvider)!;
        router.go("/");
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 用分类 All 文字点击确认在首页（闪屏后可能在其他页）
        final allTexts = _getCategoryTexts(lang);
        final allText = allTexts["all"];
        if (allText != null) {
          final allFinder = find.text(allText);
          if (allFinder.evaluate().isNotEmpty) {
            await tester.tap(allFinder.first, warnIfMissed: false);
            await tester.pumpAndSettle(const Duration(milliseconds: 300));
          }
        }

        // 3. 通知 shell 脚本：当前语言已就绪可以开始录屏
        File("/tmp/shoo_video_ready").writeAsStringSync(lang);

        // 4. 等待 shell 脚本确认开始录屏 (快速检测 3s, 没有则继续)
        final hasShellScript = () => File("/tmp/shoo_video_start").existsSync();
        for (int i = 0; i < 15 && !hasShellScript(); i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        if (!hasShellScript()) {
          debugPrint("[FAST_MODE] No shell script detected, continuing without recording");
        }

        if (File("/tmp/shoo_video_start").existsSync()) {
          debugPrint("=== LANG_RECORDING: $lang ===");
          // 5. 等待录屏稳定（1s）
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // === Scene 1: 首页滚动 (3s) ===
        await _scrollDown(tester);
        await tester.pump(const Duration(seconds: 1));
        await _scrollUp(tester);
        await tester.pump(const Duration(seconds: 1));

        // === Scene 2: 切换猛兽分类 (3s) ===
        await _tapCategory(tester, "beast", lang);
        await tester.pump(const Duration(seconds: 2));
        await _tapCategory(tester, "all", lang);
        await tester.pump(const Duration(seconds: 1));

        // === Scene 3: 打开动物详情 (4s) ===
        await _tapFirstAnimalCard(tester);
        await tester.pump(const Duration(seconds: 3));

        // === Scene 4: 关闭弹框 (用 Icons.close) + 打开设置
        final closeBtn = find.byIcon(Icons.close);
        if (closeBtn.evaluate().isNotEmpty) {
          await tester.tap(closeBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
        final settingsBtn = find.byIcon(Icons.settings);
        if (settingsBtn.evaluate().isNotEmpty) {
          await tester.tap(settingsBtn.first, warnIfMissed: false);
          await tester.pump(const Duration(seconds: 2));
        }

        // 6. 通知 shell 脚本：停止录屏
        File("/tmp/shoo_video_stop").writeAsStringSync("stop");
        debugPrint("=== LANG_DONE: $lang ===");

        // 7. 等待录屏停止
        await tester.pump(const Duration(seconds: 2));

        // 8. 返回首页准备下一轮
        final homeBtn = find.byIcon(Icons.home);
        if (homeBtn.evaluate().isNotEmpty) {
          await tester.tap(homeBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        } else {
          router.go("/");
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }
    });
  });
}

// === Helper: 滚动 ===
Future<void> _scrollDown(WidgetTester tester) async {
  final scrollable = find.byType(CustomScrollView).first;
  if (scrollable.evaluate().isEmpty) return;
  await tester.fling(scrollable, const Offset(0, -300), 1000.0);
  await tester.pumpAndSettle();
}

Future<void> _scrollUp(WidgetTester tester) async {
  final scrollable = find.byType(CustomScrollView).first;
  if (scrollable.evaluate().isEmpty) return;
  await tester.fling(scrollable, const Offset(0, 300), 1000.0);
  await tester.pumpAndSettle();
}

// === Helper: 分类切换 ===
Future<void> _tapCategory(WidgetTester tester, String categoryId, String lang) async {
  final texts = _getCategoryTexts(lang);
  final text = texts[categoryId];
  if (text == null) return;
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) return;
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pumpAndSettle();
}

// Helper: 点击第一个动物卡片
Future<void> _tapFirstAnimalCard(WidgetTester tester) async {
  // 在 CustomScrollView 中找 InkWell，第一个是 Settings 按钮(40x40)，之后才是动物卡片(~103x396)
  final scrollable = find.byType(CustomScrollView).first;
  if (scrollable.evaluate().isEmpty) return;

  final inkWells = find.descendant(
    of: scrollable,
    matching: find.byType(InkWell),
  );
  final count = inkWells.evaluate().length;
  if (count < 2) return;

  // 找第一个足够大的 InkWell (动物卡片高度>=80px且宽度>=200px)
  for (int i = 0; i < count; i++) {
    final size = tester.getSize(inkWells.at(i));
    if (size.height >= 80 && size.width >= 200) {
      debugPrint("[TAP] Tapping animal card #i=$i size=$size");
      await tester.tap(inkWells.at(i), warnIfMissed: true);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint("[TAP] closeIcons after tap: ${find.byIcon(Icons.close).evaluate().length}");
      return;
    }
  }

  // fallback: tap 第二个 InkWel (skip Settings)
  debugPrint("[TAP] No card matched predicate, fallback to index 1");
  await tester.tap(inkWells.at(1), warnIfMissed: true);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

// === 语言代码映射 ===
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

// === 分类按钮文字映射 ===
Map<String, String> _getCategoryTexts(String locale) {
  const texts = <String, Map<String, String>>{
    "zh-Hans": {
      "all": "全部",
      "beast": "猛兽威胁",
      "reptile": "爬行类",
      "primate": "灵长类",
      "rodent": "啄齿类",
      "insect": "昆虫类",
      "bird": "鸟类"
    },
    "zh-Hant": {
      "all": "全部",
      "beast": "猛獸威脅",
      "reptile": "爬行類",
      "primate": "靈長類",
      "rodent": "�齒類",
      "insect": "昆蟲類",
      "bird": "鳥類"
    },
    "en-US": {
      "all": "All",
      "beast": "Beasts",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rodents",
      "insect": "Insects",
      "bird": "Birds"
    },
    "en-AU": {
      "all": "All",
      "beast": "Beasts",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rodents",
      "insect": "Insects",
      "bird": "Birds"
    },
    "en-CA": {
      "all": "All",
      "beast": "Beasts",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rodents",
      "insect": "Insects",
      "bird": "Birds"
    },
    "en-GB": {
      "all": "All",
      "beast": "Beasts",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rodents",
      "insect": "Insects",
      "bird": "Birds"
    },
    "ja": {
      "all": "すべて",
      "beast": "猛獣",
      "reptile": "爬虫類",
      "primate": "�長類",
      "rodent": "齧歯類",
      "insect": "昆虫類",
      "bird": "鳥類"
    },
    "ko": {
      "all": "전체",
      "beast": "맹수",
      "reptile": "파충류",
      "primate": "영장류",
      "rodent": "설치류",
      "insect": "곤충류",
      "bird": "조류"
    },
    "fr-FR": {
      "all": "Tout",
      "beast": "Bêtes féroces",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rongeurs",
      "insect": "Insectes",
      "bird": "Oiseaux"
    },
    "fr-CA": {
      "all": "Tout",
      "beast": "Bêtes féroces",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Rongeurs",
      "insect": "Insectes",
      "bird": "Oiseaux"
    },
    "de-DE": {
      "all": "Alle",
      "beast": "Raubtiere",
      "reptile": "Reptilien",
      "primate": "Primaten",
      "rodent": "Nagetiere",
      "insect": "Insekten",
      "bird": "Vögel"
    },
    "es-ES": {
      "all": "Todo",
      "beast": "Bestias",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Roedores",
      "insect": "Insectos",
      "bird": "Aves"
    },
    "es-MX": {
      "all": "Todo",
      "beast": "Bestias",
      "reptile": "Reptiles",
      "primate": "Primates",
      "rodent": "Roedores",
      "insect": "Insectos",
      "bird": "Aves"
    },
    "ru": {
      "all": "Все",
      "beast": "Хищники",
      "reptile": "Рептилии",
      "primate": "Приматы",
      "rodent": "Грызуны",
      "insect": "Насекомые",
      "bird": "Птицы"
    },
    "pt-BR": {
      "all": "Todos",
      "beast": "Feras",
      "reptile": "Répteis",
      "primate": "Primatas",
      "rodent": "Roedores",
      "insect": "Insetos",
      "bird": "Aves"
    },
    "th": {
      "all": "ทั้งหมด",
      "beast": "สัตว์�ู้ล่า",
      "reptile": "สัตว์เลื้อยคลาน",
      "primate": "สัตว์อันดับลิง",
      "rodent": "สัตว์ฟันแทะ",
      "insect": "แมลง",
      "bird": "นก"
    },
    "ar-SA": {
      "all": "الكل",
      "beast": "الوحوش",
      "reptile": "الزواحف",
      "primate": "الرئيسييات",
      "rodent": "القوارض",
      "insect": "الحشرات",
      "bird": "الطيور"
    },
    "id": {
      "all": "Semua",
      "beast": "Buas",
      "reptile": "Reptil",
      "primate": "Primata",
      "rodent": "Rodensia",
      "insect": "Serangga",
      "bird": "Burung"
    },
    "it": {
      "all": "Tutto",
      "beast": "Bestie",
      "reptile": "Rettili",
      "primate": "Primati",
      "rodent": "Roditori",
      "insect": "Insetti",
      "bird": "Uccelli"
    },
    "ms": {
      "all": "Semua",
      "beast": "Buas",
      "reptile": "Reptilia",
      "primate": "Primate",
      "rodent": "Rodensia",
      "insect": "Serangga",
      "bird": "Burung"
    },
    "nl-NL": {
      "all": "Alle",
      "beast": "Beesten",
      "reptile": "Reptielen",
      "primate": "Primaten",
      "rodent": "Knaagdieren",
      "insect": "Insecten",
      "bird": "Vogels"
    },
    "pl": {
      "all": "Wszystko",
      "beast": "Bestie",
      "reptile": "Gady",
      "primate": "Naczelne",
      "rodent": "Gryzonie",
      "insect": "Owady",
      "bird": "Ptaki"
    },
    "tr": {
      "all": "Tümü",
      "beast": "Canavarlar",
      "reptile": "Sürüngenler",
      "primate": "Primatlar",
      "rodent": "Kemirgenler",
      "insect": "Böcekler",
      "bird": "Kuşlar"
    },
    "vi": {
      "all": "Tất cả",
      "beast": "Thú dữ",
      "reptile": "Bò sát",
      "primate": "Linh trư�ng",
      "rodent": "Gặm nhấm",
      "insect": "Côn trùng",
      "bird": "Chim"
    },
    "hi": {
      "all": "सभी",
      "beast": "जा�वर",
      "reptile": "सरीस�प",
      "primate": "वानर",
      "rodent": "कृंतक",
      "insect": "की�",
      "bird": "पक्षी"
    },
    "da": {
      "all": "Alle",
      "beast": "Dyr",
      "reptile": "Krybdyr",
      "primate": "Primater",
      "rodent": "Gnavere",
      "insect": "Insekter",
      "bird": "Fugle"
    },
    "fi": {
      "all": "Kaikki",
      "beast": "Pedot",
      "reptile": "Matelijat",
      "primate": "Kädelliset",
      "rodent": "Jyrsijät",
      "insect": "Hyönteiset",
      "bird": "Linnut"
    },
    "gu": {
      "all": "બ�ા",
      "beast": "પ�ર�ણ��",
      "reptile": "સ�ી�ૃ�",
      "primate": "વાનર",
      "rodent": "�ંદર",
      "insect": "��ત�",
      "bird": "�ક�ષ�"
    },
    "ca": {
      "all": "Tot",
      "beast": "Bèsties",
      "reptile": "Rèptils",
      "primate": "Primats",
      "rodent": "Roedors",
      "insect": "Insectes",
      "bird": "Ocells"
    },
    "cs": {
      "all": "Vše",
      "beast": "Šelmy",
      "reptile": "Plazi",
      "primate": "Primáti",
      "rodent": "Hlodavci",
      "insect": "Hmyz",
      "bird": "Ptáci"
    },
    "kn": {
      "all": "�ಲ�ಲ�",
      "beast": "ಮ�ಗ",
      "reptile": "��ಳ�",
      "primate": "ಕಪಿ",
      "rodent": "�ಲ�",
      "insect": "ಕೀಟ",
      "bird": "ಹಕ್ಕಿ"
    },
    "hr": {
      "all": "Sve",
      "beast": "Zvijeri",
      "reptile": "Gmazovi",
      "primate": "Primati",
      "rodent": "Glodavci",
      "insect": "Kukci",
      "bird": "Ptice"
    },
    "ro": {
      "all": "Toate",
      "beast": "Bestii",
      "reptile": "Reptile",
      "primate": "Primate",
      "rodent": "Șoareci",
      "insect": "Insecte",
      "bird": "Păsări"
    },
    "mr": {
      "all": "सर्�",
      "beast": "प्रा�ी",
      "reptile": "सरीसृप",
      "primate": "वानर",
      "rodent": "कृंतक",
      "insect": "कीट",
      "bird": "पक्षी"
    },
    "ml": {
      "all": "എല്ലാം",
      "beast": "മ�ഗ�",
      "reptile": "ഉ�ഗ�",
      "primate": "കുരങ്ങ്",
      "rodent": "ച�്��",
      "insect": "�്�ാ�ി",
      "bird": "പ�്�ി"
    },
    "bn": {
      "all": "সব",
      "beast": "�শ�",
      "reptile": "সরীসৃপ",
      "primate": "�্রাইমে�",
      "rodent": "ঁঁদুর",
      "insect": "পোকা",
      "bird": "পাখি"
    },
    "no": {
      "all": "Alle",
      "beast": "Dyr",
      "reptile": "Krypdyr",
      "primate": "Primater",
      "rodent": "Gnavere",
      "insect": "Insekter",
      "bird": "Fugler"
    },
    "or": {
      "all": "ସମ��ତ",
      "beast": "�ନ୍��",
      "reptile": "ସ�ୀସ��",
      "primate": "ପ��ାଇ��ଟ�",
      "rodent": "ଗ୍ରାମ",
      "insect": "��ଟ",
      "bird": "�କ୍��"
    },
    "pa": {
      "all": "ਸਭ",
      "beast": "ਜ�ਨ�ਰ",
      "reptile": "��ੀਸ�ਰ�",
      "primate": "ਬ�ਦ�",
      "rodent": "ਚ��ਾ",
      "insect": "ਕੀ��",
      "bird": "��ਛੀ"
    },
    "sv": {
      "all": "Alla",
      "beast": "Djur",
      "reptile": "Kräldjur",
      "primate": "Primater",
      "rodent": "Gnagare",
      "insect": "Insekter",
      "bird": "Fåglar"
    },
    "sk": {
      "all": "Všetko",
      "beast": "Šelmy",
      "reptile": "Plazy",
      "primate": "Primáty",
      "rodent": "Hlodavce",
      "insect": "Hmyz",
      "bird": "Vtáky"
    },
    "sl": {
      "all": "Vse",
      "beast": "Zveri",
      "reptile": "Plazilci",
      "primate": "Prvaki",
      "rodent": "Glodavci",
      "insect": "Žuželke",
      "bird": "Ptice"
    },
    "te": {
      "all": "అన్న�",
      "beast": "మ�గ�ల�",
      "reptile": "స�ీ�ృ�ం",
      "primate": "కుర���",
      "rodent": "గిల�ల��ు",
      "insect": "కీటకం",
      "bird": "పక్షి"
    },
    "ta": {
      "all": "அ�ைத்தும்",
      "beast": "வில�்கு",
      "reptile": "ஊர்வன",
      "primate": "கு��்கு",
      "rodent": "�ி",
      "insect": "�ூ�்சி",
      "bird": "பறவை"
    },
    "ur": {
      "all": "سب",
      "beast": "جانور",
      "reptile": "رینگنے والا",
      "primate": "بندر",
      "rodent": "�وہا",
      "insect": "کیڑا",
      "bird": "پرندہ"
    },
    "uk": {
      "all": "Всі",
      "beast": "Хижаки",
      "reptile": "Плазуни",
      "primate": "Примати",
      "rodent": "Гризуни",
      "insect": "Комахи",
      "bird": "Птахи"
    },
    "he": {
      "all": "הכל",
      "beast": "חיות",
      "reptile": "�ל�立体声",
      "primate": "�רי�טי�",
      "rodent": "מכרסמים",
      "insect": "Unity",
      "bird": "עופות"
    },
    "el": {
      "all": "Όλα",
      "beast": "Θηρία",
      "reptile": "Ερπετά",
      "primate": "�ρωτεύοντα",
      "rodent": "�ρωκτικά",
      "insect": "Έντομα",
      "bird": "�ουλιά"
    },
    "hu": {
      "all": "Összes",
      "beast": "Vadak",
      "reptile": "Hüllők",
      "primate": "Főemlősök",
      "rodent": "Rágcsálók",
      "insect": "Rovarok",
      "bird": "Madarak"
    },
  };
  return texts[locale] ?? texts["en-US"]!;
}
