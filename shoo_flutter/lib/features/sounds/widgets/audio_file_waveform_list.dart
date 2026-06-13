import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/animal.dart';
import '../../../theme/colors.dart';

class AudioFileWaveformList extends StatelessWidget {
  final RecommendedSound sound;
  final Color accentColor;
  final bool isZh; // keep for backward compat, no longer used internally
  final SoundPlayMode playMode;
  final bool isActiveSoundCard;
  final int selectedFileIndex;
  final Set<int> multiSelectedIndices;
  final String? currentAssetPath;
  final double playbackProgress;
  final bool isPlaybackActive;
  final ValueChanged<int> onFileTap;
  final ValueChanged<int>? onFileLongPress;

  const AudioFileWaveformList({
    super.key,
    required this.sound,
    required this.accentColor,
    this.isZh = false,
    required this.playMode,
    required this.isActiveSoundCard,
    required this.selectedFileIndex,
    this.multiSelectedIndices = const {0},
    required this.currentAssetPath,
    required this.playbackProgress,
    required this.isPlaybackActive,
    required this.onFileTap,
    this.onFileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, AudioWaveformData>>(
      future: AudioWaveformRepository.instance.load(),
      builder: (context, snapshot) {
        final waveforms = snapshot.data ?? const <String, AudioWaveformData>{};

        return Column(
          children: List.generate(sound.soundCount, (index) {
            final assetPath = sound.getAssetPath(index);
            final waveform = waveforms[assetPath];

            // 根据播放模式判断选中状态
            final bool isSelected;
            if (playMode == SoundPlayMode.single) {
              isSelected = selectedFileIndex == index;
            } else {
              isSelected = multiSelectedIndices.contains(index);
            }
            final isPageSelected = isActiveSoundCard && isSelected;
            final isCurrentlyPlaying =
                isPlaybackActive && currentAssetPath == assetPath;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == sound.soundCount - 1 ? 0 : 8),
              child: _AudioFileWaveformTile(
                title: _titleFor(context, index),
                subtitle: _subtitleFor(
                  context,
                  waveform,
                ),
                durationText: waveform != null
                    ? _formatDuration(waveform.durationSeconds)
                    : '--:--',
                peaks: waveform?.peaks ?? const [],
                accentColor: accentColor,
                isSelected: isPageSelected,
                isMultiSelectMode: playMode == SoundPlayMode.sequence,
                isCurrentlyPlaying: isCurrentlyPlaying,
                playbackProgress: isCurrentlyPlaying ? playbackProgress : 0,
                onTap: () => onFileTap(index),
                onLongPress: onFileLongPress != null
                    ? () => onFileLongPress!(index)
                    : null,
              ),
            );
          }),
        );
      },
    );
  }

  String _titleFor(BuildContext context, int index) {
    final s = S.of(context);
    return '${s.audioFile} ${index + 1}';
  }

  String _subtitleFor(BuildContext context, AudioWaveformData? waveform) {
    final s = S.of(context);
    if (waveform == null) {
      return s.generatingWaveform;
    }

    final duration = _formatDuration(waveform.durationSeconds);
    return '${s.switchAndPlay}  ·  $duration';
  }

  String _formatDuration(double seconds) {
    final totalSeconds = seconds.round();
    final minutes = totalSeconds ~/ 60;
    final remainSeconds = totalSeconds % 60;
    return '$minutes:${remainSeconds.toString().padLeft(2, '0')}';
  }
}

class _AudioFileWaveformTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String durationText;
  final List<double> peaks;
  final Color accentColor;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool isCurrentlyPlaying;
  final double playbackProgress;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _AudioFileWaveformTile({
    required this.title,
    required this.subtitle,
    required this.durationText,
    required this.peaks,
    required this.accentColor,
    required this.isSelected,
    this.isMultiSelectMode = false,
    required this.isCurrentlyPlaying,
    required this.playbackProgress,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? accentColor
        : (isDark ? Colors.grey.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.14));
    final waveformColor = isSelected
        ? accentColor
        : Color.lerp(accentColor, Colors.grey, 0.45) ?? accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              // 选中指示器：单选模式用 radio，多选模式用 checkbox
              if (isMultiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isSelected ? accentColor : (isDark ? AppColorsDark.textHint : Colors.grey[400]),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: waveformColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.music_note_rounded
                        : Icons.audio_file_rounded,
                    size: 18,
                    color: waveformColor,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.textPrimaryOf(context)
                            : (isDark ? AppColorsDark.textPrimary : const Color(0xFF303030)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _AudioFileWaveformPainter(
                          peaks: peaks,
                          color: waveformColor,
                          progress: playbackProgress,
                          isCurrentlyPlaying: isCurrentlyPlaying,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    durationText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: waveformColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCurrentlyPlaying)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded,
                            size: 11, color: accentColor),
                        const SizedBox(width: 2),
                        Text(
                          S.of(context).playing,
                          style: TextStyle(
                            fontSize: 10,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else if (isSelected)
                    Text(
                      S.of(context).selected,
                      style: TextStyle(
                        fontSize: 10,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioWaveformData {
  final double durationSeconds;
  final List<double> peaks;

  const AudioWaveformData({
    required this.durationSeconds,
    required this.peaks,
  });

  factory AudioWaveformData.fromJson(Map<String, dynamic> json) {
    return AudioWaveformData(
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0,
      peaks: ((json['peaks'] as List?) ?? const [])
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }
}

class AudioWaveformRepository {
  AudioWaveformRepository._();

  static final AudioWaveformRepository instance = AudioWaveformRepository._();
  static const _assetPath = 'assets/waveforms/audio_waveforms.json';

  Future<Map<String, AudioWaveformData>>? _cache;

  Future<Map<String, AudioWaveformData>> load() {
    return _cache ??= _loadInternal();
  }

  Future<Map<String, AudioWaveformData>> _loadInternal() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        AudioWaveformData.fromJson(value as Map<String, dynamic>),
      ),
    );
  }
}

class _AudioFileWaveformPainter extends CustomPainter {
  final List<double> peaks;
  final Color color;
  final double progress;
  final bool isCurrentlyPlaying;

  const _AudioFileWaveformPainter({
    required this.peaks,
    required this.color,
    required this.progress,
    required this.isCurrentlyPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero.translate(0, centerY),
        Offset(size.width, centerY), linePaint);

    if (peaks.isEmpty) return;

    const gap = 1.6;
    final barWidth = math.max(
      1.2,
      (size.width - (peaks.length - 1) * gap) / peaks.length,
    );
    final playedBarPaint = Paint()
      ..color = color.withValues(alpha: 0.98)
      ..style = PaintingStyle.fill;
    final remainingBarPaint = Paint()
      ..color = color.withValues(alpha: isCurrentlyPlaying ? 0.22 : 0.74)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < peaks.length; index++) {
      final peak = peaks[index].clamp(0.02, 1.0);
      final x = index * (barWidth + gap);
      final height = math.max(3.0, peak * size.height * 0.92);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          centerY - height / 2,
          barWidth,
          height,
        ),
        const Radius.circular(999),
      );
      final normalizedIndex = (index + 1) / peaks.length;
      final paint = isCurrentlyPlaying && normalizedIndex <= progress
          ? playedBarPaint
          : remainingBarPaint;
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AudioFileWaveformPainter oldDelegate) {
    return oldDelegate.peaks != peaks ||
        oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.isCurrentlyPlaying != isCurrentlyPlaying;
  }
}
