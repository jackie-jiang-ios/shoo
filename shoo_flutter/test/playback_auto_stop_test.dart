import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/audio/playback_auto_stop.dart';

void main() {
  group('PlaybackAutoStop', () {
    test('pause and resume keep remaining duration', () async {
      final autoStop = PlaybackAutoStop();
      var elapsedCount = 0;

      autoStop.start(
        duration: const Duration(milliseconds: 60),
        onElapsed: () => elapsedCount++,
      );

      await Future<void>.delayed(const Duration(milliseconds: 25));
      autoStop.pause();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(elapsedCount, 0);

      autoStop.resume(() => elapsedCount++);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(elapsedCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(elapsedCount, 1);
    });

    test('zero duration does not arm timer', () async {
      final autoStop = PlaybackAutoStop();
      var elapsedCount = 0;

      autoStop.start(
        duration: Duration.zero,
        onElapsed: () => elapsedCount++,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(elapsedCount, 0);
      expect(autoStop.hasRemaining, false);
    });
  });
}
