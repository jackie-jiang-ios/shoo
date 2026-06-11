import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/animal.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/storage/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

/// 当前选中动物 Provider
final currentAnimalProvider = StateProvider<Animal?>((ref) => null);

/// 播放状态 Provider
final isPlayingProvider = StateProvider<bool>((ref) => false);

/// 当前分类 Provider
final activeCategoryProvider = StateProvider<String>((ref) => 'all');

/// 图标主题 Provider
final iconThemeProvider = StateProvider<String>((ref) => prefs.iconTheme);

/// 首页 - 按照设计稿：智能推荐 + 动物分类列表 + 底部播放控制
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  StreamSubscription? _audioSub;

  @override
  void initState() {
    super.initState();
    // 监听 AudioController 播放状态变化，同步到 Provider
    final audio = AudioController.instance;
    // 使用定时器轮询音频状态（简单方案）
    _audioSub = Stream.periodic(const Duration(milliseconds: 300)).listen((_) {
      if (mounted) {
        final playing = audio.isPlaying;
        if (ref.read(isPlayingProvider) != playing) {
          ref.read(isPlayingProvider.notifier).state = playing;
        }
      }
    });
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final activeCategory = ref.watch(activeCategoryProvider);
    final currentAnimal = ref.watch(currentAnimalProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    final filteredAnimals = activeCategory == 'all'
        ? AnimalDatabase.animals
        : AnimalDatabase.animals.where((a) => a.category.id == activeCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _NavBar()),
              SliverToBoxAdapter(child: _SmartBanner(s: s)),
              SliverToBoxAdapter(child: _CategoryTabs(s: s)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AnimalCard(animal: filteredAnimals[index]),
                    childCount: filteredAnimals.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomPlayer(animal: currentAnimal, isPlaying: isPlaying, s: s),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.pets, color: Colors.orange, size: 24),
          const SizedBox(width: 8),
          Text(s.appName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
        ],
      ),
    );
  }
}

class _SmartBanner extends StatelessWidget {
  final S s;
  const _SmartBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF44336)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.smartRecommend, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 2),
              Text(s.smartRecommendHint, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
            ],
          )),
        ],
      ),
    );
  }
}

class _CategoryTabs extends ConsumerWidget {
  final S s;
  const _CategoryTabs({required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);
    final tabs = [
      ('all', s.allCategories), ('beast', s.beastCategory), ('reptile', s.reptileCategory),
      ('primate', s.primateCategory), ('rodent', s.rodentCategory), ('insect', s.insectCategory), ('bird', s.birdCategory),
    ];
    // 设计稿: rounded-full 药丸形, px-4 py-2 text-sm font-medium
    // 选中: bg-orange-500 text-white, 未选中: bg-white text-gray-600
    return Container(
      height: 36, // py-2(8*2) + text-sm lineHeight(20) = 36px
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, name) = tabs[index];
          final isActive = activeCategory == id;
          return GestureDetector(
            onTap: () => ref.read(activeCategoryProvider.notifier).state = id,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF97316) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF4B5563), // gray-600
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14, // text-sm
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimalCard extends ConsumerWidget {
  final Animal animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final isZh = s.isZh;
    final name = isZh ? animal.name : animal.nameEn;
    final desc = isZh ? animal.description : animal.descriptionEn;
    final counter = isZh ? animal.counterSound : animal.counterSoundEn;
    final catColor = _catColor(animal.category);
    final themeId = prefs.getAnimalIconTheme(animal.id);
    final imagePath = animal.getIconPath(themeId);
    final hasMultipleThemes = animal.availableThemes.length > 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDetail(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // 动物图片 + 主题切换按钮
              GestureDetector(
                onTap: hasMultipleThemes ? () => _cycleTheme(ref, themeId) : null,
                child: Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 56, height: 56,
                        decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_animalIcon(animal.iconName), color: catColor, size: 28)))),
                  // 多主题切换角标
                  if (hasMultipleThemes)
                    Positioned(right: 0, bottom: 0,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.refresh, size: 11, color: Colors.white),
                      )),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // font-semibold text-gray-800 → #1F2937
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                // text-sm text-gray-600 → #4B5563
                Text(desc, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                const SizedBox(height: 6),
                Row(children: [
                  // bg-green-100 text-green-700 → bg: #DCFCE7, text: #15803D
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                    child: Text(s.counterSound, style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 6),
                  // text-xs text-gray-500 → #6B7280
                  Text(counter, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ]),
              ])),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ]),
          ),
        ),
      ),
    );
  }

  /// 循环切换该动物的图标主题
  void _cycleTheme(WidgetRef ref, String currentThemeId) {
    final available = animal.availableThemes;
    final currentIndex = available.indexWhere((t) => t.id == currentThemeId);
    final nextIndex = (currentIndex + 1) % available.length;
    final nextThemeId = available[nextIndex].id;
    prefs.setAnimalIconTheme(animal.id, nextThemeId);
    // 同时更新全局主题以触发 UI 刷新
    ref.read(iconThemeProvider.notifier).state = nextThemeId;
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, controller) => _AnimalDetailSheet(animal: animal, scrollController: controller),
      ));
  }
}

class _AnimalDetailSheet extends ConsumerStatefulWidget {
  final Animal animal;
  final ScrollController scrollController;
  const _AnimalDetailSheet({required this.animal, required this.scrollController});

  @override
  ConsumerState<_AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends ConsumerState<_AnimalDetailSheet> {
  late String _selectedIconTheme;
  late int _selectedSoundIndex;
  late Map<String, SoundPlayMode> _soundPlayModes;
  late Map<String, int> _soundSelectedIndices;

  @override
  void initState() {
    super.initState();
    // 从持久化存储中恢复偏好
    _selectedIconTheme = prefs.getAnimalIconTheme(widget.animal.id);
    _selectedSoundIndex = prefs.getAnimalSelectedSoundIndex(widget.animal.id);

    // 恢复每个声音组的播放模式和选中索引
    _soundPlayModes = {};
    _soundSelectedIndices = {};
    for (final sound in widget.animal.sounds) {
      final modeStr = prefs.getAnimalSoundPlayMode(widget.animal.id, sound.soundGroup);
      _soundPlayModes[sound.soundGroup] = modeStr == 'sequence' ? SoundPlayMode.sequence : SoundPlayMode.single;
      _soundSelectedIndices[sound.soundGroup] = prefs.getAnimalSoundSelectedIndex(widget.animal.id, sound.soundGroup);

      // 同步到 RecommendedSound 对象
      sound.playMode = _soundPlayModes[sound.soundGroup] ?? sound.playMode;
      sound.selectedSoundIndex = _soundSelectedIndices[sound.soundGroup] ?? sound.selectedSoundIndex;
    }
  }

  void _onIconThemeChanged(String themeId) {
    setState(() => _selectedIconTheme = themeId);
    prefs.setAnimalIconTheme(widget.animal.id, themeId);
  }

  void _onSelectedSoundIndexChanged(int index) {
    setState(() => _selectedSoundIndex = index);
    prefs.setAnimalSelectedSoundIndex(widget.animal.id, index);
  }

  void _onSoundPlayModeChanged(String soundGroup, SoundPlayMode mode) {
    setState(() => _soundPlayModes[soundGroup] = mode);
    prefs.setAnimalSoundPlayMode(widget.animal.id, soundGroup, mode.id);
    // 同步到 RecommendedSound 对象
    final sound = widget.animal.sounds.firstWhere((s) => s.soundGroup == soundGroup);
    sound.playMode = mode;
  }

  void _onSoundSelectedIndexChanged(String soundGroup, int index) {
    setState(() => _soundSelectedIndices[soundGroup] = index);
    prefs.setAnimalSoundSelectedIndex(widget.animal.id, soundGroup, index);
    // 同步到 RecommendedSound 对象
    final sound = widget.animal.sounds.firstWhere((s) => s.soundGroup == soundGroup);
    sound.selectedSoundIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isZh = s.isZh;
    final animal = widget.animal;
    final name = isZh ? animal.name : animal.nameEn;
    final fullDesc = isZh ? animal.fullDescription : animal.fullDescriptionEn;
    final catColor = _catColor(animal.category);
    final imagePath = animal.getIconPath(_selectedIconTheme);
    final availableThemes = animal.availableThemes;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
          // 标题栏
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text('$name ${s.detail}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ])),

          // ============ 图标 + 描述 + 图标点击切换 ============
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 图标 + 主题切换
            Column(children: [
              GestureDetector(
                onTap: availableThemes.length > 1 ? () {
                  final currentIndex = availableThemes.indexWhere((t) => t.id == _selectedIconTheme);
                  final nextIndex = (currentIndex + 1) % availableThemes.length;
                  _onIconThemeChanged(availableThemes[nextIndex].id);
                } : null,
                child: Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath, width: 64, height: 64, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 64, height: 64,
                        decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_animalIcon(animal.iconName), size: 28, color: catColor)))),
                  // 多主题切换角标
                  if (availableThemes.length > 1)
                    Positioned(right: 0, bottom: 0,
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.refresh, size: 12, color: Colors.white),
                      )),
                ]),
              ),
              // 当前主题名称
              const SizedBox(height: 4),
              Text(_selectedIconTheme.toUpperCase(),
                style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(width: 10),
            Expanded(child: Text(fullDesc, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)),
          ])),

          // ============ 图标主题选择器 ============
          if (availableThemes.length > 1) ...[
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isZh ? '图标风格' : 'Icon Style', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: availableThemes.map((theme) {
                  final isSelected = _selectedIconTheme == theme.id;
                  final themeImagePath = animal.getIconPath(theme.id);
                  return GestureDetector(
                    onTap: () => _onIconThemeChanged(theme.id),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? catColor : Colors.grey.withValues(alpha: 0.2),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8),
                          child: Image.asset(themeImagePath, width: 48, height: 48, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 48, height: 48,
                              decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Icon(_animalIcon(animal.iconName), size: 24, color: catColor)))),
                        const SizedBox(height: 2),
                        Text(isZh ? theme.name : theme.nameEn,
                          style: TextStyle(fontSize: 10, color: isSelected ? catColor : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                      ]),
                    ),
                  );
                }).toList()),
              ])),
          ],

          const SizedBox(height: 16),

          // ============ 推荐声音列表 ============
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text(s.recommendedSounds, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)))),
          const SizedBox(height: 6),
          ...animal.sounds.asMap().entries.map((entry) {
            final idx = entry.key;
            final sound = entry.value;
            final soundName = isZh ? sound.name : sound.nameEn;
            final isSelected = idx == _selectedSoundIndex;
            return _buildSoundCard(idx, sound, soundName, isSelected, catColor, isZh, s);
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 构建声音卡片（含组内声音选择）
  Widget _buildSoundCard(int idx, RecommendedSound sound, String soundName, bool isSelected, Color catColor, bool isZh, S s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? catColor.withValues(alpha: 0.06) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: catColor.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：声音名称 + 评分 + 播放按钮
            Row(children: [
              GestureDetector(
                onTap: () => _onSelectedSoundIndexChanged(idx),
                child: Row(children: [
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? catColor : Colors.grey, size: 20),
                  const SizedBox(width: 6),
                  Text(soundName, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ),
              const Spacer(),
              Row(children: List.generate(5, (i) => Icon(i < sound.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14))),
              const SizedBox(width: 8),
              SizedBox(height: 32, child: FilledButton(
                onPressed: () {
                  // 播放前确保使用已保存的声音偏好
                  final currentMode = _soundPlayModes[sound.soundGroup] ?? sound.playMode;
                  sound.playMode = currentMode;
                  final currentIndex = _soundSelectedIndices[sound.soundGroup] ?? sound.selectedSoundIndex;
                  sound.selectedSoundIndex = currentIndex;
                  AudioController.instance.play(widget.animal, sound);
                  ref.read(currentAnimalProvider.notifier).state = widget.animal;
                  ref.read(isPlayingProvider.notifier).state = true;
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(backgroundColor: catColor, padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: Text(s.play, style: const TextStyle(fontSize: 13)),
              )),
            ]),

            // 第二行：组内声音选择（当声音组有多首时显示）
            if (sound.soundCount > 1) ...[
              const SizedBox(height: 10),
              _buildSoundGroupSelector(sound, catColor, isZh),
            ],
          ],
        ),
      ),
    );
  }

  /// 组内声音选择器
  Widget _buildSoundGroupSelector(RecommendedSound sound, Color catColor, bool isZh) {
    final currentPlayMode = _soundPlayModes[sound.soundGroup] ?? sound.playMode;
    final currentSelectedIndex = _soundSelectedIndices[sound.soundGroup] ?? sound.selectedSoundIndex;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 播放模式切换
          Row(children: [
            Text(isZh ? '播放模式' : 'Mode', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _onSoundPlayModeChanged(sound.soundGroup, SoundPlayMode.single),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentPlayMode == SoundPlayMode.single ? catColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: currentPlayMode == SoundPlayMode.single ? catColor : Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.looks_one, size: 14, color: currentPlayMode == SoundPlayMode.single ? catColor : AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(isZh ? '单个' : 'Single',
                    style: TextStyle(fontSize: 11, color: currentPlayMode == SoundPlayMode.single ? catColor : AppColors.textSecondary,
                      fontWeight: currentPlayMode == SoundPlayMode.single ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _onSoundPlayModeChanged(sound.soundGroup, SoundPlayMode.sequence),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentPlayMode == SoundPlayMode.sequence ? catColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: currentPlayMode == SoundPlayMode.sequence ? catColor : Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.playlist_play, size: 14, color: currentPlayMode == SoundPlayMode.sequence ? catColor : AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(isZh ? '连续' : 'Seq.',
                    style: TextStyle(fontSize: 11, color: currentPlayMode == SoundPlayMode.sequence ? catColor : AppColors.textSecondary,
                      fontWeight: currentPlayMode == SoundPlayMode.sequence ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ),
            ),
          ]),

          // 单个模式下，选择具体哪一首声音
          if (currentPlayMode == SoundPlayMode.single && sound.soundCount > 1) ...[
            const SizedBox(height: 8),
            Row(children: [
              Text(isZh ? '选择声音' : 'Select', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              ...List.generate(sound.soundCount, (index) {
                final isSel = currentSelectedIndex == index;
                return GestureDetector(
                  onTap: () => _onSoundSelectedIndexChanged(sound.soundGroup, index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSel ? catColor.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSel ? catColor : Colors.grey.withValues(alpha: 0.15), width: isSel ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(isSel ? Icons.music_note : Icons.music_note_outlined, size: 13,
                        color: isSel ? catColor : AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text('#${index + 1}',
                        style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                          color: isSel ? catColor : AppColors.textSecondary)),
                    ]),
                  ),
                );
              }),
            ]),
          ],

          // 连续模式提示
          if (currentPlayMode == SoundPlayMode.sequence)
            Padding(padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                Icon(Icons.info_outline, size: 12, color: catColor.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Expanded(child: Text(
                  isZh ? '依次播放 ${sound.soundCount} 首声音' : 'Plays all ${sound.soundCount} sounds in order',
                  style: TextStyle(fontSize: 11, color: catColor.withValues(alpha: 0.7)),
                )),
              ])),
        ],
      ),
    );
  }
}

class _BottomPlayer extends ConsumerWidget {
  final Animal? animal;
  final bool isPlaying;
  final S s;
  const _BottomPlayer({required this.animal, required this.isPlaying, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZh = s.isZh;
    final name = animal != null ? (isZh ? animal!.name : animal!.nameEn) : s.appName;
    final counter = animal != null ? (isZh ? animal!.counterSound : animal!.counterSoundEn) : s.noSoundPlaying;
    final themeId = animal != null ? prefs.getAnimalIconTheme(animal!.id) : prefs.iconTheme;
    final imagePath = animal?.getIconPath(themeId);
    final fallbackIcon = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.volume_up_rounded, color: Colors.orange, size: 24),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12),
          child: animal != null && imagePath != null
            ? Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallbackIcon)
            : fallbackIcon),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 2),
          Text(counter, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ])),
        GestureDetector(
          onTap: () {
            final audio = AudioController.instance;
            if (audio.isPlaying) {
              audio.pause();
            } else {
              audio.resume();
            }
            ref.read(isPlayingProvider.notifier).state = !isPlaying;
          },
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isPlaying ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: (isPlaying ? Colors.red : Colors.orange).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
          ),
        ),
      ]),
    );
  }
}

// ============ 工具方法 ============

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
