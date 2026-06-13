import 'dart:typed_data';
import 'dart:math';

/// 超声波生成器
///
/// 通过数字信号合成方式生成超声波音频。
/// 由于 Flutter 侧无法直接生成高频 PCM 数据并通过 just_audio 播放，
/// 此类提供生成 PCM 数据的方法，实际播放需要通过 Platform Channel
/// 调用原生 API（iOS: AVAudioPlayer / Android: AudioTrack）实现。
class UltrasonicGenerator {
  UltrasonicGenerator._();

  /// 支持的超声波频率
  static const List<double> supportedFrequencies = [18000, 20000, 22000];

  /// 默认采样率
  static const int sampleRate = 44100;

  /// 生成超声波 PCM 数据
  ///
  /// [frequency] 频率（Hz），如 18000, 20000, 22000
  /// [durationSeconds] 持续时间（秒）
  /// [volume] 音量 0.0 - 1.0
  static Float32List generatePcm({
    required double frequency,
    required double durationSeconds,
    double volume = 0.8,
  }) {
    final numSamples = (sampleRate * durationSeconds).round();
    final samples = Float32List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // 加入淡入淡出避免爆音
      double envelope = 1.0;
      final fadeSamples = (sampleRate * 0.01).round(); // 10ms 淡入淡出
      if (i < fadeSamples) {
        envelope = i / fadeSamples;
      } else if (i > numSamples - fadeSamples) {
        envelope = (numSamples - i) / fadeSamples;
      }

      samples[i] = volume * envelope * sin(2 * pi * frequency * t);
    }

    return samples;
  }

  /// 生成间隔模式的 PCM 数据
  ///
  /// [frequency] 频率
  /// [playDuration] 每次播放持续时间（秒）
  /// [gapDuration] 间隔时间（秒）
  /// [totalDuration] 总时长（秒）
  static Float32List generateIntervalPcm({
    required double frequency,
    required double playDuration,
    required double gapDuration,
    required double totalDuration,
    double volume = 0.8,
  }) {
    final numSamples = (sampleRate * totalDuration).round();
    final samples = Float32List(numSamples);
    final cycleDuration = playDuration + gapDuration;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final cyclePosition = t % cycleDuration;

      if (cyclePosition < playDuration) {
        // 播放阶段
        double envelope = 1.0;
        final fadeSamples = (sampleRate * 0.005).round();
        final playStart = (cyclePosition * sampleRate).round();
        final playEnd = ((playDuration - cyclePosition) * sampleRate).round();

        if (playStart < fadeSamples) {
          envelope = playStart / fadeSamples;
        } else if (playEnd < fadeSamples) {
          envelope = playEnd / fadeSamples;
        }

        samples[i] = volume * envelope * sin(2 * pi * frequency * t);
      } else {
        // 静音间隔
        samples[i] = 0.0;
      }
    }

    return samples;
  }

  /// 将 Float32 PCM 转为 16-bit PCM 字节流
  static Uint8List float32ToInt16(Float32List float32Samples) {
    final int16Samples = Uint8List(float32Samples.length * 2);
    final data = ByteData.view(int16Samples.buffer);

    for (int i = 0; i < float32Samples.length; i++) {
      final sample = (float32Samples[i] * 32767).round().clamp(-32768, 32767);
      data.setInt16(i * 2, sample, Endian.little);
    }

    return int16Samples;
  }

  /// 生成 WAV 文件头 + PCM 数据
  static Uint8List generateWav({
    required double frequency,
    required double durationSeconds,
    double volume = 0.8,
  }) {
    final pcm = generatePcm(
      frequency: frequency,
      durationSeconds: durationSeconds,
      volume: volume,
    );
    final pcmBytes = float32ToInt16(pcm);
    final dataSize = pcmBytes.length;

    // WAV header = 44 bytes
    final wav = Uint8List(44 + dataSize);
    final header = ByteData.view(wav.buffer);

    // RIFF header
    header.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    header.setUint32(4, 36 + dataSize, Endian.little);
    header.setUint32(8, 0x57415645, Endian.big); // "WAVE"

    // fmt chunk
    header.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    header.setUint32(36, 0x64617461, Endian.big); // "data"
    header.setUint32(40, dataSize, Endian.little);

    // PCM data
    wav.setRange(44, 44 + dataSize, pcmBytes);

    return wav;
  }
}
