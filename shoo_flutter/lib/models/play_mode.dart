/// 播放模式
enum PlayMode {
  /// 持续播放
  continuous('continuous', const {'zh': '持续播放', 'en': 'Continuous', 'ja': '連続再生', 'ko': '연속 재생', 'fr': 'Continu', 'de': 'Durchgehend', 'es': 'Continuo', 'ru': 'Непрерывный', 'pt': 'Contínuo', 'th': 'เล่นต่อเนื่อง'}),

  /// 间隔播放
  interval('interval', const {'zh': '间隔播放', 'en': 'Interval', 'ja': '間隔再生', 'ko': '간격 재생', 'fr': 'Intervalle', 'de': 'Intervall', 'es': 'Intervalo', 'ru': 'Интервальный', 'pt': 'Intervalado', 'th': 'เล่นเว้นช่วง'}),

  const PlayMode(
    this.id,
    this.nameMap,
  );

  final String id;
  final Map<String, String> nameMap;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) {
    return nameMap[langCode] ?? nameMap['en'] ?? nameMap.values.first;
  }

  /// 间隔播放的默认间隔时间（秒）
  static const double defaultIntervalSeconds = 3.0;

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
  final Duration? autoStopDuration; // 自动停止时间

  const PlayConfig({
    this.mode = PlayMode.continuous,
    this.volume = 0.8,
    this.intervalSeconds = PlayMode.defaultIntervalSeconds,
    this.autoStopDuration,
  });

  PlayConfig copyWith({
    PlayMode? mode,
    double? volume,
    double? intervalSeconds,
    Duration? Function()? autoStopDuration,
  }) {
    return PlayConfig(
      mode: mode ?? this.mode,
      volume: volume ?? this.volume,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      autoStopDuration:
          autoStopDuration != null ? autoStopDuration() : this.autoStopDuration,
    );
  }
}
