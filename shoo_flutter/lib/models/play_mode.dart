/// 播放模式
enum PlayMode {
  /// 持续播放
  continuous('continuous', '持续播放', 'Continuous'),

  /// 间隔播放
  interval('interval', '间隔播放', 'Interval'),

  /// 脉冲播放
  pulse('pulse', '脉冲播放', 'Pulse');

  const PlayMode(
    this.id,
    this.name,
    this.nameEn,
  );

  final String id;
  final String name;
  final String nameEn;

  /// 间隔播放的默认间隔时间（秒）
  static const double defaultIntervalSeconds = 3.0;

  /// 脉冲播放的默认脉冲持续时间（秒）
  static const double defaultPulseDuration = 0.5;

  /// 脉冲播放的默认脉冲间隔时间（秒）
  static const double defaultPulseGap = 1.0;
}

/// 播放状态
enum PlayState {
  /// 空闲
  idle,

  /// 播放中
  playing,

  /// 暂停
  paused,

  /// 间隔中
  inGap,
}

/// 播放配置
class PlayConfig {
  final PlayMode mode;
  final double volume; // 0.0 - 1.0
  final double intervalSeconds; // 间隔播放的间隔时间
  final double pulseDuration; // 脉冲持续时间
  final double pulseGap; // 脉冲间隔时间
  final Duration? autoStopDuration; // 自动停止时间

  const PlayConfig({
    this.mode = PlayMode.continuous,
    this.volume = 0.8,
    this.intervalSeconds = PlayMode.defaultIntervalSeconds,
    this.pulseDuration = PlayMode.defaultPulseDuration,
    this.pulseGap = PlayMode.defaultPulseGap,
    this.autoStopDuration,
  });

  PlayConfig copyWith({
    PlayMode? mode,
    double? volume,
    double? intervalSeconds,
    double? pulseDuration,
    double? pulseGap,
    Duration? Function()? autoStopDuration,
  }) {
    return PlayConfig(
      mode: mode ?? this.mode,
      volume: volume ?? this.volume,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      pulseDuration: pulseDuration ?? this.pulseDuration,
      pulseGap: pulseGap ?? this.pulseGap,
      autoStopDuration:
          autoStopDuration != null ? autoStopDuration() : this.autoStopDuration,
    );
  }
}
