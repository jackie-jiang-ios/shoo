import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import '../../models/sound.dart';
import '../../models/play_mode.dart';
import '../../models/animal.dart';

/// 单个声音的播放状态
class SoundPlayState {
  final Sound sound;
  final PlayState state;
  final PlayConfig config;
  final double elapsed;
  final AudioPlayer? player;

  const SoundPlayState({
    required this.sound,
    this.state = PlayState.idle,
    this.config = const PlayConfig(),
    this.elapsed = 0,
    this.player,
  });

  SoundPlayState copyWith({
    PlayState? state,
    PlayConfig? config,
    double? elapsed,
    AudioPlayer? player,
  }) {
    return SoundPlayState(
      sound: sound,
      state: state ?? this.state,
      config: config ?? this.config,
      elapsed: elapsed ?? this.elapsed,
      player: player ?? this.player,
    );
  }
}

/// 音频引擎核心
///
/// 管理所有声音的播放、停止、音量控制和播放模式。
/// 支持同时播放多个声音（混合模式）。
class AudioEngine {
  final Map<String, SoundPlayState> _playStates = {};
  final _stateController = StreamController<Map<String, SoundPlayState>>.broadcast();

  /// 播放状态流
  Stream<Map<String, SoundPlayState>> get stateStream => _stateController.stream;

  /// 当前所有播放状态
  Map<String, SoundPlayState> get playStates => Map.unmodifiable(_playStates);

  /// 是否有声音正在播放
  bool get isPlaying => _playStates.values.any((s) => s.state == PlayState.playing);

  /// 当前播放中的声音数量
  int get playingCount => _playStates.values.where((s) => s.state == PlayState.playing).length;

  final Map<String, Timer> _timers = {};
  final Map<String, Timer> _gapTimers = {};
  Timer? _autoStopTimer;

  // ============ 动物驱赶音量管理 ============

  /// 当前音量模式
  VolumeMode _volumeMode = VolumeMode.global;

  /// 通用模式下使用的统一音量
  double _globalVolume = 0.8;

  /// 独立模式下各动物的自定义音量 (animalId -> volume)
  final Map<String, double> _animalVolumes = {};

  /// 当前音量模式
  VolumeMode get volumeMode => _volumeMode;

  /// 设置音量模式
  void setVolumeMode(VolumeMode mode) {
    _volumeMode = mode;
    // 切换模式后，更新所有正在播放的声音音量
    _applyVolumeToAllPlaying();
  }

  /// 设置通用音量
  Future<void> setGlobalVolume(double volume) async {
    _globalVolume = volume.clamp(0.0, 1.0);
    if (_volumeMode == VolumeMode.global) {
      await _applyVolumeToAllPlaying();
    }
  }

  /// 设置指定动物的独立音量
  Future<void> setAnimalVolume(String animalId, double volume) async {
    _animalVolumes[animalId] = volume.clamp(0.0, 1.0);
    if (_volumeMode == VolumeMode.individual) {
      // 更新该动物关联的所有正在播放的声音
      await _applyVolumeForAnimal(animalId);
    }
  }

  /// 获取指定动物的有效播放音量
  /// 综合考虑音量模式、动物推荐音量、声音权重
  double getEffectiveVolume(String animalId, {double soundVolumeWeight = 1.0}) {
    switch (_volumeMode) {
      case VolumeMode.global:
        return _globalVolume * soundVolumeWeight;
      case VolumeMode.individual:
        final baseVolume = _animalVolumes[animalId] ?? _getDefaultAnimalVolume(animalId);
        return baseVolume * soundVolumeWeight;
    }
  }

  /// 获取动物默认推荐音量
  double _getDefaultAnimalVolume(String animalId) {
    final animal = AnimalDatabase.findById(animalId);
    return animal?.recommendedVolume ?? 0.8;
  }

  /// 对所有正在播放的声音应用当前音量设置
  Future<void> _applyVolumeToAllPlaying() async {
    for (final state in _playStates.values) {
      if (state.state == PlayState.playing && state.player != null) {
        final animalId = state.sound.targetAnimal;
        final soundWeight = state.sound.defaultVolume;
        final effectiveVolume = getEffectiveVolume(animalId, soundVolumeWeight: soundWeight);
        await state.player!.setVolume(effectiveVolume.clamp(0.0, 1.0));
        _playStates[state.sound.id] = state.copyWith(
          config: state.config.copyWith(volume: effectiveVolume),
        );
      }
    }
    _notifyStateChange();
  }

  /// 对指定动物的正在播放声音应用音量
  Future<void> _applyVolumeForAnimal(String animalId) async {
    for (final state in _playStates.values) {
      if (state.sound.targetAnimal == animalId &&
          state.state == PlayState.playing &&
          state.player != null) {
        final soundWeight = state.sound.defaultVolume;
        final effectiveVolume = getEffectiveVolume(animalId, soundVolumeWeight: soundWeight);
        await state.player!.setVolume(effectiveVolume.clamp(0.0, 1.0));
        _playStates[state.sound.id] = state.copyWith(
          config: state.config.copyWith(volume: effectiveVolume),
        );
      }
    }
    _notifyStateChange();
  }

  // ============ 分贝估算工具 ============

  /// 手机扬声器预估最大输出分贝（dB SPL）
  static const double maxDeviceDb = 100.0;

  /// 根据音量值估算输出分贝
  /// 使用非线性映射模拟人耳对音量的感知（对数关系）
  static double estimateDb(double volume) {
    final v = volume.clamp(0.0, 1.0);
    return maxDeviceDb * (v * v * 0.6 + v * 0.4);
  }

  /// 根据输出分贝估算有效传播距离（开阔环境）
  /// 声衰减公式简化版：距离每翻倍，声压降低约6dB
  /// [thresholdDb] 有效驱赶阈值分贝，默认60dB
  static double estimateRange(double outputDb, {double thresholdDb = 60.0}) {
    if (outputDb <= thresholdDb) return 1.0;
    final diff = outputDb - thresholdDb;
    final distance = pow(2, diff / 6);
    return distance.toDouble().clamp(1.0, 100.0);
  }

  /// 播放声音
  Future<void> play(Sound sound, {PlayConfig? config}) async {
    final playConfig = config ?? const PlayConfig();

    // 如果已有相同声音在播放，先停止
    if (_playStates.containsKey(sound.id)) {
      await _stopSound(sound.id);
    }

    // 创建播放器
    final player = AudioPlayer();
    try {
      await player.setAsset(sound.assetPath);
      await player.setVolume(playConfig.volume);
    } catch (e) {
      print('音频资源加载失败: ${sound.assetPath}, 错误: $e');
      return;
    }

    // 根据播放模式开始播放
    switch (playConfig.mode) {
      case PlayMode.continuous:
        await _playContinuous(sound, player, playConfig);
      case PlayMode.interval:
        await _playInterval(sound, player, playConfig);
    }

    // 设置自动停止
    if (playConfig.autoStopDuration != null) {
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(playConfig.autoStopDuration!, () {
        stopAll();
      });
    }

    _notifyStateChange();
  }

  /// 持续播放
  Future<void> _playContinuous(Sound sound, AudioPlayer player, PlayConfig config) async {
    await player.setLoopMode(LoopMode.one);
    await player.play();

    _playStates[sound.id] = SoundPlayState(
      sound: sound,
      state: PlayState.playing,
      config: config,
      player: player,
    );
  }

  /// 间隔播放
  Future<void> _playInterval(Sound sound, AudioPlayer player, PlayConfig config) async {
    await player.setLoopMode(LoopMode.one);
    await player.play();

    _playStates[sound.id] = SoundPlayState(
      sound: sound,
      state: PlayState.playing,
      config: config,
      player: player,
    );

    // 设置间隔：播放一段时间后暂停，再恢复
    _timers[sound.id]?.cancel();
    _timers[sound.id] = Timer.periodic(
      Duration(milliseconds: (config.intervalSeconds * 1000).round()),
      (timer) async {
        final currentState = _playStates[sound.id];
        if (currentState == null) {
          timer.cancel();
          return;
        }

        if (currentState.state == PlayState.playing) {
          // 暂停播放
          await player.pause();
          _playStates[sound.id] = currentState.copyWith(state: PlayState.inGap);
          _notifyStateChange();

          // 间隔后恢复
          _gapTimers[sound.id]?.cancel();
          _gapTimers[sound.id] = Timer(
            Duration(milliseconds: (config.intervalSeconds * 1000).round()),
            () async {
              if (_playStates[sound.id]?.state == PlayState.inGap) {
                await player.play();
                _playStates[sound.id] = _playStates[sound.id]!.copyWith(
                  state: PlayState.playing,
                );
                _notifyStateChange();
              }
            },
          );
        }
      },
    );
  }

  /// 停止指定声音
  Future<void> stop(String soundId) async {
    await _stopSound(soundId);
    _notifyStateChange();
  }

  Future<void> _stopSound(String soundId) async {
    final state = _playStates[soundId];
    if (state?.player != null) {
      await state!.player!.stop();
      await state.player!.dispose();
    }
    _timers[soundId]?.cancel();
    _gapTimers[soundId]?.cancel();
    _playStates.remove(soundId);
  }

  /// 停止所有声音
  Future<void> stopAll() async {
    _autoStopTimer?.cancel();
    for (final soundId in _playStates.keys.toList()) {
      await _stopSound(soundId);
    }
    _notifyStateChange();
  }

  /// 设置音量
  Future<void> setVolume(String soundId, double volume) async {
    final state = _playStates[soundId];
    if (state?.player != null) {
      await state!.player!.setVolume(volume.clamp(0.0, 1.0));
      _playStates[soundId] = state.copyWith(
        config: state.config.copyWith(volume: volume),
      );
      _notifyStateChange();
    }
  }

  /// 设置播放模式
  Future<void> setPlayMode(String soundId, PlayMode mode) async {
    final state = _playStates[soundId];
    if (state == null) return;

    // 先停止当前播放
    await _stopSound(soundId);

    // 用新模式重新播放
    await play(state.sound, config: state.config.copyWith(mode: mode));
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await stopAll();
    await _stateController.close();
  }

  void _notifyStateChange() {
    if (!_stateController.isClosed) {
      _stateController.add(Map.unmodifiable(_playStates));
    }
  }
}
