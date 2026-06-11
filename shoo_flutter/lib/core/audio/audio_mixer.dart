import 'audio_engine.dart';
import '../../models/sound.dart';
import '../../models/play_mode.dart';

/// 音频混合器
///
/// 管理多声音同时播放的场景。
/// 提供混合预设、独立音量控制等功能。
class AudioMixer {
  final AudioEngine _engine;

  AudioMixer(this._engine);

  /// 获取播放状态流
  Stream<Map<String, SoundPlayState>> get stateStream => _engine.stateStream;

  /// 当前播放状态
  Map<String, SoundPlayState> get playStates => _engine.playStates;

  /// 是否有声音在播放
  bool get isPlaying => _engine.isPlaying;

  /// 播放单个声音
  Future<void> playSound(Sound sound, {PlayConfig? config}) async {
    await _engine.play(sound, config: config);
  }

  /// 同时播放多个声音
  Future<void> playMix(List<Sound> sounds, {PlayConfig? config}) async {
    for (final sound in sounds) {
      await _engine.play(sound, config: config);
    }
  }

  /// 停止指定声音
  Future<void> stopSound(String soundId) async {
    await _engine.stop(soundId);
  }

  /// 停止所有声音
  Future<void> stopAll() async {
    await _engine.stopAll();
  }

  /// 设置指定声音的音量
  Future<void> setVolume(String soundId, double volume) async {
    await _engine.setVolume(soundId, volume);
  }

  /// 设置所有声音的音量
  Future<void> setMasterVolume(double volume) async {
    for (final state in _engine.playStates.values) {
      await _engine.setVolume(state.sound.id, volume);
    }
  }

  /// 设置指定声音的播放模式
  Future<void> setPlayMode(String soundId, PlayMode mode) async {
    await _engine.setPlayMode(soundId, mode);
  }

  /// 获取当前混合中的声音列表
  List<Sound> get activeSounds =>
      _engine.playStates.values
          .where((s) => s.state == PlayState.playing || s.state == PlayState.inGap)
          .map((s) => s.sound)
          .toList();

  /// 保存混合预设
  MixPreset createPreset(String name, List<MixItem> items) {
    return MixPreset(
      name: name,
      items: items,
    );
  }
}

/// 混合项
class MixItem {
  final Sound sound;
  final double volume;
  final PlayMode mode;

  const MixItem({
    required this.sound,
    this.volume = 0.8,
    this.mode = PlayMode.continuous,
  });
}

/// 混合预设
class MixPreset {
  final String name;
  final List<MixItem> items;

  const MixPreset({
    required this.name,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items
            .map((i) => {
                  'soundId': i.sound.id,
                  'volume': i.volume,
                  'mode': i.mode.id,
                })
            .toList(),
      };
}
