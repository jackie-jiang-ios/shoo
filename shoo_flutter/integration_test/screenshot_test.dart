// Shoo screenshot test
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shoo/main.dart" as app;

String get targetLang => const String.fromEnvironment("LANG", defaultValue: "en-US");
String get screenshotDir => const String.fromEnvironment("OUTPUT_DIR", defaultValue: "fastlane/screenshots") + "/$targetLang";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("Shoo Screenshots - $targetLang", () {
    testWidgets("01 Home", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); await _takeScreenshot(tester, "01_Home_All"); });
    testWidgets("02 Beast", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); await _tapCategory(tester, "beast"); await tester.pumpAndSettle(); await _takeScreenshot(tester, "02_Home_Beast"); });
    testWidgets("03 Reptile", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); await _tapCategory(tester, "reptile"); await tester.pumpAndSettle(); await _takeScreenshot(tester, "03_Home_Reptile"); });
    testWidgets("04 Primate", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); await _tapCategory(tester, "primate"); await tester.pumpAndSettle(); await _takeScreenshot(tester, "04_Home_Primate"); });
    testWidgets("05 Detail", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); await _tapFirstAnimalCard(tester); await tester.pumpAndSettle(const Duration(seconds: 1)); await _takeScreenshot(tester, "05_AnimalDetail"); });
    testWidgets("06 Settings", (tester) async { await _launchApp(tester); await tester.pumpAndSettle(const Duration(seconds: 2)); final b = find.byIcon(Icons.settings); if (b.evaluate().isNotEmpty) { await tester.tap(b); await tester.pumpAndSettle(const Duration(seconds: 1)); } await _takeScreenshot(tester, "06_Settings"); });
  });
}
Future<void> _launchApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({"language": _getLangCode(targetLang), "theme_mode": "light"});
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 5));
}
Future<void> _tapCategory(WidgetTester tester, String categoryId) async {
  final texts = _getCategoryTexts(targetLang);
  final text = texts[categoryId];
  if (text != null) {
    final f = find.text(text);
    if (f.evaluate().isNotEmpty) { await tester.tap(f.first); await tester.pumpAndSettle(); }
  }
}
Future<void> _tapFirstAnimalCard(WidgetTester tester) async {
  final cards = find.byType(GestureDetector);
  if (cards.evaluate().isNotEmpty) { await tester.tap(cards.first); await tester.pumpAndSettle(); }
}
Future<void> _takeScreenshot(WidgetTester tester, String name) async {
  final dir = Directory(screenshotDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  await binding.takeScreenshot("$screenshotDir/$name.png");
  await tester.pump(const Duration(milliseconds: 500));
}
IntegrationTestWidgetsFlutterBinding get binding => IntegrationTestWidgetsFlutterBinding.instance as IntegrationTestWidgetsFlutterBinding;
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

