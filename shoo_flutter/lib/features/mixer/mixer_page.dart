import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/animal.dart';
import '../../theme/colors.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_page.dart'; // iconThemeProvider

/// 混合声音项
class MixSoundItem {
  final RecommendedSound sound;
  final String animalName;
  double volume;
  bool isPlaying;

  MixSoundItem({
    required this.sound,
    required this.animalName,
    this.volume = 0.8,
    this.isPlaying = false,
  });
}

/// 多声音混合页面
class MixerPage extends ConsumerStatefulWidget {
  const MixerPage({super.key});

  @override
  ConsumerState<MixerPage> createState() => _MixerPageState();
}

class _MixerPageState extends ConsumerState<MixerPage> {
  final List<MixSoundItem> _mixItems = [];

  void _addSound(RecommendedSound sound, String animalName) {
    if (_mixItems.any((item) => item.sound.soundId == sound.soundId)) return;
    setState(() {
      _mixItems.add(MixSoundItem(sound: sound, animalName: animalName));
    });
  }

  void _removeSound(int index) {
    setState(() => _mixItems.removeAt(index));
  }

  bool get _isAnyPlaying => _mixItems.any((item) => item.isPlaying);

  void _toggleMix() {
    final playing = !_isAnyPlaying;
    for (final item in _mixItems) {
      item.isPlaying = playing;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.soundMix), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showSoundPicker()),
      ]),
      body: _mixItems.isEmpty ? _buildEmptyState(theme, s) : _buildMixContent(theme, s),
      bottomNavigationBar: _mixItems.isEmpty ? null : _buildBottomBar(s),
    );
  }

  Widget _buildEmptyState(ThemeData theme, S s) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.merge_type, size: 80, color: AppColors.textHintOf(context)),
      const SizedBox(height: 16),
      Text(s.addSound, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryOf(context))),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: _showSoundPicker, icon: const Icon(Icons.add), label: Text(s.addSound)),
    ]));
  }

  Widget _buildMixContent(ThemeData theme, S s) {
    return Column(children: [
      Container(
        height: 140, margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.of(context)]), borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${_mixItems.length} ${s.soundMix}', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_mixItems.map((i) => i.sound.getLocalizedName(Localizations.localeOf(context).languageCode)).join(' + '),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _mixItems.length,
        itemBuilder: (context, index) {
          final item = _mixItems[index];
          final soundName = item.sound.getLocalizedName(Localizations.localeOf(context).languageCode);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              Row(children: [
                Expanded(child: Text(soundName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
                Text(item.animalName, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryOf(context))),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _removeSound(index), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ]),
              Row(children: [
                Icon(Icons.volume_down, size: 16, color: AppColors.textSecondaryOf(context)),
                Expanded(child: Slider(value: item.volume, onChanged: (v) => setState(() => item.volume = v))),
                Icon(Icons.volume_up, size: 16, color: AppColors.textSecondaryOf(context)),
                SizedBox(width: 40, child: Text('${(item.volume * 100).round()}%', style: theme.textTheme.bodySmall, textAlign: TextAlign.right)),
              ]),
            ])),
          );
        },
      )),
    ]);
  }

  Widget _buildBottomBar(S s) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16),
      child: FilledButton.icon(
        onPressed: _toggleMix,
        icon: Icon(_isAnyPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
        label: Text(_isAnyPlaying ? s.stopMix : s.startMix),
        style: FilledButton.styleFrom(
          backgroundColor: _isAnyPlaying ? AppColors.dangerOf(context) : AppColors.of(context),
          padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    ));
  }

  void _showSoundPicker() {
    final s = S.of(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    showModalBottomSheet(context: context, isScrollControlled: true,
      constraints: isTablet ? BoxConstraints(maxWidth: MediaQuery.of(context).size.width) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.3, expand: false,
        builder: (context, scrollController) {
          return Column(children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.dividerOf(context), borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [Text(s.addSound, style: Theme.of(context).textTheme.titleLarge), const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: Text(s.done))])),
            Expanded(child: ListView.builder(
              controller: scrollController,
              itemCount: AnimalDatabase.animals.length,
              itemBuilder: (context, index) {
                final animal = AnimalDatabase.animals[index];
                final animalName = animal.getLocalizedName(Localizations.localeOf(context).languageCode);
                final themeId = ref.watch(iconThemeProvider);
                return ExpansionTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.asset(animal.getIconPath(themeId), width: 24, height: 24, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(_animalIcon(animal.iconName), color: _catColor(animal.category)))),
                  title: Text(animalName),
                  subtitle: Text(animal.getLocalizedDescription(Localizations.localeOf(context).languageCode), style: const TextStyle(fontSize: 12)),
                  children: animal.sounds.map((sound) {
                    final isAdded = _mixItems.any((i) => i.sound.soundId == sound.soundId);
                    final soundName = sound.getLocalizedName(Localizations.localeOf(context).languageCode);
                    return ListTile(
                      title: Text(soundName),
                      trailing: isAdded
                        ? Icon(Icons.check_circle, color: AppColors.successOf(context))
                        : const Icon(Icons.add_circle_outline),
                      onTap: isAdded ? null : () {
                        _addSound(sound, animalName);
                        setState(() {});
                      },
                    );
                  }).toList(),
                );
              },
            )),
          ]);
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
