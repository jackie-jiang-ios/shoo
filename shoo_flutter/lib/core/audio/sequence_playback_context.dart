import '../../models/animal.dart';

class SequencePlaybackContext {
  const SequencePlaybackContext({
    required this.paths,
    required this.sound,
    required this.animal,
    this.volumeOverride,
  });

  final List<String> paths;
  final RecommendedSound sound;
  final Animal animal;
  final double? volumeOverride;
}
