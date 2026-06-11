import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/animal.dart';
import '../../models/play_mode.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/storage/preferences.dart';
import '../../theme/colors.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_page.dart';

/// 声音播放状态 Provider
final soundPlayStateProvider = StateNotifierProvider<SoundPlayNotifier, Map<String, bool>>((ref) {
  return SoundPlayNotifier();
});

class SoundPlayNotifier extends StateNotifier<Map<String, bool>> {
  SoundPlayNotifier() : super({});

  void setPlaying(String soundId, bool playing) {
    state = {...state, soundId: playing};
  }

  void stopAll() {
    state = {};
  }
}

/// 声音播放器页面 - 播放指定动物的推荐声音
/// 支持通用/独立音量模式、声音组内选择、连续播放模式
class SoundPlayerPage extends ConsumerStatefulWidget {
  final Animal animal;
  final RecommendedSound? initialSound;

  const SoundPlayerPage({super.key, required this.animal, this.initialSound});

  @override
  ConsumerState<SoundPlayerPage> createState() => _SoundPlayerPageState();
}

class _SoundPlayerPageState extends ConsumerState<SoundPlayerPage>
    with SingleTickerProviderStateMixin {
  late double _volume;
  VolumeMode _volumeMode = VolumeMode.global;
  PlayMode _playMode = PlayMode.continuous;
  bool _isPlaying = false;
  double _intervalSeconds = 3.0;
  double _pulseDuration = 0.5;
  double _pulseGap = 1.0;
  int _selectedSoundIndex = 0;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // 从偏好存储中恢复设置
    final animal = widget.animal;
    final savedVolumeMode = prefs.volumeMode;
    _volumeMode = savedVolumeMode == 'individual' ? VolumeMode.individual : VolumeMode.global;

    if (_volumeMode == VolumeMode.individual) {
      _volume = prefs.getAnimalVolume(animal.id);
    } else {
      _volume = prefs.defaultVolume;
    }

    final savedPlayMode = prefs.defaultPlayMode;
    _playMode = PlayMode.values.firstWhere(
      (m) => m.id == savedPlayMode,
      orElse: () => PlayMode.continuous,
    );
    _intervalSeconds = prefs.intervalSeconds;
    _pulseDuration = prefs.pulseDuration;
    _pulseGap = prefs.pulseGap;

    // 恢复选中声音索引
    _selectedSoundIndex = prefs.getAnimalSelectedSoundIndex(animal.id);
    if (_selectedSoundIndex >= animal.sounds.length) _selectedSoundIndex = 0;

    // 如果有传入初始声音，优先使用
    if (widget.initialSound != null) {
      final idx = widget.animal.sounds.indexOf(widget.initialSound!);
      if (idx >= 0) _selectedSoundIndex = idx;
    }

    // 恢复声音组的播放模式和选中索引
    for (final sound in animal.sounds) {
      final savedMode = prefs.getAnimalSoundPlayMode(animal.id, sound.soundGroup);
      sound.playMode = savedMode == 'sequence' ? SoundPlayMode.sequence : SoundPlayMode.single;
      sound.selectedSoundIndex = prefs.getAnimalSoundSelectedIndex(animal.id, sound.soundGroup);
      if (sound.selectedSoundIndex >= sound.soundCount) sound.selectedSoundIndex = 0;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final audio = AudioController.instance;
    if (_isPlaying) {
      audio.stop();
      _waveController.stop();
    } else {
      final sound = widget.animal.sounds[_selectedSoundIndex];
      // 使用用户设置的音量播放
      final effectiveVolume = _volumeMode == VolumeMode.individual
          ? _volume * sound.volumeWeight
          : _volume;
      audio.playWithVolume(widget.animal, sound, effectiveVolume);
      _waveController.repeat();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  /// 根据音量计算预估分贝
  double get _estimatedDb {
    const maxDb = 100.0;
    return maxDb * (_volume * _volume * 0.6 + _volume * 0.4);
  }

  /// 根据分贝估算传播距离
  double get _estimatedRange {
    const threshold = 60.0;
    if (_estimatedDb <= threshold) return 1.0;
    final distance = distanceFromDb(_estimatedDb, threshold);
    return distance.clamp(1.0, 100.0);
  }

  static double distanceFromDb(double sourceDb, double thresholdDb) {
    final diff = sourceDb - thresholdDb;
    final distance = pow(2, diff / 6);
    return distance.toDouble().clamp(1.0, 100.0);
  }

  String _getDbLevelDesc(double db) {
    if (db < 50) return '低';
    if (db < 65) return '中低';
    if (db < 75) return '中等';
    if (db < 85) return '中高';
    if (db < 95) return '高';
    return '极高';
  }

  Color _getDbLevelColor(double db) {
    if (db < 50) return Colors.blue;
    if (db < 65) return Colors.green;
    if (db < 75) return Colors.lightGreen;
    if (db < 85) return Colors.orange;
    if (db < 95) return Colors.deepOrange;
    return Colors.red;
  }

  void _onVolumeModeChanged(VolumeMode mode) {
    setState(() {
      _volumeMode = mode;
      prefs.volumeMode = mode.id;
      if (mode == VolumeMode.individual) {
        _volume = prefs.getAnimalVolume(widget.animal.id);
      } else {
        _volume = prefs.defaultVolume;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final animal = widget.animal;
    final sounds = animal.sounds;
    final selectedSound = sounds[_selectedSoundIndex];
    final isZh = s.isZh;
    final animalName = isZh ? animal.name : animal.nameEn;
    final soundName = isZh ? selectedSound.name : selectedSound.nameEn;
    final catColor = _catColor(animal.category);
    final dbColor = _getDbLevelColor(_estimatedDb);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [catColor.withValues(alpha: 0.8), catColor, catColor.withValues(alpha: 0.6)],
                )),
                child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(32)),
                    child: Icon(_animalIconData(animal.iconName), size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(animalName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(soundName, style: TextStyle(color: Colors.white70, fontSize: 16)),
                ])),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ 声学参数信息卡 ============
              _buildAcousticInfoCard(animal, catColor, isZh),
              const SizedBox(height: 24),

              // 播放/停止按钮
              Center(child: GestureDetector(
                onTap: _togglePlay,
                child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(color: _isPlaying ? AppColors.danger : catColor, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: (_isPlaying ? AppColors.danger : catColor).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]),
                  child: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40)),
              )),
              const SizedBox(height: 32),

              // ============ 声音选择 ============
              Text(s.recommendedSounds, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              ...sounds.asMap().entries.map((entry) {
                final idx = entry.key;
                final sound = entry.value;
                final sName = isZh ? sound.name : sound.nameEn;
                return _buildSoundItem(idx, sound, sName, catColor, isZh);
              }),

              const SizedBox(height: 24),

              // ============ 组内声音选择（当前声音组有多首时显示） ============
              if (selectedSound.soundCount > 1) ...[
                _buildSoundGroupSelector(selectedSound, catColor, isZh),
                const SizedBox(height: 24),
              ],

              // ============ 音量模式切换 ============
              _buildVolumeModeSelector(catColor),
              const SizedBox(height: 16),

              // ============ 音量控制 ============
              _buildVolumeControl(dbColor, isZh),
              const SizedBox(height: 24),

              // 播放模式
              Text(s.playMode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              SegmentedButton<PlayMode>(
                segments: [
                  ButtonSegment(value: PlayMode.continuous, label: Text(s.continuous), icon: const Icon(Icons.all_inclusive)),
                  ButtonSegment(value: PlayMode.interval, label: Text(s.intervalPlay), icon: const Icon(Icons.timer)),
                  ButtonSegment(value: PlayMode.pulse, label: Text(s.pulsePlay), icon: const Icon(Icons.flash_on)),
                ],
                selected: {_playMode},
                onSelectionChanged: (modes) {
                  setState(() => _playMode = modes.first);
                  prefs.defaultPlayMode = modes.first.id;
                },
              ),
              const SizedBox(height: 40),
            ],
          ))),
        ],
      ),
    );
  }

  /// 声学参数信息卡
  Widget _buildAcousticInfoCard(Animal animal, Color catColor, bool isZh) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [catColor.withValues(alpha: 0.08), catColor.withValues(alpha: 0.03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: catColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.graphic_eq, color: catColor, size: 20),
            const SizedBox(width: 8),
            Text(isZh ? '声学参数' : 'Acoustic Parameters',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: catColor)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAcousticParamItem(
                icon: Icons.volume_up,
                label: isZh ? '推荐分贝' : 'Rec. dB',
                value: '${animal.recommendedDb.round()}',
                unit: 'dB',
                color: _getDbLevelColor(animal.recommendedDb),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildAcousticParamItem(
                icon: Icons.straighten,
                label: isZh ? '有效距离' : 'Range',
                value: animal.effectiveRange >= 10
                    ? animal.effectiveRange.round().toString()
                    : animal.effectiveRange.toStringAsFixed(1),
                unit: isZh ? '米' : 'm',
                color: AppColors.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildAcousticParamItem(
                icon: Icons.waves,
                label: isZh ? '频率范围' : 'Freq.',
                value: animal.frequencyRange,
                unit: '',
                color: Colors.purple,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcousticParamItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 4),
          RichText(text: TextSpan(
            text: value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            children: [
              if (unit.isNotEmpty) TextSpan(text: unit, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
            ],
          )),
        ],
      ),
    );
  }

  /// 声音选择项
  Widget _buildSoundItem(int idx, RecommendedSound sound, String sName, Color catColor, bool isZh) {
    final isSelected = idx == _selectedSoundIndex;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? catColor.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: catColor.withValues(alpha: 0.3)) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: isSelected,
        selectedTileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(i < sound.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14))),
        title: Row(children: [
          Text(sName, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          const SizedBox(width: 8),
          // 声音组标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(sound.soundGroup,
              style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w500)),
          ),
          if (sound.soundCount > 1) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${sound.soundCount}${isZh ? '首' : ' files'}',
                style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500)),
            ),
          ],
          // 分贝标签
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: _getDbLevelColor(sound.estimatedDb).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${sound.estimatedDb.round()}dB',
              style: TextStyle(fontSize: 10, color: _getDbLevelColor(sound.estimatedDb), fontWeight: FontWeight.w500)),
          ),
          if (sound.volumeWeight < 1.0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('×${sound.volumeWeight}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ),
          ],
        ]),
        subtitle: sound.frequencyRange.isNotEmpty ? Text(sound.frequencyRange,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint)) : null,
        trailing: isSelected ? Icon(Icons.check_circle, color: catColor) : null,
        onTap: () {
          setState(() => _selectedSoundIndex = idx);
          prefs.setAnimalSelectedSoundIndex(widget.animal.id, idx);
        },
      ),
    );
  }

  /// 组内声音选择器（当声音组有多首时显示）
  Widget _buildSoundGroupSelector(RecommendedSound sound, Color catColor, bool isZh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isZh ? '组内声音选择' : 'Sound Selection',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        // 播放模式：单个 / 连续
        Row(children: [
          Text(isZh ? '播放模式' : 'Play Mode', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          SegmentedButton<SoundPlayMode>(
            segments: [
              ButtonSegment(value: SoundPlayMode.single, label: Text(isZh ? '单个' : 'Single'), icon: const Icon(Icons.looks_one, size: 18)),
              ButtonSegment(value: SoundPlayMode.sequence, label: Text(isZh ? '连续' : 'Sequence'), icon: const Icon(Icons.playlist_play, size: 18)),
            ],
            selected: {sound.playMode},
            onSelectionChanged: (modes) {
              setState(() => sound.playMode = modes.first);
              prefs.setAnimalSoundPlayMode(widget.animal.id, sound.soundGroup, modes.first.id);
            },
          ),
        ]),
        const SizedBox(height: 12),
        // 单个模式下，选择具体哪一首
        if (sound.playMode == SoundPlayMode.single && sound.soundCount > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sound.soundCount,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = sound.selectedSoundIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => sound.selectedSoundIndex = index);
                    prefs.setAnimalSoundSelectedIndex(widget.animal.id, sound.soundGroup, index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? catColor.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? catColor : Colors.grey.withValues(alpha: 0.2), width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(isSelected ? Icons.music_note : Icons.music_note_outlined, size: 14, color: isSelected ? catColor : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${isZh ? '声音' : 'Sound'} ${index + 1}',
                        style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? catColor : AppColors.textSecondary)),
                    ]),
                  ),
                );
              },
            ),
          ),
        // 连续模式下的提示
        if (sound.playMode == SoundPlayMode.sequence)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(child: Text(
                isZh
                    ? '连续播放模式：将依次播放 ${sound.soundGroup} 组内的 ${sound.soundCount} 首声音'
                    : 'Sequence mode: plays all ${sound.soundCount} sounds in ${sound.soundGroup} group in order',
                style: const TextStyle(fontSize: 11, color: Colors.blue),
              )),
            ]),
          ),
      ],
    );
  }

  /// 音量模式切换
  Widget _buildVolumeModeSelector(Color catColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('音量模式', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildVolumeModeButton(
              mode: VolumeMode.global,
              icon: Icons.volume_up,
              title: '通用音量',
              subtitle: '所有动物统一音量',
              catColor: catColor,
            )),
            const SizedBox(width: 10),
            Expanded(child: _buildVolumeModeButton(
              mode: VolumeMode.individual,
              icon: Icons.tune,
              title: '独立音量',
              subtitle: '按动物推荐调节',
              catColor: catColor,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeModeButton({
    required VolumeMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color catColor,
  }) {
    final isSelected = _volumeMode == mode;
    return GestureDetector(
      onTap: () => _onVolumeModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? catColor.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? catColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: isSelected ? catColor : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14,
                color: isSelected ? catColor : AppColors.textSecondary,
              )),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 14, color: catColor),
              ],
            ]),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  /// 音量控制
  Widget _buildVolumeControl(Color dbColor, bool isZh) {
    final selectedSound = widget.animal.sounds[_selectedSoundIndex];
    final effectiveVolume = _volumeMode == VolumeMode.individual
        ? _volume * selectedSound.volumeWeight
        : _volume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(isZh ? '音量' : 'Volume', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: dbColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.graphic_eq, size: 14, color: dbColor),
              const SizedBox(width: 4),
              Text('~${_estimatedDb.round()} dB', style: TextStyle(fontSize: 12, color: dbColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Text(_getDbLevelDesc(_estimatedDb), style: TextStyle(fontSize: 10, color: dbColor)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.volume_down, color: AppColors.textSecondary),
          Expanded(child: Slider(
            value: _volume,
            onChanged: (v) {
              setState(() => _volume = v);
              // 实时保存音量设置
              if (_volumeMode == VolumeMode.individual) {
                prefs.setAnimalVolume(widget.animal.id, v);
              } else {
                prefs.defaultVolume = v;
              }
              // 如果正在播放，实时更新音量
              if (_isPlaying) {
                final sound = widget.animal.sounds[_selectedSoundIndex];
                final effectiveVolume = _volumeMode == VolumeMode.individual
                    ? _volume * sound.volumeWeight
                    : _volume;
                AudioController.instance.setVolume(effectiveVolume);
              }
            },
          )),
          const Icon(Icons.volume_up, color: AppColors.textSecondary),
          SizedBox(width: 48, child: Text('${(_volume * 100).round()}%', textAlign: TextAlign.center)),
        ]),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(Icons.volume_up, size: 16, color: dbColor),
              const SizedBox(width: 6),
              Text(isZh ? '预估输出' : 'Est. Output', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Text('${_estimatedDb.round()} dB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dbColor)),
              const Spacer(),
              Icon(Icons.straighten, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(isZh ? '有效距离' : 'Range', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Text(
                _estimatedRange >= 10 ? '~${_estimatedRange.round()}m' : '~${_estimatedRange.toStringAsFixed(1)}m',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),

        if (_volumeMode == VolumeMode.individual && selectedSound.volumeWeight < 1.0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(child: Text(
                isZh
                    ? '该声音音量权重 ×${selectedSound.volumeWeight}，实际播放 ${(effectiveVolume * 100).round()}%'
                    : 'Volume weight ×${selectedSound.volumeWeight}, actual ${(effectiveVolume * 100).round()}%',
                style: const TextStyle(fontSize: 11, color: Colors.blue),
              )),
            ]),
          ),
        ],

        if (_volumeMode == VolumeMode.individual) ...[
          const SizedBox(height: 8),
          Row(children: [
            Text(isZh ? '快捷调节' : 'Quick', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            _buildQuickVolumeButton(isZh ? '推荐' : 'Rec.', widget.animal.recommendedVolume, dbColor),
            const SizedBox(width: 6),
            _buildQuickVolumeButton(isZh ? '安静' : 'Quiet', 0.4, Colors.blue),
            const SizedBox(width: 6),
            _buildQuickVolumeButton(isZh ? '标准' : 'Normal', 0.7, Colors.green),
            const SizedBox(width: 6),
            _buildQuickVolumeButton(isZh ? '最大' : 'Max', 1.0, Colors.red),
          ]),
        ],
      ],
    );
  }

  Widget _buildQuickVolumeButton(String label, double volume, Color color) {
    final isActive = (_volume - volume).abs() < 0.02;
    return GestureDetector(
      onTap: () {
        setState(() => _volume = volume);
        if (_volumeMode == VolumeMode.individual) {
          prefs.setAnimalVolume(widget.animal.id, volume);
        } else {
          prefs.defaultVolume = volume;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : Colors.transparent, width: 1),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? color : AppColors.textSecondary,
        )),
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

IconData _animalIconData(String iconName) {
  const map = {
    'pets': Icons.pets, 'dangerous': Icons.dangerous, 'forest': Icons.forest,
    'cottage': Icons.cottage, 'emoji_nature': Icons.emoji_nature, 'pest_control': Icons.pest_control,
    'nights_stay': Icons.nights_stay, 'bug_report': Icons.bug_report, 'hive': Icons.hive,
    'grass': Icons.grass, 'flutter_dash': Icons.flutter_dash,
  };
  return map[iconName] ?? Icons.pets;
}
