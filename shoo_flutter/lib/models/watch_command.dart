/// 手表通信协议 - 手机 → 手表
class WatchCommand {
  final String type;
  final String? soundId;
  final double? volume;
  final String? mode;
  final List<SoundInfo>? sounds;

  const WatchCommand({
    required this.type,
    this.soundId,
    this.volume,
    this.mode,
    this.sounds,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (soundId != null) json['soundId'] = soundId;
    if (volume != null) json['volume'] = volume;
    if (mode != null) json['mode'] = mode;
    if (sounds != null) {
      json['sounds'] = sounds!.map((s) => s.toJson()).toList();
    }
    return json;
  }

  factory WatchCommand.fromJson(Map<String, dynamic> json) {
    return WatchCommand(
      type: json['type'] as String,
      soundId: json['soundId'] as String?,
      volume: (json['volume'] as num?)?.toDouble(),
      mode: json['mode'] as String?,
      sounds: (json['sounds'] as List<dynamic>?)
          ?.map((e) => SoundInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 播放命令
  factory WatchCommand.play({
    required String soundId,
    required double volume,
    required String mode,
  }) {
    return WatchCommand(
      type: 'play',
      soundId: soundId,
      volume: volume,
      mode: mode,
    );
  }

  /// 停止命令
  factory WatchCommand.stop({required String soundId}) {
    return WatchCommand(
      type: 'stop',
      soundId: soundId,
    );
  }

  /// 停止所有
  factory WatchCommand.stopAll() {
    return const WatchCommand(type: 'stop_all');
  }

  /// 同步声音列表
  factory WatchCommand.syncSounds(List<SoundInfo> sounds) {
    return WatchCommand(
      type: 'sync_sounds',
      sounds: sounds,
    );
  }
}

/// 手表通信协议 - 手表 → 手机
class PhoneCommand {
  final String type;
  final String? soundId;
  final double? volume;
  final bool? playing;
  final double? elapsed;
  final List<String>? soundIds;

  const PhoneCommand({
    required this.type,
    this.soundId,
    this.volume,
    this.playing,
    this.elapsed,
    this.soundIds,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (soundId != null) json['soundId'] = soundId;
    if (volume != null) json['volume'] = volume;
    if (playing != null) json['playing'] = playing;
    if (elapsed != null) json['elapsed'] = elapsed;
    if (soundIds != null) json['soundIds'] = soundIds;
    return json;
  }

  factory PhoneCommand.fromJson(Map<String, dynamic> json) {
    return PhoneCommand(
      type: json['type'] as String,
      soundId: json['soundId'] as String?,
      volume: (json['volume'] as num?)?.toDouble(),
      playing: json['playing'] as bool?,
      elapsed: (json['elapsed'] as num?)?.toDouble(),
      soundIds: (json['soundIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// 遥控播放
  factory PhoneCommand.remotePlay({
    required String soundId,
    required double volume,
  }) {
    return PhoneCommand(
      type: 'remote_play',
      soundId: soundId,
      volume: volume,
    );
  }

  /// 状态上报
  factory PhoneCommand.status({
    required bool playing,
    String? soundId,
    double? elapsed,
  }) {
    return PhoneCommand(
      type: 'status',
      playing: playing,
      soundId: soundId,
      elapsed: elapsed,
    );
  }

  /// 紧急求救
  factory PhoneCommand.emergency({
    required List<String> soundIds,
    required double volume,
  }) {
    return PhoneCommand(
      type: 'emergency',
      soundIds: soundIds,
      volume: volume,
    );
  }
}

/// 声音信息（用于通信协议）
class SoundInfo {
  final String id;
  final String name;
  final String category;
  final double duration;

  const SoundInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'duration': duration,
      };

  factory SoundInfo.fromJson(Map<String, dynamic> json) {
    return SoundInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      duration: (json['duration'] as num).toDouble(),
    );
  }
}
