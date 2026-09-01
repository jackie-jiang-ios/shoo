// Shoo video test - multi-language App Store preview video
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/main.dart" as app;
import "package:shoo/app.dart" show localeProvider, themeModeProvider, resolveLocale, resolveThemeMode;
import "package:shoo/core/storage/preferences.dart" show prefs, Preferences;

String get targetLang =>
    const String.fromEnvironment("LANG", defaultValue: "en-US");

String get videoDir =>
    const String.fromEnvironment("OUTPUT_DIR", defaultValue: "fastlane/screenshots") +
    "/$targetLang";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Shoo Video - $targetLang", () {
    testWidgets("Record preview video", (tester) async {
      // Write language to real SharedPreferences BEFORE app launch
      // (integration test uses real platform channel, not mock)
      final sp = await SharedPreferences.getInstance();
      await sp.setString('language', _getLangCode(targetLang));
      await sp.setString('theme_mode', 'light');

      // Launch the real app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Also override locale via the app's ProviderContainer
      // for cases where the simple languageCode doesn't match supportedLocales (e.g. fr_CA)
      try {
        final element = tester.element(find.byType(MaterialApp));
        final container = ProviderScope.containerOf(element, listen: false);
        container.read(localeProvider.notifier).state = resolveLocale(_getLangCode(targetLang));
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } catch (_) {
        // Fallback: SharedPreferences already set, should work
      }

      // Verify locale was set correctly
      try {
        final element = tester.element(find.byType(MaterialApp));
        final container = ProviderScope.containerOf(element, listen: false);
        final locale = container.read(localeProvider);
        debugPrint("=== VIDEO TEST: targetLang=$targetLang, langCode=${_getLangCode(targetLang)}, locale=$locale ===");
      } catch (e) {
        debugPrint("=== VIDEO TEST: Failed to read locale: $e ===");
      }

      // Signal script that app is ready
      File("/tmp/shoo_video_ready_$targetLang").writeAsStringSync("ready");

      // Wait for recording to start
      while (!File("/tmp/shoo_video_start_$targetLang").existsSync()) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // === Scene 1: Home page - scroll through animals (3s) ===
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await _scrollDown(tester);
      await tester.pump(const Duration(seconds: 1));
      await _scrollUp(tester);
      await tester.pump(const Duration(seconds: 1));

      // === Scene 2: Select beast category (3s) ===
      await _tapCategory(tester, "beast");
      await tester.pump(const Duration(seconds: 2));
      await _tapCategory(tester, "all");
      await tester.pump(const Duration(seconds: 1));

      // === Scene 3: Open animal detail (4s) ===
      await _tapFirstAnimalCard(tester);
      await tester.pump(const Duration(seconds: 3));

      // === Scene 4: Go back, open settings (3s) ===
      final backBtn = find.byIcon(Icons.arrow_back);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn);
        await tester.pumpAndSettle();
      }
      final settingsBtn = find.byIcon(Icons.settings);
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn);
        await tester.pump(const Duration(seconds: 2));
      }

      // Signal recording to stop
      File("/tmp/shoo_video_stop_$targetLang").writeAsStringSync("stop");

      // Wait for recording to finish
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

Future<void> _scrollDown(WidgetTester tester) async {
  await tester.fling(find.byType(CustomScrollView).first, const Offset(0, -300), 1000.0);
  await tester.pumpAndSettle();
}

Future<void> _scrollUp(WidgetTester tester) async {
  await tester.fling(find.byType(CustomScrollView).first, const Offset(0, 300), 1000.0);
  await tester.pumpAndSettle();
}

Future<void> _tapCategory(WidgetTester tester, String categoryId) async {
  final texts = _getCategoryTexts(targetLang);
  final text = texts[categoryId];
  if (text != null) {
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _tapFirstAnimalCard(WidgetTester tester) async {
  final cards = find.byType(GestureDetector);
  if (cards.evaluate().isNotEmpty) {
    await tester.tap(cards.first);
    await tester.pumpAndSettle();
  }
}

String _getLangCode(String locale) {
  const map = {
    "zh-Hans":"zh","zh-Hant":"zh_TW","en-US":"en","ja":"ja","ko":"ko",
    "fr-FR":"fr","de-DE":"de","es-ES":"es","ru":"ru","pt-BR":"pt","th":"th",
    "ar-SA":"ar","id":"id","it":"it","ms":"ms","nl-NL":"nl","pl":"pl","tr":"tr","vi":"vi",
    "hi":"hi","da":"da","fr-CA":"fr_CA","fi":"fi","gu":"gu","ca":"ca","cs":"cs",
    "kn":"kn","hr":"hr","ro":"ro","mr":"mr","ml":"ml","bn":"bn","no":"no",
    "pa":"pa","sv":"sv","sk":"sk","sl":"sl","te":"te","ta":"ta","ur":"ur",
    "uk":"uk","es-MX":"es_MX","he":"he","el":"el","hu":"hu",
    "en-AU":"en_AU","en-CA":"en_CA","en-GB":"en_GB",
  };
  return map[locale] ?? "en";
}

Map<String, String?> _getCategoryTexts(String locale) {
  const texts = <String, Map<String, String>>{
    "zh-Hans": { "all": "全部", "beast": "猛兽威胁", "reptile": "爬行类", "primate": "灵长类", "rodent": "啄齿类", "insect": "昆虫类", "bird": "鸟类" },
    "zh-Hant": { "all": "全部", "beast": "猛獸威脈", "reptile": "爬行類", "primate": "靈長類", "rodent": "啄齲類", "insect": "昆蟲類", "bird": "鳥類" },
    "en-US": { "all": "All", "beast": "Beasts", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rodents", "insect": "Insects", "bird": "Birds" },
    "ja": { "all": "すべて", "beast": "猛獣", "reptile": "爬虫類", "primate": "霊長類", "rodent": "齧歯類", "insect": "昆虫類", "bird": "鳥類" },
    "ko": { "all": "전체", "beast": "맹수", "reptile": "파축류", "primate": "영장류", "rodent": "설치류", "insect": "곤추류", "bird": "조류" },
    "fr-FR": { "all": "Tout", "beast": "Bêtes féroces", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rongeurs", "insect": "Insectes", "bird": "Oiseaux" },
    "de-DE": { "all": "Alle", "beast": "Raubtiere", "reptile": "Reptilien", "primate": "Primaten", "rodent": "Nagetiere", "insect": "Insekten", "bird": "Vögel" },
    "es-ES": { "all": "Todo", "beast": "Bestias", "reptile": "Reptiles", "primate": "Primates", "rodent": "Roedores", "insect": "Insectos", "bird": "Aves" },
    "ru": { "all": "Все", "beast": "Хищники", "reptile": "Рептилии", "primate": "Приматы", "rodent": "Грызуны", "insect": "Насекомые", "bird": "Птицы" },
    "pt-BR": { "all": "Todos", "beast": "Feras", "reptile": "Répteis", "primate": "Primatas", "rodent": "Roedores", "insect": "Insetos", "bird": "Aves" },
    "th": { "all": "ทั้งหมด", "beast": "สัตว์นักล่า", "reptile": "สัตว์เลื้อยคลาน", "primate": "สัตว์อันดับลิง", "rodent": "สัตว์ฟันแทะ", "insect": "แมลง", "bird": "นก" },
    "ar-SA": { "all": "\u0627\u0644\u0643\u0644", "beast": "\u0627\u0644\u0648\u062d\u0648\u0634", "reptile": "\u0627\u0644\u0632\u0648\u0627\u062d\u0641", "primate": "\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0627\u062a", "rodent": "\u0627\u0644\u0642\u0648\u0627\u0631\u0636", "insect": "\u0627\u0644\u062d\u0634\u0631\u0627\u062a", "bird": "\u0627\u0644\u0637\u064a\u0648\u0631" },
    "id": { "all": "Semua", "beast": "Buas", "reptile": "Reptil", "primate": "Primata", "rodent": "Rodensia", "insect": "Serangga", "bird": "Burung" },
    "it": { "all": "Tutti", "beast": "Bestie", "reptile": "Rettili", "primate": "Primati", "rodent": "Roditori", "insect": "Insetti", "bird": "Uccelli" },
    "ms": { "all": "Semua", "beast": "Buas", "reptile": "Reptilia", "primate": "Primate", "rodent": "Rodensia", "insect": "Serangga", "bird": "Burung" },
    "nl-NL": { "all": "Alle", "beast": "Beesten", "reptile": "Reptielen", "primate": "Primaten", "rodent": "Knaagdieren", "insect": "Insecten", "bird": "Vogels" },
    "pl": { "all": "Wszystko", "beast": "Bestie", "reptile": "Gady", "primate": "Naczelne", "rodent": "Gryzonie", "insect": "Owady", "bird": "Ptaki" },
    "tr": { "all": "T\u00fcm\u00fc", "beast": "Canavarlar", "reptile": "S\u00fcr\u00fcngenler", "primate": "Primatlar", "rodent": "Kemirgenler", "insect": "B\u00f6cekler", "bird": "Ku\u015flar" },
    "vi": { "all": "T\u1ea5t c\u1ea3", "beast": "Th\u00fa d\u1eef", "reptile": "B\u00f2 s\u00e1t", "primate": "Linh tr\u01b0\u1edfng", "rodent": "G\u1eb7m nh\u1ea5m", "insect": "C\u00f4n tr\u00f9ng", "bird": "Chim" },
    "hi": { "all": "\u0938\u092c", "beast": "\u091c\u093e\u0928\u0935\u0930", "reptile": "\u0938\u0930\u0940\u0938\u0943\u092a", "primate": "\u0935\u093e\u0928\u0930", "rodent": "\u0915\u0943\u0902\u0924\u0915", "insect": "\u0915\u0940\u091f", "bird": "\u092a\u0915\u094d\u0937\u0940" },
    "da": { "all": "Alle", "beast": "Dyr", "reptile": "Krybdyr", "primate": "Primater", "rodent": "Gnavere", "insect": "Insekter", "bird": "Fugle" },
    "fr-CA": { "all": "Tout", "beast": "B\u00eates f\u00e9roces", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rongeurs", "insect": "Insectes", "bird": "Oiseaux" },
    "fi": { "all": "Kaikki", "beast": "Pedot", "reptile": "Matelijat", "primate": "K\u00e4delliset", "rodent": "Jyrsij\u00e4t", "insect": "Hy\u00f6nteiset", "bird": "Linnut" },
    "ca": { "all": "Tot", "beast": "B\u00e8sties", "reptile": "R\u00e8ptils", "primate": "Primats", "rodent": "Roedors", "insect": "Insectes", "bird": "Ocells" },
    "cs": { "all": "V\u0161e", "beast": "\u0160elmy", "reptile": "Plazi", "primate": "Prim\u00e1ti", "rodent": "Hlodavci", "insect": "Hmyz", "bird": "Pt\u00e1ci" },
    "hr": { "all": "Sve", "beast": "Zvijeri", "reptile": "Gmazovi", "primate": "Primati", "rodent": "Glodavci", "insect": "Kukci", "bird": "Ptice" },
    "ro": { "all": "Toate", "beast": "Bestii", "reptile": "Reptile", "primate": "Primate", "rodent": "\u0218oareci", "insect": "Insecte", "bird": "P\u0103s\u0103ri" },
    "bn": { "all": "\u09b8\u09ac", "beast": "\u09aa\u09b6\u09c1", "reptile": "\u09b8\u09b0\u09c0\u09b8\u09c3\u09aa", "primate": "\u09aa\u09cd\u09b0\u09be\u0987\u09ae\u09c7\u099f", "rodent": "\u0987\u09a6\u09c1\u09b0", "insect": "\u09aa\u09cb\u0995\u09be", "bird": "\u09aa\u09be\u0996\u09bf" },
    "no": { "all": "Alle", "beast": "Dyr", "reptile": "Krypdyr", "primate": "Primater", "rodent": "Gnavere", "insect": "Insekter", "bird": "Fugler" },
    "sv": { "all": "Alla", "beast": "Djur", "reptile": "Kr\u00e4ldjur", "primate": "Primater", "rodent": "Gnagare", "insect": "Insekter", "bird": "F\u00e5glar" },
    "sk": { "all": "V\u0161etko", "beast": "\u0160elmy", "reptile": "Plazy", "primate": "Prim\u00e1ty", "rodent": "Hlodavce", "insect": "Hmyz", "bird": "Vt\u00e1ky" },
    "sl": { "all": "Vse", "beast": "Zveri", "reptile": "Plazilci", "primate": "Prvaki", "rodent": "Glodavci", "insect": "\u017du\u017eelke", "bird": "Ptice" },
    "uk": { "all": "\u0412\u0441\u0456", "beast": "\u0425\u0438\u0436\u0430\u043a\u0438", "reptile": "\u041f\u043b\u0430\u0437\u0443\u043d\u0438", "primate": "\u041f\u0440\u0438\u043c\u0430\u0442\u0438", "rodent": "\u0413\u0440\u0438\u0437\u0443\u043d\u0438", "insect": "\u041a\u043e\u043c\u0430\u0445\u0438", "bird": "\u041f\u0442\u0430\u0445\u0438" },
    "es-MX": { "all": "Todo", "beast": "Bestias", "reptile": "Reptiles", "primate": "Primates", "rodent": "Roedores", "insect": "Insectos", "bird": "Aves" },
    "he": { "all": "\u05d4\u05db\u05dc", "beast": "\u05d7\u05d9\u05d5\u05ea", "reptile": "\u05d6\u05d7\u05dc\u05d9\u05dd", "primate": "\u05e4\u05e8\u05d9\u05de\u05d8\u05d9\u05dd", "rodent": "\u05de\u05db\u05e8\u05e1\u05de\u05d9\u05dd", "insect": "\u05d7\u05e8\u05e7\u05d9\u05dd", "bird": "\u05e2\u05d5\u05e4\u05d5\u05ea" },
    "el": { "all": "\u038c\u03bb\u03b1", "beast": "\u0398\u03b7\u03c1\u03af\u03b1", "reptile": "\u0388\u03c1\u03c0\u03b5\u03c4\u03ac", "primate": "\u03a0\u03c1\u03c9\u03c4\u03b5\u03cd\u03bf\u03bd\u03c4\u03b1", "rodent": "\u03a4\u03c1\u03c9\u03ba\u03c4\u03b9\u03ba\u03ac", "insect": "\u0388\u03bd\u03c4\u03bf\u03bc\u03b1", "bird": "\u03a0\u03bf\u03c5\u03bb\u03b9\u03ac" },
    "hu": { "all": "\u00d6sszes", "beast": "Vadak", "reptile": "H\u00fcll\u0151k", "primate": "F\u0151eml\u0151s\u00f6k", "rodent": "R\u00e1gcs\u00e1l\u00f3k", "insect": "Rovarok", "bird": "Madarak" },
    "en-AU": { "all": "All", "beast": "Beasts", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rodents", "insect": "Insects", "bird": "Birds" },
    "en-CA": { "all": "All", "beast": "Beasts", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rodents", "insect": "Insects", "bird": "Birds" },
    "en-GB": { "all": "All", "beast": "Beasts", "reptile": "Reptiles", "primate": "Primates", "rodent": "Rodents", "insect": "Insects", "bird": "Birds" },
  };
  return texts[locale] ?? texts["en-US"]!;
}

