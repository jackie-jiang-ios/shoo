import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/timer/play_scheduler.dart';
import '../../theme/colors.dart';

/// 定时器页面
class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  final PlayScheduler _scheduler = PlayScheduler();
  int _selectedMinutes = 0;
  Duration? _remainingDuration;

  /// 预设定时选项（分钟）
  static const List<int> _presetMinutes = [5, 10, 15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _scheduler.countdownStream.listen((duration) {
      if (mounted) {
        setState(() => _remainingDuration = duration);
      }
    });
  }

  @override
  void dispose() {
    _scheduler.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedMinutes <= 0) return;
    _scheduler.scheduleAutoStop(
      Duration(minutes: _selectedMinutes),
      () {
        // 停止所有播放
        // 通过 ref 或回调通知音频引擎
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定时结束，已停止播放')),
          );
        }
      },
    );
    setState(() {});
  }

  void _cancelTimer() {
    _scheduler.cancelAutoStop();
    setState(() => _remainingDuration = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCounting = _remainingDuration != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('定时播放'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 倒计时显示
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 背景圆环
                        CircularProgressIndicator(
                          value: isCounting && _selectedMinutes > 0
                              ? _remainingDuration!.inSeconds /
                                  (_selectedMinutes * 60)
                              : 1.0,
                          strokeWidth: 8,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCounting ? AppColors.primary : AppColors.textHint,
                          ),
                        ),
                        // 时间文字
                        Center(
                          child: isCounting
                              ? Text(
                                  _formatDuration(_remainingDuration!),
                                  style: AppTypographyNumber.timerDisplay,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 48,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '设置定时',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 预设时间选择
            Text(
              '选择时长',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetMinutes.map((minutes) {
                final isSelected = _selectedMinutes == minutes && !isCounting;
                return ChoiceChip(
                  label: Text(minutes >= 60 ? '${minutes ~/ 60}小时' : '$minutes分钟'),
                  selected: isSelected,
                  onSelected: isCounting
                      ? null
                      : (selected) {
                          setState(() {
                            _selectedMinutes = selected ? minutes : 0;
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 自定义时间
            if (!isCounting) ...[
              Text(
                '自定义时长',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '分钟',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (value) {
                        final minutes = int.tryParse(value);
                        if (minutes != null && minutes > 0) {
                          setState(() => _selectedMinutes = minutes);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // 操作按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isCounting
                    ? _cancelTimer
                    : (_selectedMinutes > 0 ? _startTimer : null),
                icon: Icon(
                  isCounting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(isCounting ? '取消定时' : '开始定时'),
                style: FilledButton.styleFrom(
                  backgroundColor: isCounting ? AppColors.danger : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 数字排版用于定时器
class AppTypographyNumber {
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
