import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/animal.dart';
import '../../theme/colors.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_page.dart'; // iconThemeProvider

/// 声音库页面 - 按动物分类浏览所有驱赶声音
class SoundLibraryPage extends ConsumerWidget {
  final String? categoryFilter;

  const SoundLibraryPage({super.key, this.categoryFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final animals = AnimalDatabase.animals;
    final themeId = ref.watch(iconThemeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.soundLibrary)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: animals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final animal = animals[index];
          final catColor = _catColor(animal.category);
          final animalName = s.isZh ? animal.name : animal.nameEn;
          final desc = s.isZh ? animal.description : animal.descriptionEn;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.asset(animal.getIconPath(themeId), width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 48, height: 48,
                        decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_animalIcon(animal.iconName), color: catColor, size: 24)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(animalName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ])),
                ]),
                const SizedBox(height: 8),
                ...animal.sounds.map((sound) {
                  final soundName = s.isZh ? sound.name : sound.nameEn;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Expanded(child: Text(soundName, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
                      Row(children: List.generate(5, (i) => Icon(i < sound.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14))),
                    ]),
                  );
                }),
              ]),
            ),
          );
        },
      ),
    );
  }
}

Color _catColor(AnimalCategory cat) {
  switch (cat) {
    case AnimalCategory.beast: return Colors.orange;
    case AnimalCategory.reptile: return Colors.green;
    case AnimalCategory.primate: return Colors.brown;
    case AnimalCategory.rodent: return Colors.blueGrey;
    case AnimalCategory.insect: return Colors.purple;
    case AnimalCategory.bird: return Colors.blue;
    case AnimalCategory.all: return Colors.orange;
  }
}

IconData _animalIcon(String name) {
  const map = {
    'pets': Icons.pets, 'dangerous': Icons.dangerous, 'forest': Icons.forest,
    'cottage': Icons.cottage, 'emoji_nature': Icons.emoji_nature, 'pest_control': Icons.pest_control,
    'nights_stay': Icons.nights_stay, 'bug_report': Icons.bug_report, 'hive': Icons.hive,
    'grass': Icons.grass, 'flutter_dash': Icons.flutter_dash,
  };
  return map[name] ?? Icons.pets;
}
