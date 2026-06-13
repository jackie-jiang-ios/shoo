import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/models/sound.dart';
import 'package:shoo/models/play_mode.dart';

void main() {
  group('Sound Model Tests', () {
    test('Sound should have correct properties', () {
      const sound = Sound(
        id: 'test_sound',
        name: '测试声音',
        nameEn: 'Test Sound',
        assetPath: 'assets/sounds/test.mp3',
        category: SoundCategory.animal,
        duration: 3.5,
        description: '测试用',
        descriptionEn: 'For testing',
        targetAnimal: '测试动物',
        frequencyRange: '100Hz-2kHz',
        iconName: 'pets',
      );

      expect(sound.id, 'test_sound');
      expect(sound.name, '测试声音');
      expect(sound.category, SoundCategory.animal);
      expect(sound.duration, 3.5);
      expect(sound.isUltrasonic, false);
      expect(sound.defaultVolume, 0.8);
    });

    test('Sound copyWith should work correctly', () {
      const sound = Sound(
        id: 'test_sound',
        name: '测试声音',
        nameEn: 'Test Sound',
        assetPath: 'assets/sounds/test.mp3',
        category: SoundCategory.animal,
        duration: 3.5,
        description: '测试用',
        descriptionEn: 'For testing',
        targetAnimal: '测试动物',
        frequencyRange: '100Hz-2kHz',
        iconName: 'pets',
      );

      final copied = sound.copyWith(name: '新名称', defaultVolume: 0.5);
      expect(copied.name, '新名称');
      expect(copied.id, 'test_sound'); // 未修改的属性保持不变
    });
  });

  group('SoundCategory Tests', () {
    test('SoundCategory should have correct values', () {
      expect(SoundCategory.values.length, 5);
      expect(SoundCategory.ultrasonic.id, 'ultrasonic');
      expect(SoundCategory.animal.name, '动物威慑');
      expect(SoundCategory.firecracker.emoji, '🧨');
    });
  });

  group('PlayMode Tests', () {
    test('PlayMode should have correct values', () {
      expect(PlayMode.values.length, 2);
      expect(PlayMode.continuous.id, 'continuous');
      expect(PlayMode.interval.name, '间隔播放');
    });

    test('PlayConfig default values', () {
      const config = PlayConfig();
      expect(config.mode, PlayMode.continuous);
      expect(config.volume, 0.8);
      expect(config.autoStopDuration, isNull);
    });
  });
}
