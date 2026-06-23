import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../models/animal.dart';
import '../platform/native_logger.dart';
import '../storage/preferences.dart';
import 'playback_auto_stop.dart';
import 'sequence_playback_context.dart';

class AudioController {
  AudioController._();

  static final AudioController instance = AudioController._();

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  Future<void> _operationQueue = Future.value();
  RecommendedSound? _currentSound;
  Animal? _currentAnimal;
  String? _currentAssetPath;
  bool _isPlaying = false;
  int _sequenceIndex = 0;
  int _playbackGeneration = 0;
  SequencePlaybackContext? _sequenceContext;
  Timer? _intervalTimer;
  bool _isInIntervalGap = false;
  final PlaybackAutoStop _autoStop = PlaybackAutoStop();

  /// 用户是否手动设置过系统音量（防止自动调大逻辑覆盖用户意图）
  bool _userManuallySetVolume = false;

  /// 应用内播放音量，始终为 1.0（满格）
  /// 实际输出音量完全由系统音量控制
  static const double _appVolume = 1.0;

  /// 自动调大系统音量时的目标值
  static const double autoVolumeTarget = 0.8;

  /// 系统音量变化监听回调
  void Function(double systemVolume)? onSystemVolumeChanged;

  bool get isPlaying => _isPlaying;
  bool get isInIntervalGap => _isInIntervalGap;
  RecommendedSound? get currentSound => _currentSound;
  Animal? get currentAnimal => _currentAnimal;
  String? get currentAssetPath => _currentAssetPath;
  Duration get currentPosition => _player?.position ?? Duration.zero;
  Duration? get currentDuration => _player?.duration;

  /// 初始化系统音量监听
  Future<void> initVolumeListener() async {
    try {
      VolumeController().listener((volume) {
        // 如果用户通过硬件按键将音量调高到自动调大目标值以上，清除手动标记
        // 这样下次播放时就能恢复自动调大行为
        if (_userManuallySetVolume && volume >= autoVolumeTarget) {
          _userManuallySetVolume = false;
        }
        onSystemVolumeChanged?.call(volume);
      });
    } catch (e) {
      debugPrint('系统音量监听初始化失败: $e');
    }
  }

  /// 获取当前系统音量
  Future<double> getSystemVolume() async {
    try {
      return await VolumeController().getVolume();
    } catch (e) {
      debugPrint('获取系统音量失败: $e');
      return 1.0;
    }
  }

  Future<void> _setSystemVolumeInternal(
    double volume, {
    required bool markAsUserOverride,
  }) async {
    try {
      final clamped = (volume.clamp(0.0, 1.0) as num).toDouble();
      VolumeController().setVolume(clamped, showSystemUI: false);
      _userManuallySetVolume = markAsUserOverride;
      // 立即通知回调，避免 provider 持有旧值导致滑块回弹
      onSystemVolumeChanged?.call(clamped);
    } catch (e) {
      debugPrint('设置系统音量失败: $e');
    }
  }

  /// 设置系统音量
  Future<void> setSystemVolume(double volume) async {
    await _setSystemVolumeInternal(volume, markAsUserOverride: true);
  }

  /// 根据设置中的默认音量初始化播放音量。
  /// 当用户在当前会话手动调过音量时，尊重用户选择，不再覆盖。
  Future<void> ensureMinSystemVolume() async {
    if (_userManuallySetVolume) {
      unawaited(NativeLogger.log(
        scope: 'audio_controller:ensureMinSystemVolume',
        level: 'debug',
        message: 'skipping default volume apply, user manually set volume',
      ));
      return;
    }
    try {
      final currentVol = await VolumeController().getVolume();
      final defaultVol = (prefs.defaultVolume.clamp(0.0, 1.0) as num).toDouble();
      unawaited(NativeLogger.log(
        scope: 'audio_controller:ensureMinSystemVolume',
        level: 'debug',
        message: 'applying configured default volume',
        data: {
          'currentVolume': currentVol.toStringAsFixed(2),
          'defaultVolume': defaultVol.toStringAsFixed(2),
          'willAdjust': (currentVol - defaultVol).abs() >= 0.01,
        },
      ));
      if ((currentVol - defaultVol).abs() >= 0.01) {
        await _setSystemVolumeInternal(defaultVol, markAsUserOverride: false);
      }
    } catch (e) {
      debugPrint('应用默认系统音量失败: $e');
    }
  }

  Future<void> playWithVolume(
    Animal animal,
    RecommendedSound sound,
    double volume,
  ) =>
      _enqueue(() => _startPlayback(animal, sound));

  Future<void> play(Animal animal, RecommendedSound sound) =>
      _enqueue(() => _startPlayback(animal, sound));

  Future<void> _startPlayback(
    Animal animal,
    RecommendedSound sound,
  ) async {
    final generation = _invalidatePlayback();
    final paths = sound.assetPaths;

    await _disposeCurrentPlayer();

    _currentAnimal = animal;
    _currentSound = sound;
    if (paths.isEmpty) return;

    _scheduleAutoStopForNewPlayback();

    // 进入播放前应用默认音量设置
    await ensureMinSystemVolume();

    unawaited(NativeLogger.log(
      scope: 'audio_controller:_startPlayback',
      level: 'debug',
      message: 'start playback',
      data: {
        'animalId': animal.id,
        'soundGroup': sound.soundGroup,
        'playMode': sound.playMode.id,
        'pathsCount': paths.length,
        'paths': paths.join(', '),
        'appVolume': _appVolume.toStringAsFixed(2),
      },
    ));

    if (sound.playMode == SoundPlayMode.sequence && paths.length > 1) {
      _sequenceContext = SequencePlaybackContext(
        paths: paths,
        sound: sound,
        animal: animal,
        volumeOverride: null, // 不再需要
      );
      _sequenceIndex = 0;
      _isPlaying = true;
      unawaited(NativeLogger.log(
        scope: 'audio_controller:_startPlayback',
        level: 'debug',
        message: 'entering sequence mode',
        data: {
          'sequenceIndex': _sequenceIndex,
          'firstPath': paths.first,
        },
      ));
      await _playSequenceCurrent(generation);
      return;
    }

    _sequenceContext = null;
    _isInIntervalGap = false;
    _intervalTimer?.cancel();
    _intervalTimer = null;

    if (prefs.intervalSeconds > 0) {
      // 有间隔时间：使用 LoopMode.off，播完一次后暂停间隔再重播
      _isPlaying = true;
      unawaited(NativeLogger.log(
        scope: 'audio_controller:_startPlayback',
        level: 'debug',
        message: 'entering single interval loop mode',
        data: {
          'assetPath': paths.first,
          'intervalSeconds': prefs.intervalSeconds,
        },
      ));
      await _playAsset(
        assetPath: paths.first,
        generation: generation,
        loopMode: LoopMode.off,
        onCompleted: () => _onIntervalLoopCompleted(generation),
      );
    } else {
      // 无间隔时间：持续循环
      _isPlaying = true;
      unawaited(NativeLogger.log(
        scope: 'audio_controller:_startPlayback',
        level: 'debug',
        message: 'entering single loop mode',
        data: {
          'assetPath': paths.first,
        },
      ));
      await _playAsset(
        assetPath: paths.first,
        generation: generation,
        loopMode: LoopMode.one,
      );
    }
  }

  Future<void> _playSequenceCurrent(int generation) async {
    final context = _sequenceContext;
    if (context == null || !_isActiveGeneration(generation)) return;
    if (_sequenceIndex >= context.paths.length) {
      _sequenceIndex = 0;
    }
    final assetPath = context.paths[_sequenceIndex];
    unawaited(NativeLogger.log(
      scope: 'audio_controller:_playSequenceCurrent',
      level: 'debug',
      message: 'playing sequence item',
      data: {
        'sequenceIndex': _sequenceIndex,
        'totalPaths': context.paths.length,
        'assetPath': assetPath,
        'generation': generation,
      },
    ));
    await _playAsset(
      assetPath: assetPath,
      generation: generation,
      loopMode: LoopMode.off,
    );
  }

  /// 间隔循环模式下的单曲播放完成后回调
  Future<void> _onIntervalLoopCompleted(int generation) async {
    if (!_isActiveGeneration(generation) || !_isPlaying) return;

    unawaited(NativeLogger.log(
      scope: 'audio_controller:_onIntervalLoopCompleted',
      level: 'debug',
      message: 'track completed, entering interval gap',
      data: {
        'generation': generation,
        'intervalSeconds': prefs.intervalSeconds,
      },
    ));

    // 进入间隔暂停
    _isInIntervalGap = true;
    _isPlaying = false;
    final intervalSec = prefs.intervalSeconds;
    _intervalTimer?.cancel();
    _intervalTimer = Timer(Duration(milliseconds: (intervalSec * 1000).round()), () {
      _intervalTimer = null;
      if (!_isActiveGeneration(generation)) return;

      unawaited(NativeLogger.log(
        scope: 'audio_controller:_onIntervalLoopCompleted',
        level: 'debug',
        message: 'interval gap ended, restarting playback',
        data: {'generation': generation},
      ));

      _isInIntervalGap = false;
      _isPlaying = true;
      unawaited(_enqueue(() async {
        if (!_isActiveGeneration(generation) || !_isPlaying) return;
        final player = _player;
        if (player == null) return;
        try {
          await player.seek(Duration.zero);
          if (!_isCurrentPlayer(player, generation)) return;
          unawaited(player.play().catchError((Object error, StackTrace stackTrace) async {
            debugPrint('间隔后恢复播放失败: $error');
          }));
        } catch (e) {
          debugPrint('间隔后恢复播放失败: $e');
        }
      }));
    });
  }

  Future<void> _playAsset({
    required String assetPath,
    required int generation,
    required LoopMode loopMode,
    VoidCallback? onCompleted,
  }) async {
    final player = _player ??= AudioPlayer();
    await _playerStateSub?.cancel();
    _playerStateSub = null;
    await _safeStop(player);
    _currentAssetPath = assetPath;

    final configured = await _configurePlayer(
      player: player,
      assetPath: assetPath,
      loopMode: loopMode,
      generation: generation,
    );
    if (configured != true || !_isCurrentPlayer(player, generation)) {
      return;
    }

    _playerStateSub = player.playerStateStream.listen((state) {
      if (!_isCurrentPlayer(player, generation)) return;
      if (state.processingState != ProcessingState.completed) return;

      // 优先处理间隔循环模式的完成回调
      if (onCompleted != null) {
        onCompleted();
        return;
      }

      // 序列播放模式
      if (_sequenceContext == null) return;
      _sequenceIndex++;
      unawaited(NativeLogger.log(
        scope: 'audio_controller:_onPlaybackCompleted',
        level: 'debug',
        message: 'track completed, advancing sequence',
        data: {
          'completedAssetPath': assetPath,
          'nextSequenceIndex': _sequenceIndex,
          'totalPaths': _sequenceContext!.paths.length,
          'generation': generation,
        },
      ));
      unawaited(_enqueue(() async {
        if (!_isCurrentPlayer(player, generation)) return;
        await _disposeCurrentPlayer(clearAssetPath: false);
        if (!_isActiveGeneration(generation) || !_isPlaying) return;
        await _playSequenceCurrent(generation);
      }));
    });

    try {
      unawaited(player.play().catchError((Object error, StackTrace stackTrace) async {
        debugPrint('音频播放失败: $assetPath, 错误: $error');
        await _enqueue(() async {
          if (_isCurrentPlayer(player, generation)) {
            _autoStop.cancel();
            await _disposeCurrentPlayer();
          } else {
            await _safeStop(player);
          }
        });
      }));
      if (!_isCurrentPlayer(player, generation)) {
        await _safeStop(player);
        return;
      }
      _isPlaying = true;
    } catch (e) {
      debugPrint('音频播放失败: $assetPath, 错误: $e');
      if (_isCurrentPlayer(player, generation)) {
        _autoStop.cancel();
        await _disposeCurrentPlayer();
      } else {
        await _safeStop(player);
      }
    }
  }

  Future<bool?> _configurePlayer({
    required AudioPlayer player,
    required String assetPath,
    required LoopMode loopMode,
    required int generation,
  }) async {
    try {
      await player.setAsset(assetPath);
      if (!_isCurrentPlayer(player, generation)) {
        await _safeStop(player);
        return null;
      }
      // 应用音量始终为 1.0（满格），实际音量由系统控制
      await player.setVolume(_appVolume);
      if (!_isCurrentPlayer(player, generation)) {
        await _safeStop(player);
        return null;
      }
      await player.setLoopMode(loopMode);
      if (!_isCurrentPlayer(player, generation)) {
        await _safeStop(player);
        return null;
      }
      return true;
    } catch (e) {
      debugPrint('音频播放失败: $assetPath, 错误: $e');
      await _safeStop(player);
      return false;
    }
  }

  Future<void> pause() async {
    await _enqueue(_pauseInternal);
  }

  Future<void> _pauseInternal() async {
    final player = _player;
    _autoStop.pause();
    // 暂停间隔定时器
    _intervalTimer?.cancel();
    _intervalTimer = null;
    _isInIntervalGap = false;
    if (player != null && player.playing) {
      unawaited(player.pause().catchError((Object error, StackTrace stackTrace) async {
        debugPrint('音频暂停失败: $error');
      }));
    }
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _enqueue(_resumeInternal);
  }

  Future<void> _resumeInternal() async {
    final player = _player;
    if (player != null) {
      try {
        if (player.processingState == ProcessingState.idle ||
            player.processingState == ProcessingState.loading) {
          final assetPath = _currentAssetPath;
          if (assetPath != null) {
            await player.setAsset(assetPath);
            await player.seek(Duration.zero);
          }
        }
        // 恢复播放时检查系统音量
        await ensureMinSystemVolume();

        // 如果当前处于间隔暂停中，重新启动间隔定时器
        if (_isInIntervalGap && prefs.intervalSeconds > 0) {
          final intervalSec = prefs.intervalSeconds;
          _intervalTimer?.cancel();
          _intervalTimer = Timer(Duration(milliseconds: (intervalSec * 1000).round()), () {
            _intervalTimer = null;
            if (!_isActiveGeneration(_playbackGeneration)) return;
            _isInIntervalGap = false;
            _isPlaying = true;
            unawaited(_enqueue(() async {
              final p = _player;
              if (p == null) return;
              try {
                await p.seek(Duration.zero);
                unawaited(p.play().catchError((Object error, StackTrace stackTrace) async {
                  debugPrint('间隔后恢复播放失败: $error');
                }));
              } catch (e) {
                debugPrint('间隔后恢复播放失败: $e');
              }
            }));
          });
          return;
        }

        _resumeAutoStopAfterPause();
        unawaited(player.play().catchError((Object error, StackTrace stackTrace) async {
          debugPrint('音频恢复失败: $error');
        }));
        _isPlaying = true;
        return;
      } catch (e) {
        debugPrint('音频恢复失败: $e');
        _isPlaying = false;
      }
    }
    if (_sequenceContext != null) {
      _isPlaying = true;
      _resumeAutoStopAfterPause();
      await _playSequenceCurrent(_playbackGeneration);
    }
  }

  Future<void> togglePlay() async {
    await _enqueue(() async {
      if (_isPlaying) {
        await _pauseInternal();
      } else {
        await _resumeInternal();
      }
    });
  }

  Future<void> stop() async {
    await _enqueue(_stopInternal);
  }

  Future<void> _stopInternal() async {
    _invalidatePlayback();
    _isPlaying = false;
    _autoStop.cancel();
    _isInIntervalGap = false;
    _intervalTimer?.cancel();
    _intervalTimer = null;
    _sequenceContext = null;
    _sequenceIndex = 0;
    _currentSound = null;
    _currentAssetPath = null;
    // 停止播放后重置手动音量标记，下次播放时允许自动调大
    _userManuallySetVolume = false;
    await _disposeCurrentPlayer();
  }

  Future<void> stopAndClear() async {
    await _enqueue(() async {
      await _stopInternal();
      _currentAnimal = null;
    });
  }

  /// 设置应用音量 - 现在改为设置系统音量
  Future<void> setVolume(double volume) async {
    await setSystemVolume(volume);
  }

  Future<void> dispose() async {
    await _enqueue(() async {
      await _stopInternal();
      _currentAnimal = null;
      final player = _player;
      _player = null;
      if (player != null) {
        await _safeStopAndDispose(player);
      }
    });
  }

  Future<void> _disposeCurrentPlayer({
    bool clearAssetPath = true,
    bool disposePlayer = false,
  }) async {
    final player = _player;
    await _playerStateSub?.cancel();
    _playerStateSub = null;
    _intervalTimer?.cancel();
    _intervalTimer = null;
    _isInIntervalGap = false;
    if (clearAssetPath) {
      _currentAssetPath = null;
    }
    if (player != null) {
      await _safeStop(player);
      if (disposePlayer) {
        _player = null;
        await _safeStopAndDispose(player);
      }
    }
  }

  Future<void> _safeStop(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> _safeStopAndDispose(AudioPlayer player) async {
    await _safeStop(player);
    try {
      await player.dispose();
    } catch (_) {}
  }

  Duration? _configuredAutoStopDuration() {
    final minutes = prefs.autoStopMinutes;
    if (minutes <= 0) return null;
    return Duration(minutes: minutes);
  }

  void _scheduleAutoStopForNewPlayback() {
    final duration = _configuredAutoStopDuration();
    if (duration == null) {
      _autoStop.cancel();
      return;
    }
    _autoStop.start(
      duration: duration,
      onElapsed: _handleAutoStopElapsed,
    );
  }

  void _resumeAutoStopAfterPause() {
    final duration = _configuredAutoStopDuration();
    if (duration == null) {
      _autoStop.cancel();
      return;
    }
    if (_autoStop.hasRemaining) {
      _autoStop.resume(_handleAutoStopElapsed);
      return;
    }
    _autoStop.start(
      duration: duration,
      onElapsed: _handleAutoStopElapsed,
    );
  }

  void _handleAutoStopElapsed() {
    unawaited(NativeLogger.log(
      scope: 'audio_controller:auto_stop',
      level: 'info',
      message: 'auto stop elapsed, stopping playback',
      data: {
        'animalId': _currentAnimal?.id,
        'soundGroup': _currentSound?.soundGroup,
      },
    ));
    unawaited(_enqueue(_stopInternal));
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final completer = Completer<void>();
    _operationQueue = _operationQueue.catchError((_) {}).then((_) async {
      try {
        await action();
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  int _invalidatePlayback() => ++_playbackGeneration;

  bool _isActiveGeneration(int generation) => generation == _playbackGeneration;

  bool _isCurrentPlayer(AudioPlayer player, int generation) {
    return identical(_player, player) && generation == _playbackGeneration;
  }
}

final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController.instance;
});
