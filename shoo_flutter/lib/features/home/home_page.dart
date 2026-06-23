import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../models/animal.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/platform/native_logger.dart';
import '../../core/storage/preferences.dart';
import '../sounds/widgets/audio_file_waveform_list.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

/// 当前选中动物 Provider
final currentAnimalProvider = StateProvider<Animal?>((ref) => null);

/// 当前播放声音组 Provider（用于驱动底部播放栏文案更新）
final currentSoundGroupProvider = StateProvider<String?>((ref) => null);

/// 播放状态 Provider
final isPlayingProvider = StateProvider<bool>((ref) => false);

/// 当前分类 Provider
final activeCategoryProvider = StateProvider<String>((ref) => 'all');

/// 图标主题 Provider
final iconThemeProvider = StateProvider<String>((ref) => prefs.iconTheme);

/// 系统音量 Provider
final systemVolumeProvider = StateProvider<double>((ref) => 1.0);

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
    _audioSub = Stream.periodic(const Duration(milliseconds: 200)).listen((_) {
      if (mounted) {
        final playing = audio.isPlaying;
        if (ref.read(isPlayingProvider) != playing) {
          ref.read(isPlayingProvider.notifier).state = playing;
        }
        final animal = audio.currentAnimal;
        if (ref.read(currentAnimalProvider) != animal) {
          ref.read(currentAnimalProvider.notifier).state = animal;
        }
        final soundGroup = audio.currentSound?.soundGroup;
        if (ref.read(currentSoundGroupProvider) != soundGroup) {
          ref.read(currentSoundGroupProvider.notifier).state = soundGroup;
        }
      }
    });

    // 监听系统音量变化，同步到 UI
    audio.onSystemVolumeChanged = (volume) {
      if (mounted) {
        ref.read(systemVolumeProvider.notifier).state = volume;
      }
    };
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    AudioController.instance.onSystemVolumeChanged = null;
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
        : AnimalDatabase.animals
            .where((a) => a.category.id == activeCategory)
            .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.background : const Color(0xFFF0F7FF),
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
                    (context, index) =>
                        _AnimalCard(animal: filteredAnimals[index]),
                    childCount: filteredAnimals.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPlayer(
                animal: currentAnimal, isPlaying: isPlaying, s: s),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          Icon(Icons.pets,
              color: isDark ? AppColorsDark.primary : Colors.orange, size: 24),
          const SizedBox(width: 8),
          Text(s.appName,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColorsDark.textPrimary : Colors.black)),
          const Spacer(),
          IconButton(
              icon: Icon(Icons.settings,
                  color: isDark ? AppColorsDark.textSecondary : null),
              onPressed: () => context.push('/settings')),
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
        gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFF44336)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.smartRecommend,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 2),
              Text(s.smartRecommendHint,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      ('all', s.allCategories),
      ('beast', s.beastCategory),
      ('reptile', s.reptileCategory),
      ('primate', s.primateCategory),
      ('rodent', s.rodentCategory),
      ('insect', s.insectCategory),
      ('bird', s.birdCategory),
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
                color: isActive
                    ? const Color(0xFFF97316)
                    : (isDark ? AppColorsDark.cardBackground : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFFF97316).withValues(alpha: 0.35),
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
                    color: isActive
                        ? Colors.white
                        : (isDark
                            ? AppColorsDark.textSecondary
                            : const Color(0xFF4B5563)), // gray-600
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
    final langCode = Localizations.localeOf(context).languageCode;
    final name = animal.getLocalizedName(langCode);
    final desc = animal.getLocalizedDescription(langCode);
    final counter = animal.getLocalizedCounterSound(langCode);
    final catColor = _catColor(animal.category);
    // watch 以监听任何动物图标主题变化，触发 rebuild
    ref.watch(iconThemeProvider);
    final themeId = prefs.getAnimalIconTheme(animal.id);
    final imagePath = animal.getIconPath(themeId);
    final hasMultipleThemes = animal.availableThemes.length > 1;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.02 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
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
                onTap:
                    hasMultipleThemes ? () => _cycleTheme(ref, themeId) : null,
                child: Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(imagePath,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(_animalIcon(animal.iconName),
                                  color: catColor, size: 28)))),
                  // 多主题切换角标
                  if (hasMultipleThemes)
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isDark
                                    ? AppColorsDark.cardBackground
                                    : Colors.white,
                                width: 1.5),
                          ),
                          child: const Icon(Icons.refresh,
                              size: 11, color: Colors.white),
                        )),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // font-semibold text-gray-800 → #1F2937
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : const Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    // text-sm text-gray-600 → #4B5563
                    Text(desc,
                        style: TextStyle(
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : const Color(0xFF4B5563),
                            fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(children: [
                      // bg-green-100 text-green-700 → bg: #DCFCE7, text: #15803D
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(s.counterSound,
                              style: TextStyle(
                                  color: isDark
                                      ? AppColorsDark.success
                                      : const Color(0xFF15803D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500))),
                      const SizedBox(width: 6),
                      // text-xs text-gray-500 → #6B7280
                      Text(counter,
                          style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : const Color(0xFF6B7280),
                              fontSize: 12)),
                    ]),
                  ])),
              Icon(Icons.chevron_right,
                  color: isDark ? AppColorsDark.textHint : Colors.grey[400]),
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: isTablet
            ? BoxConstraints(maxWidth: MediaQuery.of(context).size.width)
            : null,
        builder: (ctx) => DraggableScrollableSheet(
              initialChildSize: 0.94,
              minChildSize: 0.72,
              maxChildSize: 0.98,
              builder: (_, controller) => _AnimalDetailSheet(
                  animal: animal, scrollController: controller),
            ));
  }
}

class _AnimalDetailSheet extends ConsumerStatefulWidget {
  final Animal animal;
  final ScrollController scrollController;
  const _AnimalDetailSheet(
      {required this.animal, required this.scrollController});

  @override
  ConsumerState<_AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends ConsumerState<_AnimalDetailSheet> {
  late String _selectedIconTheme;
  late int _selectedSoundIndex;
  late Map<String, SoundPlayMode> _soundPlayModes;
  late Map<String, int> _soundSelectedIndices;
  late Map<String, Set<int>> _soundMultiSelectedIndices;
  Timer? _playbackProgressTimer;
  String? _currentPlayingAssetPath;
  double _playbackProgress = 0;
  bool _isApplyingModeChange = false;

  @override
  void initState() {
    super.initState();
    // 从持久化存储中恢复偏好
    _selectedIconTheme = prefs.getAnimalIconTheme(widget.animal.id);
    _selectedSoundIndex = prefs.getAnimalSelectedSoundIndex(widget.animal.id);

    // 恢复每个声音组的播放模式和选中索引
    _soundPlayModes = {};
    _soundSelectedIndices = {};
    _soundMultiSelectedIndices = {};
    for (final sound in widget.animal.sounds) {
      final modeStr =
          prefs.getAnimalSoundPlayMode(widget.animal.id, sound.soundGroup);
      _soundPlayModes[sound.soundGroup] =
          modeStr == 'sequence' ? SoundPlayMode.sequence : SoundPlayMode.single;
      _soundSelectedIndices[sound.soundGroup] =
          prefs.getAnimalSoundSelectedIndex(widget.animal.id, sound.soundGroup);
      _soundMultiSelectedIndices[sound.soundGroup] =
          prefs.getAnimalSoundMultiSelectedIndices(
              widget.animal.id, sound.soundGroup);

      // 同步到 RecommendedSound 对象
      sound.playMode = _soundPlayModes[sound.soundGroup] ?? sound.playMode;
      sound.selectedSoundIndex =
          _soundSelectedIndices[sound.soundGroup] ?? sound.selectedSoundIndex;
      sound.selectedIndices =
          _soundMultiSelectedIndices[sound.soundGroup] ?? sound.selectedIndices;
    }

    _playbackProgressTimer = Timer.periodic(
      const Duration(milliseconds: 140),
      (_) => _syncPlaybackProgress(),
    );
  }

  @override
  void dispose() {
    _playbackProgressTimer?.cancel();
    super.dispose();
  }

  void _onIconThemeChanged(String themeId) {
    setState(() => _selectedIconTheme = themeId);
    prefs.setAnimalIconTheme(widget.animal.id, themeId);
    // 更新全局主题以触发首页图标 UI 刷新
    ref.read(iconThemeProvider.notifier).state = themeId;
  }

  void _onSelectedSoundIndexChanged(int index) {
    setState(() => _selectedSoundIndex = index);
    prefs.setAnimalSelectedSoundIndex(widget.animal.id, index);
  }

  Future<void> _onSoundPlayModeChanged(
      String soundGroup, SoundPlayMode mode) async {
    // 守卫防止 _playSoundSelection → _onSoundPlayModeChanged 递归
    if (_isApplyingModeChange) return;
    setState(() => _soundPlayModes[soundGroup] = mode);
    prefs.setAnimalSoundPlayMode(widget.animal.id, soundGroup, mode.id);
    // 同步到 RecommendedSound 对象
    final sound =
        widget.animal.sounds.firstWhere((s) => s.soundGroup == soundGroup);
    sound.playMode = mode;

    // 切换到列表循环模式时，将当前单曲选中的文件索引同步到多选集合
    if (mode == SoundPlayMode.sequence) {
      final singleSelected =
          _soundSelectedIndices[soundGroup] ?? sound.selectedSoundIndex;
      final currentMulti = Set<int>.from(
          _soundMultiSelectedIndices[soundGroup] ?? {singleSelected});
      // 确保当前选中的文件在多选集合中
      if (!currentMulti.contains(singleSelected)) {
        currentMulti.add(singleSelected);
      }
      setState(() => _soundMultiSelectedIndices[soundGroup] = currentMulti);
      prefs.setAnimalSoundMultiSelectedIndices(
          widget.animal.id, soundGroup, currentMulti);
      sound.selectedIndices = currentMulti;
    }

    // 切换模式后自动开始播放（无论之前是否在播放）
    _isApplyingModeChange = true;
    try {
      await _playSoundSelection(
        widget.animal.sounds.indexOf(sound),
        sound,
        overridePlayMode: mode,
      );
    } finally {
      _isApplyingModeChange = false;
    }
  }

  void _onSoundSelectedIndexChanged(String soundGroup, int index) {
    setState(() => _soundSelectedIndices[soundGroup] = index);
    prefs.setAnimalSoundSelectedIndex(widget.animal.id, soundGroup, index);
    // 同步到 RecommendedSound 对象
    final sound =
        widget.animal.sounds.firstWhere((s) => s.soundGroup == soundGroup);
    sound.selectedSoundIndex = index;
  }

  /// 多选模式下切换某个声音文件的选中状态
  void _onSoundMultiSelectionToggled(String soundGroup, int index) {
    final current =
        Set<int>.from(_soundMultiSelectedIndices[soundGroup] ?? {0});
    if (current.contains(index)) {
      // 至少保留一个选中
      if (current.length <= 1) return;
      current.remove(index);
    } else {
      current.add(index);
    }
    setState(() => _soundMultiSelectedIndices[soundGroup] = current);
    prefs.setAnimalSoundMultiSelectedIndices(
        widget.animal.id, soundGroup, current);
    // 同步到 RecommendedSound 对象
    final sound =
        widget.animal.sounds.firstWhere((s) => s.soundGroup == soundGroup);
    sound.selectedIndices = current;

    // 防止在模式切换过程中重复触发播放（_onSoundPlayModeChanged 已经会自动播放）
    if (_isApplyingModeChange) return;

    // 切换多选后自动开始播放
    _playSoundSelection(
      widget.animal.sounds.indexOf(sound),
      sound,
      overridePlayMode: SoundPlayMode.sequence,
    );
  }

  Future<void> _playSoundSelection(
    int soundCardIndex,
    RecommendedSound sound, {
    int? fileIndex,
    SoundPlayMode? overridePlayMode,
  }) async {
    final playMode =
        overridePlayMode ?? _soundPlayModes[sound.soundGroup] ?? sound.playMode;
    final selectedFileIndex = fileIndex ??
        _soundSelectedIndices[sound.soundGroup] ??
        sound.selectedSoundIndex;

    final audio = AudioController.instance;
    final targetAssetPath = playMode == SoundPlayMode.sequence
        ? sound.assetPaths.firstOrNull
        : sound.getAssetPath(selectedFileIndex);

    // 判断当前播放的模式是否与新请求的模式一致
    final isSamePlayMode = audio.currentSound?.playMode == playMode;

    // 如果点击的是当前正在播放的同一个声音文件，且播放模式相同，则 toggle 暂停/恢复
    final isSameAnimal = audio.currentAnimal?.id == widget.animal.id;
    final isSameSoundGroup = audio.currentSound?.soundGroup == sound.soundGroup;
    final isSameAssetPath = audio.currentAssetPath == targetAssetPath;
    if (isSameAnimal &&
        isSameSoundGroup &&
        isSameAssetPath &&
        isSamePlayMode &&
        audio.isPlaying) {
      await audio.pause();
      ref.read(isPlayingProvider.notifier).state = false;
      return;
    }
    // 如果暂停状态点击同一声音（且模式相同），则恢复播放
    if (isSameAnimal &&
        isSameSoundGroup &&
        isSameAssetPath &&
        isSamePlayMode &&
        !audio.isPlaying &&
        audio.currentAssetPath != null) {
      await audio.resume();
      ref.read(isPlayingProvider.notifier).state = audio.isPlaying;
      return;
    }

    _onSelectedSoundIndexChanged(soundCardIndex);
    // 仅更新播放模式的状态和持久化，不触发 _onSoundPlayModeChanged
    // 因为 _onSoundPlayModeChanged 在正在播放时会递归调用 _playSoundSelection，
    // 导致重复 _startPlayback（generation 疯狂递增），而本方法已经在下方调用了 audio.play()
    if (_soundPlayModes[sound.soundGroup] != playMode) {
      setState(() => _soundPlayModes[sound.soundGroup] = playMode);
      prefs.setAnimalSoundPlayMode(
          widget.animal.id, sound.soundGroup, playMode.id);
    }
    _onSoundSelectedIndexChanged(sound.soundGroup, selectedFileIndex);

    sound.playMode = playMode;
    sound.selectedSoundIndex = selectedFileIndex;
    setState(() {
      _currentPlayingAssetPath = targetAssetPath;
      _playbackProgress = 0;
    });
    ref.read(currentAnimalProvider.notifier).state = widget.animal;
    ref.read(isPlayingProvider.notifier).state = true;

    // 应用音量始终为 1.0，实际音量由系统音量控制
    // 所有文件统一以满格播放，不再有音量差异
    await audio.playWithVolume(widget.animal, sound, 1.0);
    // 记录上次播放的动物和声音组
    prefs.setLastPlayedAnimalId(widget.animal.id);
    prefs.setLastPlayedSoundGroup(sound.soundGroup);
    ref.read(currentAnimalProvider.notifier).state = audio.currentAnimal;
    ref.read(isPlayingProvider.notifier).state = audio.isPlaying;
    if (!audio.isPlaying) {
      setState(() {
        _currentPlayingAssetPath = null;
        _playbackProgress = 0;
      });
    }
  }

  void _syncPlaybackProgress() {
    if (!mounted) return;

    final audio = AudioController.instance;
    final currentAnimal = audio.currentAnimal;
    final isPlaying = audio.isPlaying;
    if (ref.read(currentAnimalProvider) != currentAnimal) {
      ref.read(currentAnimalProvider.notifier).state = currentAnimal;
    }
    if (ref.read(isPlayingProvider) != isPlaying) {
      ref.read(isPlayingProvider.notifier).state = isPlaying;
    }
    final duration = audio.currentDuration;
    final position = audio.currentPosition;
    final nextAssetPath = audio.currentAssetPath;
    final nextProgress = duration == null || duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    if (_currentPlayingAssetPath == nextAssetPath &&
        (_playbackProgress - nextProgress).abs() < 0.015) {
      return;
    }

    setState(() {
      _currentPlayingAssetPath = nextAssetPath;
      _playbackProgress = nextProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final animal = widget.animal;
    final langCode = Localizations.localeOf(context).languageCode;
    final name = animal.getLocalizedName(langCode);
    final fullDesc = animal.getLocalizedFullDescription(langCode);
    final catColor = _catColor(animal.category);
    final imagePath = animal.getIconPath(_selectedIconTheme);
    final availableThemes = animal.availableThemes;
    final currentAnimal = ref.watch(currentAnimalProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final currentSound = AudioController.instance.currentSound;
    final isCurrentAnimal = currentAnimal?.id == animal.id;
    final playingGroup = isPlaying && currentAnimal?.id == animal.id
        ? currentSound?.soundGroup
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final detailMaxWidth = isTablet
        ? (screenWidth > 960 ? 960.0 : screenWidth - 32)
        : double.infinity;

    return Container(
      decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: detailMaxWidth),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 28),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 标题栏
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Text('$name ${s.detail}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? AppColorsDark.textPrimary : null)),
                      const Spacer(),
                      IconButton(
                          icon: Icon(Icons.close,
                              color:
                                  isDark ? AppColorsDark.textSecondary : null),
                          onPressed: () => Navigator.pop(context)),
                    ])),

                // ============ 图标 + 描述 + 图标点击切换 ============
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 图标 + 主题切换
                          Column(children: [
                            GestureDetector(
                              onTap: availableThemes.length > 1
                                  ? () {
                                      final currentIndex =
                                          availableThemes.indexWhere((t) =>
                                              t.id == _selectedIconTheme);
                                      final nextIndex = (currentIndex + 1) %
                                          availableThemes.length;
                                      _onIconThemeChanged(
                                          availableThemes[nextIndex].id);
                                    }
                                  : null,
                              child: Stack(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(imagePath,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                                color: catColor.withValues(
                                                    alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Icon(
                                                _animalIcon(animal.iconName),
                                                size: 28,
                                                color: catColor)))),
                                // 多主题切换角标
                                if (availableThemes.length > 1)
                                  Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: catColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 1.5),
                                        ),
                                        child: const Icon(Icons.refresh,
                                            size: 12, color: Colors.white),
                                      )),
                              ]),
                            ),
                            // 当前主题名称
                            const SizedBox(height: 4),
                            Text(_selectedIconTheme.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: catColor,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(fullDesc,
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColorsDark.textSecondary
                                          : Colors.grey[600],
                                      fontSize: 12,
                                      height: 1.4),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis)),
                        ])),

                // ============ 图标主题选择器 ============
                if (availableThemes.length > 1) ...[
                  const SizedBox(height: 12),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.iconStyle,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColorsDark.textPrimary
                                        : null)),
                            const SizedBox(height: 8),
                            Row(
                                children: availableThemes.map((theme) {
                              final isSelected = _selectedIconTheme == theme.id;
                              final themeImagePath =
                                  animal.getIconPath(theme.id);
                              return GestureDetector(
                                onTap: () => _onIconThemeChanged(theme.id),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? catColor
                                          : (isDark
                                              ? Colors.grey
                                                  .withValues(alpha: 0.3)
                                              : Colors.grey
                                                  .withValues(alpha: 0.2)),
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: Column(children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(themeImagePath,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            catColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Icon(
                                                        _animalIcon(
                                                            animal.iconName),
                                                        size: 24,
                                                        color: catColor)))),
                                    const SizedBox(height: 2),
                                    Text(
                                        theme.getLocalizedName(
                                            Localizations.localeOf(context)
                                                .languageCode),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected
                                                ? catColor
                                                : AppColors.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal)),
                                  ]),
                                ),
                              );
                            }).toList()),
                          ])),
                ],
                const SizedBox(height: 16),

                // ============ 推荐声音列表 ============
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      s.recommendedSounds,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? AppColorsDark.textPrimary : null),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...animal.sounds.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final sound = entry.value;
                  final soundName = sound.getLocalizedName(
                      Localizations.localeOf(context).languageCode);
                  final isSelected = idx == _selectedSoundIndex;
                  return _buildSoundCard(
                    idx,
                    sound,
                    soundName,
                    isSelected,
                    isCurrentAnimal,
                    playingGroup,
                    catColor,
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建声音卡片（一体化：波形列表即选择器）
  Widget _buildSoundCard(
    int idx,
    RecommendedSound sound,
    String soundName,
    bool isSelected,
    bool isCurrentAnimal,
    String? playingGroup,
    Color catColor,
  ) {
    final s = S.of(context);
    final currentPlayMode = _soundPlayModes[sound.soundGroup] ?? sound.playMode;
    final fileCountLabel =
        sound.soundCount > 1 ? '${sound.soundCount}${s.nFiles}' : s.singleFile;
    final multiSelectedIndices =
        _soundMultiSelectedIndices[sound.soundGroup] ?? sound.selectedIndices;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? catColor.withValues(alpha: 0.06)
              : (isDark
                  ? AppColorsDark.divider.withValues(alpha: 0.3)
                  : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: catColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行：声音名称 + 评分 + 播放按钮
            Row(children: [
              GestureDetector(
                onTap: () => _playSoundSelection(idx, sound),
                child: Row(children: [
                  Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? catColor : Colors.grey,
                      size: 20),
                  const SizedBox(width: 6),
                  Text(soundName,
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isDark ? AppColorsDark.textPrimary : null)),
                ]),
              ),
              const Spacer(),
              Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                          i < sound.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14))),
            ]),
            const SizedBox(height: 10),
            // 信息标签
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                    Icons.multitrack_audio_outlined, fileCountLabel, catColor),
                if (sound.frequencyRange.isNotEmpty)
                  _buildInfoChip(
                      Icons.waves, sound.frequencyRange, Colors.purple),
                _buildInfoChip(
                    Icons.graphic_eq,
                    '${sound.estimatedDb.round()} dB',
                    _dbColor(sound.estimatedDb)),
              ],
            ),
            const SizedBox(height: 10),
            // 一体化波形列表：点击即选择+播放
            AudioFileWaveformList(
              sound: sound,
              accentColor: isSelected
                  ? catColor
                  : Color.lerp(catColor, Colors.grey, 0.35) ?? catColor,
              playMode: currentPlayMode,
              isActiveSoundCard: isSelected,
              selectedFileIndex: _soundSelectedIndices[sound.soundGroup] ??
                  sound.selectedSoundIndex,
              multiSelectedIndices: multiSelectedIndices,
              currentAssetPath:
                  isCurrentAnimal ? _currentPlayingAssetPath : null,
              playbackProgress:
                  playingGroup == sound.soundGroup ? _playbackProgress : 0,
              isPlaybackActive: playingGroup == sound.soundGroup,
              onFileTap: (fileIndex) {
                if (currentPlayMode == SoundPlayMode.single) {
                  // 单曲循环模式：点击选中该文件并播放
                  _playSoundSelection(
                    idx,
                    sound,
                    fileIndex: fileIndex,
                    overridePlayMode: SoundPlayMode.single,
                  );
                } else {
                  // 列表循环模式：点击 toggle 该文件的选中状态
                  _onSoundMultiSelectionToggled(sound.soundGroup, fileIndex);
                }
              },
            ),
            // 模式切换 segmented control（仅多文件时显示）
            if (sound.soundCount > 1) ...[
              const SizedBox(height: 10),
              _buildPlayModeSelector(sound, currentPlayMode, catColor),
            ],
          ],
        ),
      ),
    );
  }

  /// 播放模式选择器（紧凑型 segmented control）
  Widget _buildPlayModeSelector(
    RecommendedSound sound,
    SoundPlayMode currentPlayMode,
    Color catColor,
  ) {
    final s = S.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 单曲循环
        GestureDetector(
          onTap: () =>
              _onSoundPlayModeChanged(sound.soundGroup, SoundPlayMode.single),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentPlayMode == SoundPlayMode.single
                  ? catColor.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentPlayMode == SoundPlayMode.single
                    ? catColor
                    : Colors.grey.withValues(alpha: 0.2),
                width: currentPlayMode == SoundPlayMode.single ? 1.5 : 1,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.repeat_one,
                  size: 15,
                  color: currentPlayMode == SoundPlayMode.single
                      ? catColor
                      : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(s.singleLoop,
                  style: TextStyle(
                      fontSize: 12,
                      color: currentPlayMode == SoundPlayMode.single
                          ? catColor
                          : AppColors.textSecondary,
                      fontWeight: currentPlayMode == SoundPlayMode.single
                          ? FontWeight.w600
                          : FontWeight.normal)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        // 列表循环
        GestureDetector(
          onTap: () =>
              _onSoundPlayModeChanged(sound.soundGroup, SoundPlayMode.sequence),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentPlayMode == SoundPlayMode.sequence
                  ? catColor.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentPlayMode == SoundPlayMode.sequence
                    ? catColor
                    : Colors.grey.withValues(alpha: 0.2),
                width: currentPlayMode == SoundPlayMode.sequence ? 1.5 : 1,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.playlist_play,
                  size: 15,
                  color: currentPlayMode == SoundPlayMode.sequence
                      ? catColor
                      : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(s.sequenceLoop,
                  style: TextStyle(
                      fontSize: 12,
                      color: currentPlayMode == SoundPlayMode.sequence
                          ? catColor
                          : AppColors.textSecondary,
                      fontWeight: currentPlayMode == SoundPlayMode.sequence
                          ? FontWeight.w600
                          : FontWeight.normal)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ]),
    );
  }

  Color _dbColor(double db) {
    if (db < 65) return Colors.green;
    if (db < 80) return Colors.orange;
    if (db < 95) return Colors.deepOrange;
    return Colors.red;
  }
}

class _BottomPlayer extends ConsumerStatefulWidget {
  final Animal? animal;
  final bool isPlaying;
  final S s;
  const _BottomPlayer(
      {required this.animal, required this.isPlaying, required this.s});

  @override
  ConsumerState<_BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends ConsumerState<_BottomPlayer> {
  bool _isPlayPending = false;
  bool _showVolumeSlider = false;
  double _systemVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _initSystemVolume();
  }

  Future<void> _initSystemVolume() async {
    try {
      final vol = await VolumeController().getVolume();
      if (mounted) {
        setState(() => _systemVolume = vol);
        ref.read(systemVolumeProvider.notifier).state = vol;
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant _BottomPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 当没有当前播放内容时，自动播放上次播放的动物或列表第一个动物
  Future<void> _playDefault() async {
    if (_isPlayPending) {
      unawaited(NativeLogger.log(
        scope: 'bottom_player:_playDefault',
        level: 'warn',
        message: 'duplicate tap blocked',
        data: {'isPlayPending': true},
      ));
      return; // 防止重复点击
    }
    _isPlayPending = true;

    final audio = AudioController.instance;
    Animal? target;
    RecommendedSound? targetSound;

    // 优先恢复上次播放的动物
    final lastId = prefs.lastPlayedAnimalId;
    final lastGroup = prefs.lastPlayedSoundGroup;
    unawaited(NativeLogger.log(
      scope: 'bottom_player:_playDefault',
      level: 'debug',
      message: 'starting playDefault',
      data: {
        'lastPlayedAnimalId': lastId,
        'lastPlayedSoundGroup': lastGroup,
        'audioCurrentAnimal': audio.currentAnimal?.id,
        'audioIsPlaying': audio.isPlaying,
        'audioCurrentAssetPath': audio.currentAssetPath,
      },
    ));
    if (lastId != null) {
      target = AnimalDatabase.findById(lastId);
      if (target != null && lastGroup != null) {
        targetSound = target.sounds.cast<RecommendedSound?>().firstWhere(
              (s) => s?.soundGroup == lastGroup,
              orElse: () => null,
            );
      }
    }

    // 回退到列表第一个动物
    target ??= AnimalDatabase.animals.firstOrNull;
    targetSound ??= target?.sounds.firstOrNull;

    if (target != null && targetSound != null) {
      // 恢复上次的声音选择偏好
      final savedIndex =
          prefs.getAnimalSoundSelectedIndex(target.id, targetSound.soundGroup);
      targetSound.selectedSoundIndex = savedIndex;
      final savedModeStr =
          prefs.getAnimalSoundPlayMode(target.id, targetSound.soundGroup);
      targetSound.playMode = savedModeStr == 'sequence'
          ? SoundPlayMode.sequence
          : SoundPlayMode.single;
      // 恢复多选索引（sequence 模式下使用）
      if (targetSound.playMode == SoundPlayMode.sequence) {
        targetSound.selectedIndices = prefs.getAnimalSoundMultiSelectedIndices(
            target.id, targetSound.soundGroup);
      }

      unawaited(NativeLogger.log(
        scope: 'bottom_player:_playDefault',
        level: 'debug',
        message: 'resolved target',
        data: {
          'targetAnimalId': target.id,
          'targetSoundGroup': targetSound.soundGroup,
          'playMode': targetSound.playMode.id,
          'selectedIndex': targetSound.selectedSoundIndex,
        },
      ));

      ref.read(currentAnimalProvider.notifier).state = target;
      ref.read(isPlayingProvider.notifier).state = true;
      // 应用音量始终为 1.0，实际音量由系统音量控制
      await audio.playWithVolume(target, targetSound, 1.0);
      unawaited(NativeLogger.log(
        scope: 'bottom_player:_playDefault',
        level: 'debug',
        message: 'audio.play completed',
        data: {
          'audioIsPlaying': audio.isPlaying,
          'audioCurrentAnimal': audio.currentAnimal?.id,
          'audioCurrentAssetPath': audio.currentAssetPath,
          'mounted': mounted,
        },
      ));
      if (mounted) {
        ref.read(currentAnimalProvider.notifier).state = audio.currentAnimal;
        ref.read(isPlayingProvider.notifier).state = audio.isPlaying;
      }
    }

    _isPlayPending = false;
  }

  void _onTap() async {
    final audio = AudioController.instance;
    // 实时检查 AudioController 是否已有播放内容，而非依赖 build 快照
    final hasActiveContent = audio.currentAnimal != null;
    unawaited(NativeLogger.log(
      scope: 'bottom_player:_onTap',
      level: 'debug',
      message: 'tap triggered',
      data: {
        'hasActiveContent': hasActiveContent,
        'audioCurrentAnimal': audio.currentAnimal?.id,
        'audioIsPlaying': audio.isPlaying,
        'audioCurrentAssetPath': audio.currentAssetPath,
        'providerCurrentAnimal': ref.read(currentAnimalProvider)?.id,
        'providerIsPlaying': ref.read(isPlayingProvider),
        'isPlayPending': _isPlayPending,
        'widgetAnimal': widget.animal?.id,
        'widgetIsPlaying': widget.isPlaying,
      },
    ));
    if (!hasActiveContent) {
      // 空状态：自动播放默认声音
      await _playDefault();
      return;
    }
    await audio.togglePlay();
    unawaited(NativeLogger.log(
      scope: 'bottom_player:_onTap',
      level: 'debug',
      message: 'togglePlay completed',
      data: {
        'audioIsPlaying': audio.isPlaying,
        'audioCurrentAnimal': audio.currentAnimal?.id,
        'mounted': mounted,
      },
    ));
    if (mounted) {
      ref.read(isPlayingProvider.notifier).state = audio.isPlaying;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    // 使用 AudioController 的实时状态判断，而非仅依赖 provider 快照
    final audio = AudioController.instance;
    final effectiveIsPlaying = audio.isPlaying;
    final effectiveAnimal = audio.currentAnimal;
    final hasContent = effectiveAnimal != null;
    // watch soundGroup 以确保声音切换时触发 rebuild
    // ignore: unused_local_variable
    final currentSoundGroup = ref.watch(currentSoundGroupProvider);
    // watch iconTheme 以确保图标主题切换时触发 rebuild
    // ignore: unused_local_variable
    final currentIconTheme = ref.watch(iconThemeProvider);
    // watch 系统音量 provider 以实时更新 UI
    final systemVolume = ref.watch(systemVolumeProvider);
    _systemVolume = systemVolume;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = hasContent
        ? effectiveAnimal!
            .getLocalizedName(Localizations.localeOf(context).languageCode)
        : s.appName;
    final currentSound = audio.currentSound;
    final counter = hasContent
        ? (currentSound != null
            ? currentSound
                .getLocalizedName(Localizations.localeOf(context).languageCode)
            : effectiveAnimal!.getLocalizedCounterSound(
                Localizations.localeOf(context).languageCode))
        : s.tapToPreview;
    final themeId = hasContent
        ? prefs.getAnimalIconTheme(effectiveAnimal!.id)
        : prefs.iconTheme;
    final imagePath = effectiveAnimal?.getIconPath(themeId);
    final fallbackIcon = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          const Icon(Icons.volume_up_rounded, color: Colors.orange, size: 24),
    );

    return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          border: Border(
              top: BorderSide(
                  color: isDark ? AppColorsDark.divider : Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.02 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasContent && imagePath != null
                      ? Image.asset(imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => fallbackIcon)
                      : fallbackIcon),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? AppColorsDark.textPrimary : null)),
                    const SizedBox(height: 2),
                    // 声音名称
                    Text(counter,
                        style: TextStyle(
                            color: hasContent
                                ? (isDark
                                    ? AppColorsDark.textSecondary
                                    : Colors.grey[500])
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: hasContent
                                ? FontWeight.normal
                                : FontWeight.w500)),
                  ])),
              // 音量按钮
              if (hasContent)
                GestureDetector(
                  onTap: () =>
                      setState(() => _showVolumeSlider = !_showVolumeSlider),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _showVolumeSlider
                          ? Colors.orange.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                        systemVolume > 0.5
                            ? Icons.volume_up_rounded
                            : (systemVolume > 0.2
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded),
                        size: 18,
                        color: _showVolumeSlider
                            ? Colors.orange
                            : (isDark
                                ? AppColorsDark.textSecondary
                                : Colors.grey[600])),
                  ),
                ),
              // 播放/暂停按钮
              GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveIsPlaying ? Colors.red : Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color:
                              (effectiveIsPlaying ? Colors.red : Colors.orange)
                                  .withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Icon(
                      effectiveIsPlaying
                          ? Icons.pause
                          : (hasContent
                              ? Icons.play_arrow
                              : Icons.volume_up_rounded),
                      color: Colors.white,
                      size: 28),
                ),
              ),
            ]),
            // 系统音量滑块区域
            if (_showVolumeSlider && hasContent) ...[
              const SizedBox(height: 8),
              _SystemVolumeSlider(currentVolume: systemVolume),
            ],
          ],
        ));
  }
}

// ============ 工具方法 ============

Color _catColor(AnimalCategory cat) {
  switch (cat) {
    case AnimalCategory.beast:
      return Colors.orange;
    case AnimalCategory.reptile:
      return Colors.green;
    case AnimalCategory.primate:
      return Colors.brown;
    case AnimalCategory.rodent:
      return Colors.blueGrey;
    case AnimalCategory.insect:
      return Colors.purple;
    case AnimalCategory.bird:
      return Colors.blue;
    case AnimalCategory.all:
      return Colors.orange;
  }
}

IconData _animalIcon(String name) {
  const map = {
    'pets': Icons.pets,
    'dangerous': Icons.dangerous,
    'forest': Icons.forest,
    'cottage': Icons.cottage,
    'emoji_nature': Icons.emoji_nature,
    'pest_control': Icons.pest_control,
    'nights_stay': Icons.nights_stay,
    'bug_report': Icons.bug_report,
    'hive': Icons.hive,
    'grass': Icons.grass,
    'flutter_dash': Icons.flutter_dash,
  };
  return map[name] ?? Icons.pets;
}

/// 系统音量滑块组件 - 控制设备系统音量
class _SystemVolumeSlider extends StatefulWidget {
  final double currentVolume;
  const _SystemVolumeSlider({required this.currentVolume});

  @override
  State<_SystemVolumeSlider> createState() => _SystemVolumeSliderState();
}

class _SystemVolumeSliderState extends State<_SystemVolumeSlider> {
  late double _sliderValue;
  bool _isDragging = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentVolume;
  }

  @override
  void didUpdateWidget(covariant _SystemVolumeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果不在拖拽中且不在防抖窗口内，同步系统音量值
    if (!_isDragging && _debounceTimer == null) {
      _sliderValue = widget.currentVolume;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(Icons.volume_mute_rounded,
            size: 16,
            color: isDark ? AppColorsDark.textSecondary : Colors.grey[500]),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
              thumbColor: Colors.orange,
              overlayColor: Colors.orange.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: _sliderValue.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                  _isDragging = true;
                });
                // 实时调整系统音量
                AudioController.instance.setSystemVolume(value);
              },
              onChangeEnd: (value) {
                _isDragging = false;
                // 设置防抖窗口：松手后 300ms 内不接受 provider 的旧值覆盖
                // 防止 volume_controller 在模拟器上延迟回调导致滑块回弹
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  _debounceTimer = null;
                });
              },
            ),
          ),
        ),
        Icon(Icons.volume_up_rounded,
            size: 16,
            color: isDark ? AppColorsDark.textSecondary : Colors.grey[500]),
        const SizedBox(width: 4),
        Text('${(_sliderValue * 100).round()}%',
            style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColorsDark.textSecondary : Colors.grey[600],
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
