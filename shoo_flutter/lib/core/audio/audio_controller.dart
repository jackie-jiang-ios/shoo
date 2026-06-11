import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/animal.dart';

/// 全局音频控制器
/// 管理动物驱赶声音的播放、停止、音量控制
/// 支持单个播放和连续播放模式
class AudioController {
  AudioController._();
  static final AudioController instance = AudioController._();

  /// 当前正在播放的 AudioPlayer 列表（连续模式时会有多个）
  final List<AudioPlayer> _players = [];

  /// 当前正在播放的声音
  RecommendedSound? _currentSound;

  /// 当前关联的动物
  Animal? _currentAnimal;

  /// 是否正在播放
  bool _isPlaying = false;

  /// 连续播放时的当前索引
  int _sequenceIndex = 0;

  bool get isPlaying => _isPlaying;
  RecommendedSound? get currentSound => _currentSound;
  Animal? get currentAnimal => _currentAnimal;

  /// 使用指定音量播放声音
  Future<void> playWithVolume(Animal animal, RecommendedSound sound, double volume) async {
    // 停止当前播放
    await stop();

    _currentAnimal = animal;
    _currentSound = sound;

    final paths = sound.assetPaths;
    if (paths.isEmpty) return;

    if (sound.playMode == SoundPlayMode.sequence && paths.length > 1) {
      await _playSequenceWithVolume(paths, sound, animal, volume);
    } else {
      await _playSingleWithVolume(paths.first, sound, animal, volume);
    }
  }

  /// 播放指定声音
  Future<void> play(Animal animal, RecommendedSound sound) async {
    // 停止当前播放
    await stop();

    _currentAnimal = animal;
    _currentSound = sound;

    final paths = sound.assetPaths;
    if (paths.isEmpty) return;

    if (sound.playMode == SoundPlayMode.sequence && paths.length > 1) {
      // 连续播放模式：依次播放组内所有声音
      await _playSequence(paths, sound, animal);
    } else {
      // 单个播放模式
      await _playSingle(paths.first, sound, animal);
    }
  }

  /// 单个声音播放（循环）
  Future<void> _playSingle(String assetPath, RecommendedSound sound, Animal animal) async {
    final player = AudioPlayer();
    try {
      await player.setAsset(assetPath);
      await player.setVolume(sound.volumeWeight * animal.recommendedVolume);
      await player.setLoopMode(LoopMode.one);
      await player.play();

      _players.add(player);
      _isPlaying = true;
    } catch (e) {
      print('音频播放失败: $assetPath, 错误: $e');
      await player.dispose();
    }
  }

  /// 连续播放模式：依次播放组内所有声音，全部播完后循环
  Future<void> _playSequence(List<String> paths, RecommendedSound sound, Animal animal) async {
    _sequenceIndex = 0;
    await _playNextInSequence(paths, sound, animal);
  }

  Future<void> _playNextInSequence(List<String> paths, RecommendedSound sound, Animal animal) async {
    if (!_isPlaying && _players.isNotEmpty) return;
    if (_sequenceIndex >= paths.length) {
      // 一轮播完，重新开始
      _sequenceIndex = 0;
    }

    final player = AudioPlayer();
    final assetPath = paths[_sequenceIndex];
    try {
      await player.setAsset(assetPath);
      await player.setVolume(sound.volumeWeight * animal.recommendedVolume);
      await player.setLoopMode(LoopMode.off);

      // 监听播放完成事件，播下一个
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _players.remove(player);
          player.dispose();
          _sequenceIndex++;
          if (_isPlaying) {
            _playNextInSequence(paths, sound, animal);
          }
        }
      });

      await player.play();
      _players.add(player);
      _isPlaying = true;
    } catch (e) {
      print('音频播放失败: $assetPath, 错误: $e');
      await player.dispose();
      // 尝试播放下一个
      _sequenceIndex++;
      if (_isPlaying) {
        await _playNextInSequence(paths, sound, animal);
      }
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    for (final player in _players) {
      if (player.playing) {
        await player.pause();
      }
    }
    _isPlaying = false;
  }

  /// 恢复播放
  Future<void> resume() async {
    for (final player in _players) {
      if (!player.playing) {
        await player.play();
      }
    }
    _isPlaying = true;
  }

  /// 切换播放/暂停
  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// 停止播放
  Future<void> stop() async {
    _isPlaying = false;
    for (final player in _players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
    _currentSound = null;
    _sequenceIndex = 0;
  }

  /// 完全停止并清空状态
  Future<void> stopAndClear() async {
    await stop();
    _currentAnimal = null;
  }

  /// 单个声音播放（循环），使用指定音量
  Future<void> _playSingleWithVolume(String assetPath, RecommendedSound sound, Animal animal, double volume) async {
    final player = AudioPlayer();
    try {
      await player.setAsset(assetPath);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setLoopMode(LoopMode.one);
      await player.play();

      _players.add(player);
      _isPlaying = true;
    } catch (e) {
      print('音频播放失败: $assetPath, 错误: $e');
      await player.dispose();
    }
  }

  /// 连续播放模式，使用指定音量
  Future<void> _playSequenceWithVolume(List<String> paths, RecommendedSound sound, Animal animal, double volume) async {
    _sequenceIndex = 0;
    await _playNextInSequenceWithVolume(paths, sound, animal, volume);
  }

  Future<void> _playNextInSequenceWithVolume(List<String> paths, RecommendedSound sound, Animal animal, double volume) async {
    if (!_isPlaying && _players.isNotEmpty) return;
    if (_sequenceIndex >= paths.length) {
      _sequenceIndex = 0;
    }

    final player = AudioPlayer();
    final assetPath = paths[_sequenceIndex];
    try {
      await player.setAsset(assetPath);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setLoopMode(LoopMode.off);

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _players.remove(player);
          player.dispose();
          _sequenceIndex++;
          if (_isPlaying) {
            _playNextInSequenceWithVolume(paths, sound, animal, volume);
          }
        }
      });

      await player.play();
      _players.add(player);
      _isPlaying = true;
    } catch (e) {
      print('音频播放失败: $assetPath, 错误: $e');
      await player.dispose();
      _sequenceIndex++;
      if (_isPlaying) {
        await _playNextInSequenceWithVolume(paths, sound, animal, volume);
      }
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    for (final player in _players) {
      await player.setVolume(volume.clamp(0.0, 1.0));
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await stopAndClear();
  }
}

/// Riverpod Provider
final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController.instance;
});
