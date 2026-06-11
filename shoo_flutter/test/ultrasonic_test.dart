import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/audio/ultrasonic_generator.dart';
import 'dart:math';

void main() {
  group('UltrasonicGenerator Tests', () {
    test('generatePcm should return correct number of samples', () {
      final pcm = UltrasonicGenerator.generatePcm(
        frequency: 18000,
        durationSeconds: 1.0,
      );

      expect(pcm.length, UltrasonicGenerator.sampleRate);
    });

    test('generatePcm values should be within [-1, 1]', () {
      final pcm = UltrasonicGenerator.generatePcm(
        frequency: 20000,
        durationSeconds: 0.5,
      );

      for (final sample in pcm) {
        expect(sample.abs(), lessThanOrEqualTo(1.0));
      }
    });

    test('generateIntervalPcm should have silent gaps', () {
      final pcm = UltrasonicGenerator.generateIntervalPcm(
        frequency: 18000,
        playDuration: 0.5,
        gapDuration: 0.5,
        totalDuration: 2.0,
      );

      // 在间隔期间应该有静音区域
      final gapStart = (0.5 * UltrasonicGenerator.sampleRate).round();
      var hasSilentGap = false;
      for (int i = gapStart; i < gapStart + 100 && i < pcm.length; i++) {
        if (pcm[i].abs() < 0.01) {
          hasSilentGap = true;
          break;
        }
      }
      expect(hasSilentGap, true);
    });

    test('generateWav should produce valid WAV header', () {
      final wav = UltrasonicGenerator.generateWav(
        frequency: 18000,
        durationSeconds: 0.1,
      );

      // 检查 RIFF 标识
      expect(wav[0], 0x52); // 'R'
      expect(wav[1], 0x49); // 'I'
      expect(wav[2], 0x46); // 'F'
      expect(wav[3], 0x46); // 'F'

      // 检查 WAVE 标识
      expect(wav[8], 0x57); // 'W'
      expect(wav[9], 0x41); // 'A'
      expect(wav[10], 0x56); // 'V'
      expect(wav[11], 0x45); // 'E'
    });
  });
}
