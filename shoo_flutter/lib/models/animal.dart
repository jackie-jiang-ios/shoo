/// 动物分类
enum AnimalCategory {
  all('all', '全部', 'All', '🐾'),
  beast('beast', '猛兽威胁', 'Beasts', '🦁'),
  reptile('reptile', '爬行类', 'Reptiles', '🐍'),
  primate('primate', '灵长类', 'Primates', '🐒'),
  rodent('rodent', '啮齿类', 'Rodents', '🐭'),
  insect('insect', '昆虫类', 'Insects', '🐛'),
  bird('bird', '鸟类', 'Birds', '🦅');

  const AnimalCategory(this.id, this.name, this.nameEn, this.emoji);

  final String id;
  final String name;
  final String nameEn;
  final String emoji;
}

/// 音量配置模式
enum VolumeMode {
  /// 通用模式：所有动物使用统一的默认音量
  global('global', '通用音量', 'Global Volume'),

  /// 独立模式：每种动物使用各自推荐的音量
  individual('individual', '独立音量', 'Individual Volume');

  const VolumeMode(this.id, this.name, this.nameEn);

  final String id;
  final String name;
  final String nameEn;
}

/// 图标主题
enum IconTheme {
  /// 插画风格A
  v1('v1', '插画A', 'Illustration A'),

  /// 插画风格B
  v2('v2', '插画B', 'Illustration B'),

  /// 写实照片
  v3('v3', '写实', 'Photo');

  const IconTheme(this.id, this.name, this.nameEn);

  final String id;
  final String name;
  final String nameEn;
}

/// 动物模型
class Animal {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String counterSound;
  final String counterSoundEn;
  final String fullDescription;
  final String fullDescriptionEn;
  final AnimalCategory category;
  final List<RecommendedSound> sounds;
  final String iconName;

  /// 多套图标路径，key 为 IconTheme.id
  final Map<String, String> iconPaths;

  /// 推荐分贝值（dB SPL）- 该动物驱赶所需的有效声压级
  /// 参考值：低频动物(蛇/蜘蛛) 60-70dB，中型动物(狗/猴) 75-85dB，
  /// 大型猛兽(野猪/熊) 85-100dB，超声波(鼠/虫) 以频率为主
  final double recommendedDb;

  /// 有效传播距离（米）- 该推荐分贝声音在开阔环境下的有效驱赶距离
  final double effectiveRange;

  /// 推荐音量 (0.0 - 1.0) - 基于推荐分贝换算的系统播放音量
  /// 该值是综合考虑设备最大输出和推荐分贝后的建议值
  final double recommendedVolume;

  /// 频率范围描述（如 "20Hz-20kHz", "18kHz-22kHz"）
  final String frequencyRange;

  const Animal({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.counterSound,
    required this.counterSoundEn,
    required this.fullDescription,
    required this.fullDescriptionEn,
    required this.category,
    required this.sounds,
    required this.iconName,
    this.iconPaths = const {},
    this.recommendedDb = 80.0,
    this.effectiveRange = 15.0,
    this.recommendedVolume = 0.8,
    this.frequencyRange = '20Hz-20kHz',
  });

  /// 根据图标主题获取图片路径
  String getIconPath(String themeId) => iconPaths[themeId] ?? iconPaths.values.first;

  /// 获取该动物可用的图标主题列表
  List<IconTheme> get availableThemes {
    final result = <IconTheme>[];
    for (final theme in IconTheme.values) {
      if (iconPaths.containsKey(theme.id)) {
        result.add(theme);
      }
    }
    return result.isEmpty ? IconTheme.values.toList() : result;
  }
}

/// 声音播放模式
enum SoundPlayMode {
  /// 播放组内某一个指定声音
  single('single', '单个播放', 'Single'),

  /// 组内所有声音连续循环播放
  sequence('sequence', '连续播放', 'Sequence');

  const SoundPlayMode(this.id, this.name, this.nameEn);
  final String id;
  final String name;
  final String nameEn;
}

/// 推荐声音（带评分）
class RecommendedSound {
  final String name;
  final String nameEn;
  final int rating; // 1-5

  /// 声音组标识，对应 assets/sounds/ 下的文件夹名
  /// 例如 'tiger' 对应 assets/sounds/tiger/
  final String soundGroup;

  /// 组内声音文件数量（自动发现）
  final int soundCount;

  /// 当前选中的声音索引（0-based），-1 表示连续播放模式
  int selectedSoundIndex;

  /// 播放模式：单个播放 或 连续播放
  SoundPlayMode playMode;

  /// 该声音的推荐音量权重 (0.0 - 1.0)
  /// 不同于动物的推荐音量，这是该声音相对于动物基础音量的权重
  /// 例如：虎啸声权重 1.0（满音量），猎豹叫声权重 0.7（稍低）
  final double volumeWeight;

  /// 声音频率范围描述
  final String frequencyRange;

  /// 声音预估分贝（在满音量下该素材的输出分贝）
  final double estimatedDb;

  RecommendedSound({
    required this.name,
    required this.nameEn,
    this.rating = 3,
    required this.soundGroup,
    this.soundCount = 1,
    this.selectedSoundIndex = 0,
    this.playMode = SoundPlayMode.single,
    this.volumeWeight = 1.0,
    this.frequencyRange = '',
    this.estimatedDb = 80.0,
  });

  /// 获取指定索引的声音资源路径
  String getAssetPath(int index) {
    final i = index.clamp(0, soundCount - 1);
    return 'assets/sounds/$soundGroup/${soundGroup}_${i + 1}.mp3';
  }

  /// 获取当前应播放的资源路径列表
  /// 单个模式：返回选中索引的那一个
  /// 连续模式：返回组内所有声音
  List<String> get assetPaths {
    if (playMode == SoundPlayMode.single) {
      return [getAssetPath(selectedSoundIndex)];
    }
    return List.generate(soundCount, (i) => getAssetPath(i));
  }
}

/// 动物数据库
class AnimalDatabase {
  AnimalDatabase._();

  static final List<Animal> animals = [
    // ============ 猛兽威胁 ============
    Animal(
      id: 'wild_dog',
      name: '野狗',
      nameEn: 'Wild Dog',
      description: '常见威胁，群体攻击性强',
      descriptionEn: 'Common threat, aggressive in packs',
      counterSound: '虎啸声',
      counterSoundEn: 'Tiger Roar',
      fullDescription: '野狗具有强烈的领地意识和群体攻击性，在遇到危险时会集体围攻。老虎作为顶级捕食者，其威严的咆哮声能够有效震慑野狗群，让它们感到恐惧而退却。',
      fullDescriptionEn: 'Wild dogs have strong territorial awareness and pack aggression. The majestic roar of a tiger, as an apex predator, can effectively intimidate wild dog packs, making them feel threatened and retreat.',
      category: AnimalCategory.beast,
      recommendedDb: 80.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.85,
      frequencyRange: '100Hz-8kHz',
      sounds: [
        RecommendedSound(name: '虎啸声', nameEn: 'Tiger Roar', rating: 5, soundGroup: 'tiger', soundCount: 3, volumeWeight: 1.0, frequencyRange: '100Hz-2kHz', estimatedDb: 90),
        RecommendedSound(name: '狮吼声', nameEn: 'Lion Roar', rating: 4, soundGroup: 'lion', soundCount: 3, volumeWeight: 0.95, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.8, frequencyRange: '500Hz-12kHz', estimatedDb: 82),
      ],
      iconName: 'pets',
      iconPaths: {
        'v1': 'assets/images/icons/v1/dog.png',
        'v2': 'assets/images/icons/v2/dog.png',
        'v3': 'assets/images/icons/v3/dog.jpg',
      },
    ),
    Animal(
      id: 'wild_boar',
      name: '野猪',
      nameEn: 'Wild Boar',
      description: '力量强大，攻击性强',
      descriptionEn: 'Powerful and aggressive',
      counterSound: '狮子吼叫',
      counterSoundEn: 'Lion Roar',
      fullDescription: '野猪体型庞大，力量惊人，遇到威胁时会主动攻击。狮子作为森林之王的吼叫声能够传达强大的威慑力，让野猪感知到潜在威胁而避开。',
      fullDescriptionEn: 'Wild boars are massive and incredibly strong, actively attacking when threatened. The roar of a lion conveys powerful deterrence, making boars sense potential danger and stay away.',
      category: AnimalCategory.beast,
      recommendedDb: 90.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.9,
      frequencyRange: '50Hz-5kHz',
      sounds: [
        RecommendedSound(name: '狮子吼叫', nameEn: 'Lion Roar', rating: 5, soundGroup: 'lion', soundCount: 3, volumeWeight: 1.0, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(name: '低频声波', nameEn: 'Low-freq Wave', rating: 4, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.95, frequencyRange: '20Hz-1kHz', estimatedDb: 95),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.85, frequencyRange: '200Hz-6kHz', estimatedDb: 85),
      ],
      iconName: 'forest',
      iconPaths: {
        'v1': 'assets/images/icons/v1/boar.png',
        'v2': 'assets/images/icons/v2/boar.png',
        'v3': 'assets/images/icons/v3/boar.jpg',
      },
    ),
    Animal(
      id: 'bear',
      name: '熊',
      nameEn: 'Bear',
      description: '大型猛兽，破坏力强',
      descriptionEn: 'Large predator, highly destructive',
      counterSound: '枪声模拟',
      counterSoundEn: 'Gunshot Simulation',
      fullDescription: '熊是极具攻击性的大型猛兽，遇到人类时可能造成致命伤害。枪声的模拟能够传达人类武器的威胁，让熊意识到潜在危险而远离。',
      fullDescriptionEn: 'Bears are extremely aggressive large predators that can cause fatal injuries. Gunshot simulation conveys the threat of human weapons, making bears aware of potential danger and stay away.',
      category: AnimalCategory.beast,
      recommendedDb: 95.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.95,
      frequencyRange: '50Hz-10kHz',
      sounds: [
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 5, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '200Hz-6kHz', estimatedDb: 85),
      ],
      iconName: 'cottage',
      iconPaths: {
        'v1': 'assets/images/icons/v1/bear.png',
        'v2': 'assets/images/icons/v2/bear.png',
        'v3': 'assets/images/icons/v3/bear.jpg',
      },
    ),
    Animal(
      id: 'wolf',
      name: '狼',
      nameEn: 'Wolf',
      description: '夜间狩猎，群体性强',
      descriptionEn: 'Nocturnal hunter, strong pack behavior',
      counterSound: '狼嚎声',
      counterSoundEn: 'Wolf Howl',
      fullDescription: '狼是夜行性动物，具有极强的群体狩猎能力。狼嚎声能够模拟同类间的交流，传达领域占有信息，从而威慑狼群。',
      fullDescriptionEn: 'Wolves are nocturnal animals with strong pack hunting abilities. Wolf howls simulate intraspecific communication, conveying territorial possession to deter wolf packs.',
      category: AnimalCategory.beast,
      recommendedDb: 85.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.88,
      frequencyRange: '150Hz-5kHz',
      sounds: [
        RecommendedSound(name: '狼嚎声', nameEn: 'Wolf Howl', rating: 5, soundGroup: 'wolf', soundCount: 3, volumeWeight: 1.0, frequencyRange: '150Hz-2kHz', estimatedDb: 85),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.95, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(name: '低频声波', nameEn: 'Low-freq Wave', rating: 3, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '1kHz-8kHz', estimatedDb: 70),
      ],
      iconName: 'nights_stay',
      iconPaths: {
        'v1': 'assets/images/icons/v1/wolf.png',
        'v2': 'assets/images/icons/v2/wolf.png',
        'v3': 'assets/images/icons/v3/wolf.jpg',
      },
    ),
    Animal(
      id: 'fox',
      name: '狐狸',
      nameEn: 'Fox',
      description: '夜间活动，偷食家禽',
      descriptionEn: 'Nocturnal, poultry thief',
      counterSound: '狗吠声',
      counterSoundEn: 'Dog Bark',
      fullDescription: '狐狸夜间活动，常偷食家禽。狗吠声能够模拟天敌威胁，驱赶狐狸。',
      fullDescriptionEn: 'Foxes are nocturnal and often steal poultry. Dog barking simulates predator threats, driving foxes away.',
      category: AnimalCategory.beast,
      recommendedDb: 75.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.8,
      frequencyRange: '200Hz-6kHz',
      sounds: [
        RecommendedSound(name: '狗吠声', nameEn: 'Dog Bark', rating: 5, soundGroup: 'dog', soundCount: 3, volumeWeight: 1.0, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
      ],
      iconName: 'pets',
      iconPaths: {
        'v3': 'assets/images/icons/v3/fox.jpg',
      },
    ),

    // ============ 爬行类 ============
    Animal(
      id: 'snake',
      name: '毒蛇',
      nameEn: 'Venomous Snake',
      description: '夜间活动，毒性危险',
      descriptionEn: 'Nocturnal, dangerously venomous',
      counterSound: '雄鸡啼鸣',
      counterSoundEn: 'Rooster Crow',
      fullDescription: '毒蛇在野外是极其危险的生物，尤其在夜间活动频繁。雄鸡的啼鸣声模拟了蛇类天敌（如獴类动物）的警告声，能够有效驱赶毒蛇。',
      fullDescriptionEn: 'Venomous snakes are extremely dangerous in the wild, especially at night. Rooster crowing simulates the warning sound of snake predators (like mongooses), effectively driving them away.',
      category: AnimalCategory.reptile,
      recommendedDb: 65.0,
      effectiveRange: 8.0,
      recommendedVolume: 0.65,
      frequencyRange: '100Hz-4kHz',
      sounds: [
        RecommendedSound(name: '雄鸡啼鸣', nameEn: 'Rooster Crow', rating: 5, soundGroup: 'rooster', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-4kHz', estimatedDb: 75),
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '300Hz-3kHz', estimatedDb: 70),
        RecommendedSound(name: '低频声波', nameEn: 'Low-freq Wave', rating: 3, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '50Hz-500Hz', estimatedDb: 85),
      ],
      iconName: 'dangerous',
      iconPaths: {
        'v1': 'assets/images/icons/v1/snake.png',
        'v2': 'assets/images/icons/v2/snake.png',
        'v3': 'assets/images/icons/v3/snake.jpg',
      },
    ),

    // ============ 灵长类 ============
    Animal(
      id: 'monkey',
      name: '猴子',
      nameEn: 'Monkey',
      description: '群体骚扰，抢夺物品',
      descriptionEn: 'Pack harassment, snatching items',
      counterSound: '鹰啸声',
      counterSoundEn: 'Eagle Screech',
      fullDescription: '猴子虽然个体不大，但群体行动时会骚扰人类并抢夺食物。鹰作为天空霸主的啸声能够模拟天敌威胁，让猴群感到恐慌而逃离。',
      fullDescriptionEn: 'Monkeys may be small individually, but in packs they harass humans and snatch food. Eagle screeches simulate predator threats, causing panic in monkey troops and driving them away.',
      category: AnimalCategory.primate,
      recommendedDb: 75.0,
      effectiveRange: 15.0,
      recommendedVolume: 0.78,
      frequencyRange: '500Hz-8kHz',
      sounds: [
        RecommendedSound(name: '鹰啸声', nameEn: 'Eagle Screech', rating: 5, soundGroup: 'eagle', soundCount: 3, volumeWeight: 1.0, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
        RecommendedSound(name: '狗吠声', nameEn: 'Dog Bark', rating: 4, soundGroup: 'dog', soundCount: 3, volumeWeight: 0.85, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.7, frequencyRange: '2kHz-10kHz', estimatedDb: 75),
      ],
      iconName: 'emoji_nature',
      iconPaths: {
        'v1': 'assets/images/icons/v1/monkey.png',
        'v2': 'assets/images/icons/v2/monkey.png',
        'v3': 'assets/images/icons/v3/monkey.jpg',
      },
    ),

    // ============ 啮齿类 ============
    Animal(
      id: 'mouse',
      name: '老鼠',
      nameEn: 'Mouse',
      description: '夜间活动，传播疾病',
      descriptionEn: 'Nocturnal, disease carrier',
      counterSound: '猫叫声',
      counterSoundEn: 'Cat Meow',
      fullDescription: '老鼠是常见的害虫，不仅破坏物品还会传播疾病。猫作为老鼠的天敌，其叫声能够有效驱赶老鼠，保护居住环境。',
      fullDescriptionEn: 'Mice are common pests that damage property and spread disease. As natural predators of mice, cat sounds can effectively drive them away and protect your living space.',
      category: AnimalCategory.rodent,
      recommendedDb: 55.0,
      effectiveRange: 5.0,
      recommendedVolume: 0.6,
      frequencyRange: '1kHz-22kHz',
      sounds: [
        RecommendedSound(name: '猫叫声', nameEn: 'Cat Meow', rating: 5, soundGroup: 'cat', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-5kHz', estimatedDb: 65),
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '18kHz-22kHz', estimatedDb: 60),
      ],
      iconName: 'pest_control',
      iconPaths: {
        'v3': 'assets/images/icons/v3/mouse.jpg',
      },
    ),
    Animal(
      id: 'rabbit',
      name: '野兔',
      nameEn: 'Wild Rabbit',
      description: '农田害兽，繁殖快',
      descriptionEn: 'Farm pest, rapid reproduction',
      counterSound: '猎犬吠叫',
      counterSoundEn: 'Hound Bark',
      fullDescription: '野兔繁殖能力强，对农作物造成损害。猎犬吠叫能够模拟天敌威胁，驱赶野兔。',
      fullDescriptionEn: 'Wild rabbits reproduce rapidly and damage crops. Hound barking simulates predator threats, driving rabbits away.',
      category: AnimalCategory.rodent,
      recommendedDb: 70.0,
      effectiveRange: 12.0,
      recommendedVolume: 0.7,
      frequencyRange: '300Hz-6kHz',
      sounds: [
        RecommendedSound(name: '狗吠声', nameEn: 'Dog Bark', rating: 5, soundGroup: 'dog', soundCount: 3, volumeWeight: 1.0, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(name: '鹰啸声', nameEn: 'Eagle Screech', rating: 4, soundGroup: 'eagle', soundCount: 3, volumeWeight: 0.85, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
      ],
      iconName: 'grass',
      iconPaths: {
        'v3': 'assets/images/icons/v3/rabbit.jpg',
      },
    ),

    // ============ 昆虫类 ============
    Animal(
      id: 'spider',
      name: '毒蜘蛛',
      nameEn: 'Venomous Spider',
      description: '夜间活动，毒性危险',
      descriptionEn: 'Nocturnal, dangerously venomous',
      counterSound: '震动声',
      counterSoundEn: 'Vibration Sound',
      fullDescription: '毒蜘蛛多在夜间活动，具有较强的毒性。高频震动声能够干扰蜘蛛的感知系统，使其离开栖息地。',
      fullDescriptionEn: 'Venomous spiders are mostly nocturnal with potent venom. High-frequency vibration sounds can disrupt their sensory systems, driving them from their habitats.',
      category: AnimalCategory.insect,
      recommendedDb: 50.0,
      effectiveRange: 3.0,
      recommendedVolume: 0.55,
      frequencyRange: '15kHz-22kHz',
      sounds: [
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 5, soundGroup: 'vibration', soundCount: 3, volumeWeight: 1.0, frequencyRange: '20kHz-22kHz', estimatedDb: 55),
        RecommendedSound(name: '低频声波', nameEn: 'Low-freq Wave', rating: 4, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '200Hz-3kHz', estimatedDb: 65),
      ],
      iconName: 'bug_report',
      iconPaths: {
        'v3': 'assets/images/icons/v3/spider.jpg',
      },
    ),
    Animal(
      id: 'wasp',
      name: '马蜂',
      nameEn: 'Wasp',
      description: '群体攻击，毒性较强',
      descriptionEn: 'Swarm attacks, highly venomous',
      counterSound: '低频声波',
      counterSoundEn: 'Low-freq Wave',
      fullDescription: '马蜂具有强烈的护巢本能，一旦受到惊扰会群体攻击。低频声波能够干扰马蜂的飞行平衡，使其远离。',
      fullDescriptionEn: 'Wasps have strong nest-protecting instincts and attack in swarms when disturbed. Low-frequency waves can disrupt their flight balance, keeping them away.',
      category: AnimalCategory.insect,
      recommendedDb: 60.0,
      effectiveRange: 5.0,
      recommendedVolume: 0.65,
      frequencyRange: '15kHz-20kHz',
      sounds: [
        RecommendedSound(name: '低频声波', nameEn: 'Low-freq Wave', rating: 5, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 1.0, frequencyRange: '15kHz-18kHz', estimatedDb: 60),
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.8, frequencyRange: '2kHz-8kHz', estimatedDb: 65),
      ],
      iconName: 'hive',
      iconPaths: {
        'v3': 'assets/images/icons/v3/hornet.jpg',
      },
    ),

    // ============ 鸟类 ============
    Animal(
      id: 'crow',
      name: '乌鸦',
      nameEn: 'Crow',
      description: '群体性强，破坏庄稼',
      descriptionEn: 'Strong flocking, crop destroyer',
      counterSound: '鹰啸声',
      counterSoundEn: 'Eagle Screech',
      fullDescription: '乌鸦群体性强，常破坏庄稼和果实。鹰啸声能够模拟天敌威胁，驱散乌鸦群。',
      fullDescriptionEn: 'Crows have strong flocking behavior and often destroy crops and fruits. Eagle screeches simulate predator threats, dispersing crow flocks.',
      category: AnimalCategory.bird,
      recommendedDb: 75.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.78,
      frequencyRange: '500Hz-8kHz',
      sounds: [
        RecommendedSound(name: '鹰啸声', nameEn: 'Eagle Screech', rating: 5, soundGroup: 'eagle', soundCount: 3, volumeWeight: 1.0, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
        RecommendedSound(name: '枪声', nameEn: 'Gunshot', rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(name: '震动声', nameEn: 'Vibration', rating: 3, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.7, frequencyRange: '2kHz-8kHz', estimatedDb: 80),
      ],
      iconName: 'flutter_dash',
      iconPaths: {
        'v3': 'assets/images/icons/v3/crow.jpg',
      },
    ),
  ];

  /// 根据ID查找动物
  static Animal? findById(String id) {
    for (final animal in animals) {
      if (animal.id == id) return animal;
    }
    return null;
  }

  /// 根据分类获取动物列表
  static List<Animal> findByCategory(AnimalCategory category) {
    if (category == AnimalCategory.all) return animals;
    return animals.where((a) => a.category == category).toList();
  }
}
