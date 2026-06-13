import 'package:uuid/uuid.dart';

/// 多语言翻译查找工具方法
String _t(Map<String, String> translations, String langCode) {
  return translations[langCode] ?? translations['en'] ?? translations.values.first;
}

/// 声音模型
class Sound {
  final String id;
  final Map<String, String> nameMap;
  final String _assetPath;
  final List<String> _assetPaths;
  final SoundCategory category;
  final double duration; // 秒
  final Map<String, String> descriptionMap;
  final String targetAnimal; // 驱赶目标
  final String frequencyRange; // 频率范围
  final bool isUltrasonic; // 是否为超声波
  final double defaultVolume; // 默认音量 0.0 - 1.0
  final String iconName; // 对应图标名称

  const Sound({
    required this.id,
    required this.nameMap,
    required String assetPath,
    List<String>? assetPaths,
    required this.category,
    required this.duration,
    required this.descriptionMap,
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

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);

  /// 根据语言代码获取本地化描述
  String getLocalizedDescription(String langCode) => _t(descriptionMap, langCode);

  Sound copyWith({
    String? id,
    Map<String, String>? nameMap,
    String? assetPath,
    List<String>? assetPaths,
    SoundCategory? category,
    double? duration,
    Map<String, String>? descriptionMap,
    String? targetAnimal,
    String? frequencyRange,
    bool? isUltrasonic,
    double? defaultVolume,
    String? iconName,
  }) {
    return Sound(
      id: id ?? this.id,
      nameMap: nameMap ?? this.nameMap,
      assetPath: assetPath ?? _assetPath,
      assetPaths: assetPaths ?? _assetPaths,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      descriptionMap: descriptionMap ?? this.descriptionMap,
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
  ultrasonic('ultrasonic', const {'zh': '超声波', 'en': 'Ultrasonic', 'ja': '超音波', 'ko': '초음파', 'fr': 'Ultrason', 'de': 'Ultraschall', 'es': 'Ultrasonido', 'ru': 'Ультразвук', 'pt': 'Ultrassom', 'th': 'อัลตราซาวด์'}, '🔊'),
  animal('animal', const {'zh': '动物威慑', 'en': 'Animal Deterrent', 'ja': '動物威嚇', 'ko': '동물 억제', 'fr': 'Dissuasion animale', 'de': 'Tierabschreckung', 'es': 'Disuasión animal', 'ru': 'Отпугивание животных', 'pt': 'Dissuasão animal', 'th': 'ไล่สัตว์'}, '🐅'),
  firecracker('firecracker', const {'zh': '炮仗', 'en': 'Firecracker', 'ja': '爆竹', 'ko': '폭죽', 'fr': 'Pétard', 'de': 'Feuerwerkskörper', 'es': 'Petardo', 'ru': 'Хлопушка', 'pt': 'Foguete', 'th': 'ประทัด'}, '🧨'),
  alarm('alarm', const {'zh': '警报', 'en': 'Alarm', 'ja': '警報', 'ko': '경보', 'fr': 'Alarme', 'de': 'Alarm', 'es': 'Alarma', 'ru': 'Тревога', 'pt': 'Alarme', 'th': 'สัญญาณเตือน'}, '🚨'),
  metal('metal', const {'zh': '金属撞击', 'en': 'Metal Impact', 'ja': '金属衝突', 'ko': '금속 충돌', 'fr': 'Impact métallique', 'de': 'Metallaufprall', 'es': 'Impacto metálico', 'ru': 'Металлический удар', 'pt': 'Impacto metálico', 'th': 'เสียงโลหะกระแทก'}, '🔔');

  const SoundCategory(
    this.id,
    this.nameMap,
    this.emoji,
  );

  final String id;
  final Map<String, String> nameMap;
  final String emoji;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}
