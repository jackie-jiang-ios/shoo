// Shoo video test - multi-language App Store preview video
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/main.dart" as app;

String get targetLang =>
    const String.fromEnvironment("LANG", defaultValue: "en-US");

String get videoDir =>
    const String.fromEnvironment("OUTPUT_DIR", defaultValue: "fastlane/screenshots") +
    "/$targetLang";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Shoo Video - $targetLang", () {
    testWidgets("Record preview video", (tester) async {
      // Set language
      SharedPreferences.setMockInitialValues({
        "language": _getLangCode(targetLang),
        "theme_mode": "light",
      });
      // Launch the real app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

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
  const map = {"zh-Hans":"zh","zh-Hant":"zh_TW","en-US":"en","ja":"ja","ko":"ko","fr-FR":"fr","de-DE":"de","es-ES":"es","ru":"ru","pt-BR":"pt","th":"th"};
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
  };
  return texts[locale] ?? texts["en-US"]!;
}

