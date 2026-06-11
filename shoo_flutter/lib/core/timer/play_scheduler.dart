import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/play_mode.dart';

/// 定时播放调度器
///
/// 支持以下功能：
/// - 定时自动停止播放
/// - 定时自动开始播放
/// - 倒计时显示
class PlayScheduler {
  Timer? _countdownTimer;
  Timer? _scheduledStartTimer;
  Duration? _remainingDuration;
  DateTime? _scheduledStartTime;

  final _countdownController = StreamController<Duration?>.broadcast();
  final _schedulerStateController = StreamController<SchedulerState>.broadcast();

  /// 倒计时流
  Stream<Duration?> get countdownStream => _countdownController.stream;

  /// 调度器状态流
  Stream<SchedulerState> get schedulerStateStream => _schedulerStateController.stream;

  /// 剩余时间
  Duration? get remainingDuration => _remainingDuration;

  /// 是否正在倒计时
  bool get isCountingDown => _countdownTimer != null && _countdownTimer!.isActive;

  /// 设置自动停止
  ///
  /// [duration] 播放持续时间，到达后触发 [onStop]
  void scheduleAutoStop(Duration duration, VoidCallback onStop) {
    cancelAutoStop();

    _remainingDuration = duration;
    _countdownController.add(_remainingDuration);
    _schedulerStateController.add(SchedulerState.countingDown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingDuration = _remainingDuration! - const Duration(seconds: 1);

      if (_remainingDuration!.isNegative || _remainingDuration == Duration.zero) {
        timer.cancel();
        _remainingDuration = Duration.zero;
        _countdownController.add(_remainingDuration);
        _schedulerStateController.add(SchedulerState.completed);
        onStop();
      } else {
        _countdownController.add(_remainingDuration);
      }
    });
  }

  /// 设置定时开始
  ///
  /// [startTime] 开始播放的时间
  void scheduleAutoStart(DateTime startTime, VoidCallback onStart) {
    cancelScheduledStart();

    _scheduledStartTime = startTime;
    final delay = startTime.difference(DateTime.now());

    if (delay.isNegative) {
      // 时间已过，立即执行
      onStart();
      return;
    }

    _schedulerStateController.add(SchedulerState.scheduled);

    _scheduledStartTimer = Timer(delay, () {
      _schedulerStateController.add(SchedulerState.completed);
      onStart();
    });
  }

  /// 取消自动停止
  void cancelAutoStop() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingDuration = null;
    _countdownController.add(null);
    _schedulerStateController.add(SchedulerState.idle);
  }

  /// 取消定时开始
  void cancelScheduledStart() {
    _scheduledStartTimer?.cancel();
    _scheduledStartTimer = null;
    _scheduledStartTime = null;
    _schedulerStateController.add(SchedulerState.idle);
  }

  /// 取消所有调度
  void cancelAll() {
    cancelAutoStop();
    cancelScheduledStart();
  }

  /// 释放资源
  void dispose() {
    cancelAll();
    _countdownController.close();
    _schedulerStateController.close();
  }
}

/// 调度器状态
enum SchedulerState {
  /// 空闲
  idle,

  /// 倒计时中
  countingDown,

  /// 已计划
  scheduled,

  /// 已完成
  completed,
}
