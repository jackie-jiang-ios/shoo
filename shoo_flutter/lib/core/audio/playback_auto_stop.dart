import 'dart:async';

import 'package:flutter/foundation.dart';

/// 管理一次播放会话的自动停止计时。
class PlaybackAutoStop {
  Timer? _timer;
  DateTime? _deadline;
  Duration? _remaining;

  bool get hasRemaining {
    final remaining = _remaining;
    return remaining != null && remaining > Duration.zero;
  }

  void start({
    required Duration duration,
    required VoidCallback onElapsed,
  }) {
    cancel();
    if (duration <= Duration.zero) return;
    _arm(duration, onElapsed);
  }

  void pause() {
    final deadline = _deadline;
    if (deadline == null) return;

    final remaining = deadline.difference(DateTime.now());
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    _remaining = remaining > Duration.zero ? remaining : Duration.zero;
  }

  void resume(VoidCallback onElapsed) {
    final remaining = _remaining;
    if (remaining == null || remaining <= Duration.zero) return;
    _arm(remaining, onElapsed);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    _remaining = null;
  }

  void _arm(Duration duration, VoidCallback onElapsed) {
    _remaining = duration;
    _deadline = DateTime.now().add(duration);
    _timer = Timer(duration, () {
      _timer = null;
      _deadline = null;
      _remaining = Duration.zero;
      onElapsed();
    });
  }
}
