import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';

/// 声波示意卡片
///
/// 当前页面没有真实 PCM 数据，这里根据频率范围、分贝和音量生成一个可读的示意波形，
/// 让用户更直观看到当前声音的大致强弱和频谱倾向。
class SoundWaveformCard extends StatelessWidget {
  final String title;
  final String frequencyLabel;
  final double estimatedDb;
  final double volume;
  final Color accentColor;
  final bool isPlaying;
  final Animation<double> animation;
  final bool isZh; // keep for backward compat, no longer used internally
  final bool compact;

  const SoundWaveformCard({
    super.key,
    required this.title,
    required this.frequencyLabel,
    required this.estimatedDb,
    required this.volume,
    required this.accentColor,
    required this.isPlaying,
    required this.animation,
    this.isZh = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final profile = _WaveProfile.fromFrequencyRange(frequencyLabel);
    final outputDb = estimatedDb * volume.clamp(0.0, 1.0);
    final intensity = (outputDb / 100).clamp(0.0, 1.0);
    final badgeColor =
        Color.lerp(Colors.blue, accentColor, intensity) ?? accentColor;
    final waveformHeight = compact ? 76.0 : 120.0;
    final cardPadding = compact ? 12.0 : 16.0;
    final iconSize = compact ? 30.0 : 34.0;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: compact ? 13 : 15,
    );
    final subtitleStyle = TextStyle(
      fontSize: compact ? 11 : 12,
      color: AppColors.textSecondary,
    );

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.08),
            Colors.white,
            badgeColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.multitrack_audio_rounded,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.waveformPreview,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              _MetricBadge(
                label: s.output,
                value: '${outputDb.round()} dB',
                color: badgeColor,
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Container(
            height: waveformHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _WaveformPainter(
                    accentColor: accentColor,
                    profile: profile,
                    intensity: intensity,
                    phase: isPlaying ? animation.value : 0,
                    animate: isPlaying,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricBadge(
                label: s.freq,
                value: frequencyLabel,
                color: Colors.purple,
              ),
              _MetricBadge(
                label: s.intensity,
                value: _describeIntensity(intensity, s),
                color: accentColor,
              ),
              _MetricBadge(
                label: s.shape,
                value: _describeTone(profile.centerBias, s),
                color: Colors.blue,
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Text(
              isPlaying
                  ? s.waveformPlayingDesc
                  : s.waveformStaticDesc,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  String _describeIntensity(double value, S s) {
    if (value < 0.28) return s.intensitySoft;
    if (value < 0.5) return s.intensityBalanced;
    if (value < 0.72) return s.intensityStrong;
    return s.intensityPowerful;
  }

  String _describeTone(double centerBias, S s) {
    if (centerBias < 0.25) return s.toneBassLed;
    if (centerBias < 0.55) return s.toneMidBalanced;
    if (centerBias < 0.78) return s.toneTrebleClear;
    return s.toneUltraHigh;
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveProfile {
  final double centerBias;
  final double bandwidth;

  const _WaveProfile({
    required this.centerBias,
    required this.bandwidth,
  });

  factory _WaveProfile.fromFrequencyRange(String label) {
    final matches = RegExp(r'(\d+(?:\.\d+)?)\s*(k?Hz)', caseSensitive: false)
        .allMatches(label);
    if (matches.isEmpty) {
      return const _WaveProfile(centerBias: 0.45, bandwidth: 0.35);
    }

    final values = matches.map((match) {
      final raw = double.tryParse(match.group(1) ?? '') ?? 0;
      final unit = (match.group(2) ?? '').toLowerCase();
      return unit.startsWith('k') ? raw * 1000 : raw;
    }).toList()
      ..sort();

    final minHz = values.first.clamp(20, 22000).toDouble();
    final maxHz = values.last.clamp(20, 22000).toDouble();
    final center = (minHz + maxHz) / 2;
    final width = ((maxHz - minHz) / 22000).clamp(0.08, 1.0);

    return _WaveProfile(
      centerBias: _normalizeLog(center),
      bandwidth: width,
    );
  }

  static double _normalizeLog(double hz) {
    const minHz = 20.0;
    const maxHz = 22000.0;
    final numerator = math.log(hz / minHz);
    final denominator = math.log(maxHz / minHz);
    return (numerator / denominator).clamp(0.0, 1.0);
  }
}

class _WaveformPainter extends CustomPainter {
  final Color accentColor;
  final _WaveProfile profile;
  final double intensity;
  final double phase;
  final bool animate;

  const _WaveformPainter({
    required this.accentColor,
    required this.profile,
    required this.intensity,
    required this.phase,
    required this.animate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final framePhase = phase * math.pi * 2;

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final baselinePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..strokeWidth = 1.2;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
        Offset(0, centerY), Offset(size.width, centerY), baselinePaint);

    final amplitudeBase = size.height * (0.16 + intensity * 0.22);
    final mainFrequency = 1.8 + profile.centerBias * 4.6;
    final detailFrequency = 4.5 + profile.bandwidth * 7.0;
    final wavePath = Path();
    final fillPath = Path()..moveTo(0, centerY);

    for (var i = 0; i <= 96; i++) {
      final x = size.width * i / 96;
      final t = x / size.width;
      final envelope = 0.72 + math.sin((t * math.pi * 2) + framePhase) * 0.14;
      final primary = math.sin((t * math.pi * 2 * mainFrequency) + framePhase);
      final harmonic =
          math.sin((t * math.pi * 2 * detailFrequency) - framePhase * 0.7) *
              0.34;
      final shimmer = animate
          ? math.sin((t * math.pi * 14) + framePhase * 1.8) * 0.06
          : 0.0;
      final y =
          centerY - amplitudeBase * envelope * (primary + harmonic + shimmer);

      if (i == 0) {
        wavePath.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        wavePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(size.width, centerY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.28),
          accentColor.withValues(alpha: 0.05),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final wavePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.75),
          Color.lerp(accentColor, Colors.white, 0.25) ?? accentColor,
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: animate ? 0.14 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(wavePath, glowPaint);
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.intensity != intensity ||
        oldDelegate.animate != animate ||
        oldDelegate.profile.centerBias != profile.centerBias ||
        oldDelegate.profile.bandwidth != profile.bandwidth ||
        oldDelegate.accentColor != accentColor;
  }
}
