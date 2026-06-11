import 'package:uuid/uuid.dart';

/// 声音模型
class Sound {
  final String id;
  final String name;
  final String nameEn;
  final String _assetPath;
  final List<String> _assetPaths;
  final SoundCategory category;
  final double duration; // 秒
  final String description;
  final String descriptionEn;
  final String targetAnimal; // 驱赶目标
  final String frequencyRange; // 频率范围
  final bool isUltrasonic; // 是否为超声波
  final double defaultVolume; // 默认音量 0.0 - 1.0
  final String iconName; // 对应图标名称

  const Sound({
    required this.id,
    required this.name,
    required this.nameEn,
    required String assetPath,
    List<String>? assetPaths,
    required this.category,
    required this.duration,
    required this.description,
    required this.descriptionEn,
    required this.targetAnimal,
    required this.frequencyRange,
    this.isUltrasonic = false,
    this.defaultVolume = 0.8,
    required this.iconName,
  }) : _assetPath = assetPath, _assetPaths = assetPaths ?? const [];

  /// 获取资源路径（单个）
  String get assetPath => _assetPath;

  /// 获取所有资源路径列表
  /// 如果设置了 assetPaths 则返回该列表，否则返回 [_assetPath]
  List<String> get assetPaths => _assetPaths.isNotEmpty ? _assetPaths : [_assetPath];

  Sound copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? assetPath,
    List<String>? assetPaths,
    SoundCategory? category,
    double? duration,
    String? description,
    String? descriptionEn,
    String? targetAnimal,
    String? frequencyRange,
    bool? isUltrasonic,
    double? defaultVolume,
    String? iconName,
  }) {
    return Sound(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      assetPath: assetPath ?? _assetPath,
      assetPaths: assetPaths ?? _assetPaths,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      targetAnimal: targetAnimal ?? this.targetAnimal,
      frequencyRange: frequencyRange ?? this.frequencyRange,
      isUltrasonic: isUltrasonic ?? this.isUltrasonic,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sound && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 声音分类
enum SoundCategory {
  ultrasonic('ultrasonic', '超声波', 'Ultrasonic', '🔊'),
  animal('animal', '动物威慑', 'Animal Deterrent', '🐅'),
  firecracker('firecracker', '炮仗', 'Firecracker', '🧨'),
  alarm('alarm', '警报', 'Alarm', '🚨'),
  metal('metal', '金属撞击', 'Metal Impact', '🔔');

  const SoundCategory(
    this.id,
    this.name,
    this.nameEn,
    this.emoji,
  );

  final String id;
  final String name;
  final String nameEn;
  final String emoji;
}
