/// 多语言翻译查找工具方法
/// 优先匹配当前语言，回退到英文，再回退到第一个可用值
String _t(Map<String, String> translations, String langCode) {
  return translations[langCode] ?? translations['en'] ?? translations.values.first;
}

/// 动物分类
enum AnimalCategory {
  all('all', const {'zh': '全部', 'en': 'All', 'ja': 'すべて', 'ko': '전체', 'fr': 'Tout', 'de': 'Alle', 'es': 'Todo', 'ru': 'Все', 'pt': 'Todos', 'th': 'ทั้งหมด'}, '🐾'),
  beast('beast', const {'zh': '猛兽威胁', 'en': 'Beasts', 'ja': '猛獣', 'ko': '맹수', 'fr': 'Bêtes féroces', 'de': 'Raubtiere', 'es': 'Bestias', 'ru': 'Хищники', 'pt': 'Feras', 'th': 'สัตว์นักล่า'}, '🦁'),
  reptile('reptile', const {'zh': '爬行类', 'en': 'Reptiles', 'ja': '爬虫類', 'ko': '파충류', 'fr': 'Reptiles', 'de': 'Reptilien', 'es': 'Reptiles', 'ru': 'Рептилии', 'pt': 'Répteis', 'th': 'สัตว์เลื้อยคลาน'}, '🐍'),
  primate('primate', const {'zh': '灵长类', 'en': 'Primates', 'ja': '霊長類', 'ko': '영장류', 'fr': 'Primates', 'de': 'Primaten', 'es': 'Primates', 'ru': 'Приматы', 'pt': 'Primatas', 'th': 'สัตว์อันดับลิง'}, '🐒'),
  rodent('rodent', const {'zh': '啮齿类', 'en': 'Rodents', 'ja': '齧歯類', 'ko': '설치류', 'fr': 'Rongeurs', 'de': 'Nagetiere', 'es': 'Roedores', 'ru': 'Грызуны', 'pt': 'Roedores', 'th': 'สัตว์ฟันแทะ'}, '🐭'),
  insect('insect', const {'zh': '昆虫类', 'en': 'Insects', 'ja': '昆虫類', 'ko': '곤충류', 'fr': 'Insectes', 'de': 'Insekten', 'es': 'Insectos', 'ru': 'Насекомые', 'pt': 'Insetos', 'th': 'แมลง'}, '🐛'),
  bird('bird', const {'zh': '鸟类', 'en': 'Birds', 'ja': '鳥類', 'ko': '조류', 'fr': 'Oiseaux', 'de': 'Vögel', 'es': 'Aves', 'ru': 'Птицы', 'pt': 'Aves', 'th': 'นก'}, '🦅');

  const AnimalCategory(this.id, this.nameMap, this.emoji);

  final String id;
  final Map<String, String> nameMap;
  final String emoji;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}

/// 音量配置模式
enum VolumeMode {
  /// 通用模式：所有动物使用统一的默认音量
  global('global', const {'zh': '通用音量', 'en': 'Global Volume', 'ja': '共通音量', 'ko': '공통 볼륨', 'fr': 'Volume global', 'de': 'Globaler Volume', 'es': 'Volumen global', 'ru': 'Общая громкость', 'pt': 'Volume global', 'th': 'ระดับเสียงรวม'}),

  /// 独立模式：每种动物使用各自推荐的音量
  individual('individual', const {'zh': '独立音量', 'en': 'Individual Volume', 'ja': '個別音量', 'ko': '개별 볼륨', 'fr': 'Volume individuel', 'de': 'Individueller Volume', 'es': 'Volumen individual', 'ru': 'Индивидуальная громкость', 'pt': 'Volume individual', 'th': 'ระดับเสียงแยก'});

  const VolumeMode(this.id, this.nameMap);

  final String id;
  final Map<String, String> nameMap;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}

/// 图标主题
enum IconTheme {
  /// 插画风格A
  v1('v1', const {'zh': '插画A', 'en': 'Illustration A', 'ja': 'イラストA', 'ko': '일러스트A', 'fr': 'Illustration A', 'de': 'Illustration A', 'es': 'Ilustración A', 'ru': 'Иллюстрация A', 'pt': 'Ilustração A', 'th': 'ภาพประกอบ A'}),

  /// 插画风格B
  v2('v2', const {'zh': '插画B', 'en': 'Illustration B', 'ja': 'イラストB', 'ko': '일러스트B', 'fr': 'Illustration B', 'de': 'Illustration B', 'es': 'Ilustración B', 'ru': 'Иллюстрация B', 'pt': 'Ilustração B', 'th': 'ภาพประกอบ B'}),

  /// 写实照片
  v3('v3', const {'zh': '写实', 'en': 'Photo', 'ja': '写真', 'ko': '사진', 'fr': 'Photo', 'de': 'Foto', 'es': 'Foto', 'ru': 'Фото', 'pt': 'Foto', 'th': 'ภาพถ่าย'});

  const IconTheme(this.id, this.nameMap);

  final String id;
  final Map<String, String> nameMap;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}

/// 动物模型
class Animal {
  final String id;
  final Map<String, String> nameMap;
  final Map<String, String> descriptionMap;
  final Map<String, String> counterSoundMap;
  final Map<String, String> fullDescriptionMap;
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
    required this.nameMap,
    required this.descriptionMap,
    required this.counterSoundMap,
    required this.fullDescriptionMap,
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

  /// 根据语言代码获取动物名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);

  /// 根据语言代码获取描述
  String getLocalizedDescription(String langCode) => _t(descriptionMap, langCode);

  /// 根据语言代码获取完整描述
  String getLocalizedFullDescription(String langCode) => _t(fullDescriptionMap, langCode);

  /// 根据语言代码获取克制声音名称
  String getLocalizedCounterSound(String langCode) => _t(counterSoundMap, langCode);
}

/// 声音播放模式
enum SoundPlayMode {
  /// 播放组内某一个指定声音（单选）
  single('single', const {'zh': '单个', 'en': 'Single', 'ja': '単一', 'ko': '단일', 'fr': 'Unique', 'de': 'Einzeln', 'es': 'Único', 'ru': 'Одиночный', 'pt': 'Único', 'th': 'เดี่ยว'}),

  /// 播放组内多个选中声音的循环（多选）
  sequence('sequence', const {'zh': '多选', 'en': 'Multi', 'ja': '複数', 'ko': '다중', 'fr': 'Multi', 'de': 'Multi', 'es': 'Multi', 'ru': 'Мульти', 'pt': 'Multi', 'th': 'หลายรายการ'});

  const SoundPlayMode(this.id, this.nameMap);
  final String id;
  final Map<String, String> nameMap;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}

/// 推荐声音（带评分）
class RecommendedSound {
  final Map<String, String> nameMap;
  final int rating; // 1-5

  /// 声音组标识，对应 assets/sounds/ 下的文件夹名
  /// 例如 'tiger' 对应 assets/sounds/tiger/
  final String soundGroup;

  /// 组内声音文件数量（自动发现）
  final int soundCount;

  /// 当前选中的声音索引（0-based），single 模式下使用
  int selectedSoundIndex;

  /// 多选模式下选中的声音索引集合，sequence 模式下使用
  Set<int> selectedIndices;

  /// 播放模式：单个播放 或 多选连续播放
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
    required this.nameMap,
    this.rating = 3,
    required this.soundGroup,
    this.soundCount = 1,
    this.selectedSoundIndex = 0,
    Set<int>? selectedIndices,
    this.playMode = SoundPlayMode.single,
    this.volumeWeight = 1.0,
    this.frequencyRange = '',
    this.estimatedDb = 80.0,
  }) : selectedIndices = selectedIndices ?? const {0};

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);

  /// 获取声音的唯一标识（用于去重）
  String get soundId => soundGroup;

  /// 获取指定索引的声音资源路径
  String getAssetPath(int index) {
    final i = index.clamp(0, soundCount - 1);
    return 'assets/sounds/$soundGroup/${soundGroup}_${i + 1}.mp3';
  }

  /// 获取当前应播放的资源路径列表
  /// 单个模式：返回选中索引的那一个
  /// 多选模式：返回所有选中索引的声音文件
  List<String> get assetPaths {
    if (playMode == SoundPlayMode.single) {
      return [getAssetPath(selectedSoundIndex)];
    }
    // 多选模式：按索引排序，确保播放顺序一致
    final sorted = selectedIndices.toList()..sort();
    if (sorted.isEmpty) return [getAssetPath(0)];
    return sorted.map((i) => getAssetPath(i)).toList();
  }
}

/// 动物数据库
class AnimalDatabase {
  AnimalDatabase._();

  static final List<Animal> animals = [
    // ============ 猛兽威胁 ============
    Animal(
      id: 'wild_dog',
      nameMap: const {'zh': '野狗', 'en': 'Wild Dog', 'ja': '野良犬', 'ko': '들개', 'fr': 'Chien sauvage', 'de': 'Wildhund', 'es': 'Perro salvaje', 'ru': 'Дикая собака', 'pt': 'Cão selvagem', 'th': 'หมาป่า'},
      descriptionMap: const {'zh': '常见威胁，群体攻击性强', 'en': 'Common threat, aggressive in packs', 'ja': '一般的な脅威、群れで攻撃的', 'ko': '흔한 위협, 무리 공격성 강함', 'fr': 'Menace courante, agressif en meute', 'de': 'Häufige Bedrohung, aggressiv im Rudel', 'es': 'Amenaza común, agresivo en manada', 'ru': 'Частая угроза, агрессивны стаями', 'pt': 'Ameaça comum, agressivo em matilha', 'th': 'ภัยคุกคามทั่วไป ดุร้ายเมื่ออยู่เป็นฝูง'},
      counterSoundMap: const {'zh': '虎啸声', 'en': 'Tiger Roar', 'ja': '虎の咆哮', 'ko': '호랑이 포효', 'fr': 'Rugissement de tigre', 'de': 'Tigerbrüllen', 'es': 'Rugido de tigre', 'ru': 'Рёв тигра', 'pt': 'Rugido de tigre', 'th': 'เสียงเสือคำราม'},
      fullDescriptionMap: const {'zh': '野狗具有强烈的领地意识和群体攻击性，在遇到危险时会集体围攻。老虎作为顶级捕食者，其威严的咆哮声能够有效震慑野狗群，让它们感到恐惧而退却。', 'en': 'Wild dogs have strong territorial awareness and pack aggression. The majestic roar of a tiger can effectively intimidate wild dog packs, making them retreat.', 'ja': '野良犬は強い縄張り意識と群れの攻撃性を持ちます。トラの咆哮は野良犬の群れを効果的に威嚇し、退散させます。', 'ko': '들개는 강한 영역 의식과 무리 공격성을 가집니다. 호랑이의 포효는 들개 무리를 효과적으로 위협하여 물러나게 합니다.', 'fr': 'Les chiens sauvages ont un fort sens du territoire. Le rugissement du tigre intimide les meutes et les pousse à fuir.', 'de': 'Wildhunde haben ein starkes Revierbewusstsein. Das Brüllen eines Tigers schüchtert Wildhundrudel effektiv ein.', 'es': 'Los perros salvajes tienen fuerte conciencia territorial. El rugido del tigre intimida eficazmente a las manadas.', 'ru': 'Дикие собаки обладают сильным чувством территории. Рык тигра эффективно отпугивает стаи диких собак.', 'pt': 'Cães selvagens têm forte consciência territorial. O rugido do tigre intimida eficazmente as matilhas.', 'th': 'หมาป่ามีความรู้สึกถึงอาณาเขตแรง เสียงคำรามของเสือขู่ฝูงหมาป่าได้อย่างมีประสิทธิภาพ'},
      category: AnimalCategory.beast,
      recommendedDb: 80.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.85,
      frequencyRange: '100Hz-8kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '虎啸声', 'en': 'Tiger Roar', 'ja': '虎の咆哮', 'ko': '호랑이 포효', 'fr': 'Rugissement de tigre', 'de': 'Tigerbrüllen', 'es': 'Rugido de tigre', 'ru': 'Рёв тигра', 'pt': 'Rugido de tigre', 'th': 'เสียงเสือคำราม'}, rating: 5, soundGroup: 'tiger', soundCount: 3, volumeWeight: 1.0, frequencyRange: '100Hz-2kHz', estimatedDb: 90),
        RecommendedSound(nameMap: const {'zh': '狮吼声', 'en': 'Lion Roar', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'}, rating: 4, soundGroup: 'lion', soundCount: 3, volumeWeight: 0.95, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.8, frequencyRange: '500Hz-12kHz', estimatedDb: 82),
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
      nameMap: const {'zh': '野猪', 'en': 'Wild Boar', 'ja': 'イノシシ', 'ko': '멧돼지', 'fr': 'Sanglier', 'de': 'Wildschwein', 'es': 'Jabalí', 'ru': 'Кабан', 'pt': 'Javali', 'th': 'หมูป่า'},
      descriptionMap: const {'zh': '力量强大，攻击性强', 'en': 'Powerful and aggressive', 'ja': '力が強く、攻撃的', 'ko': '힘이 세고 공격적', 'fr': 'Puissant et agressif', 'de': 'Kraftvoll und aggressiv', 'es': 'Potente y agresivo', 'ru': 'Мощный и агрессивный', 'pt': 'Poderoso e agressivo', 'th': 'แข็งแกร่งและดุร้าย'},
      counterSoundMap: const {'zh': '狮子吼叫', 'en': 'Lion Roar', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'},
      fullDescriptionMap: const {'zh': '野猪体型庞大，力量惊人，遇到威胁时会主动攻击。狮子作为森林之王的吼叫声能够传达强大的威慑力，让野猪感知到潜在威胁而避开。', 'en': 'Wild boars are massive and incredibly strong, actively attacking when threatened. The roar of a lion conveys powerful deterrence, making boars stay away.', 'ja': 'イノシシは体が大きく力が強く、脅威を感じると攻撃してきます。ライオンの咆哮は強力な威嚇力を伝え、イノシシを遠ざけます。', 'ko': '멧돼지는 체구가 크고 힘이 엄청나며, 위협을 받으면 공격합니다. 사자의 포효는 강력한 위협을 전달하여 멧돼지를 쫓아냅니다.', 'fr': 'Les sangliers sont massifs et forts, attaquant activement quand menacés. Le rugissement du lion transmet une forte dissuasion.', 'de': 'Wildschweine sind massiv und stark. Das Brüllen des Löwen vermittelt starke Abschreckung und hält sie auf Abstand.', 'es': 'Los jabalíes son masivos y fuertes. El rugido del león transmite poderosa disuasión, haciéndolos alejarse.', 'ru': 'Кабаны массивны и сильны, атакуют при угрозе. Рык льва передаёт мощное устрашение, заставляя их держаться подальше.', 'pt': 'Javalis são massivos e fortes. O rugido do leão transmite poderosa dissuasão, fazendo-os se afastar.', 'th': 'หมูป่าตัวใหญ่และแข็งแกร่ง เสียงคำรามของสิงโตส่งผลขู่อย่างทรงพลัง ทำให้หมูป่าหนีห่าง'},
      category: AnimalCategory.beast,
      recommendedDb: 90.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.9,
      frequencyRange: '50Hz-5kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狮子吼叫', 'en': 'Lion Roar', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'}, rating: 5, soundGroup: 'lion', soundCount: 3, volumeWeight: 1.0, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 4, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.95, frequencyRange: '20Hz-1kHz', estimatedDb: 95),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.85, frequencyRange: '200Hz-6kHz', estimatedDb: 85),
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
      nameMap: const {'zh': '熊', 'en': 'Bear', 'ja': '熊', 'ko': '곰', 'fr': 'Ours', 'de': 'Bär', 'es': 'Oso', 'ru': 'Медведь', 'pt': 'Urso', 'th': 'หมี'},
      descriptionMap: const {'zh': '大型猛兽，破坏力强', 'en': 'Large predator, highly destructive', 'ja': '大型猛獣、破壊力が強い', 'ko': '대형 맹수, 파괴력 강함', 'fr': 'Grand prédateur, très destructeur', 'de': 'Großes Raubtier, sehr zerstörerisch', 'es': 'Gran depredador, muy destructivo', 'ru': 'Крупный хищник, очень разрушительный', 'pt': 'Grande predador, muito destrutivo', 'th': 'สัตว์นักล่าขนาดใหญ่ ทำลายล้างมาก'},
      counterSoundMap: const {'zh': '枪声模拟', 'en': 'Gunshot Simulation', 'ja': '銃声シミュレーション', 'ko': '총소리 시뮬레이션', 'fr': 'Simulation de coup de feu', 'de': 'Schusssimulation', 'es': 'Simulación de disparo', 'ru': 'Имитация выстрела', 'pt': 'Simulação de tiro', 'th': 'จำลองเสียงปืน'},
      fullDescriptionMap: const {'zh': '熊是极具攻击性的大型猛兽，遇到人类时可能造成致命伤害。枪声的模拟能够传达人类武器的威胁，让熊意识到潜在危险而远离。', 'en': 'Bears are extremely aggressive large predators that can cause fatal injuries. Gunshot simulation conveys the threat of human weapons, making bears stay away.', 'ja': '熊は非常に攻撃的な大型猛獣であり、人間に致命的な被害を与える可能性があります。銃声のシミュレーションは武器の脅威を伝え、熊を遠ざけます。', 'ko': '곰은 극히 공격적인 대형 맹수로, 치명적인 상해를 입힐 수 있습니다. 총소리 시뮬레이션은 무기의 위협을 전달하여 곰을 쫓아냅니다.', 'fr': 'Les ours sont de grands prédateurs extrêmement agressifs. La simulation de coup de feu transmet la menace des armes humaines et les éloigne.', 'de': 'Bären sind extrem aggressive Großraubtiere. Die Schusssimulation vermittelt die Bedrohung durch Waffen und hält Bären auf Abstand.', 'es': 'Los osos son grandes depredadores extremadamente agresivos. La simulación de disparo transmite la amenaza de armas humanas y los aleja.', 'ru': 'Медведи — крайне агрессивные крупные хищники. Имитация выстрела передаёт угрозу оружия и заставляет их держаться подальше.', 'pt': 'Ursos são grandes predadores extremamente agressivos. A simulação de tiro transmite a ameaça de armas e os afasta.', 'th': 'หมีเป็นสัตว์นักล่าขนาดใหญ่ที่ดุร้ายมาก การจำลองเสียงปืนส่งผลขู่ของอาวุธและทำให้หมีหนีห่าง'},
      category: AnimalCategory.beast,
      recommendedDb: 95.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.95,
      frequencyRange: '50Hz-10kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 5, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '200Hz-6kHz', estimatedDb: 85),
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
      nameMap: const {'zh': '狼', 'en': 'Wolf', 'ja': 'オオカミ', 'ko': '늑대', 'fr': 'Loup', 'de': 'Wolf', 'es': 'Lobo', 'ru': 'Волк', 'pt': 'Lobo', 'th': 'หมาป่า'},
      descriptionMap: const {'zh': '夜间狩猎，群体性强', 'en': 'Nocturnal hunter, strong pack behavior', 'ja': '夜行性、群れ行動が強い', 'ko': '야행성 사냥꾼, 무리 행동 강함', 'fr': 'Chasseur nocturne, fort comportement de meute', 'de': 'Nächtlicher Jäger, starkes Rudelverhalten', 'es': 'Cazador nocturno, fuerte comportamiento de manada', 'ru': 'Ночной охотник, сильное стайное поведение', 'pt': 'Caçador noturno, forte comportamento de matilha', 'th': 'นักล่ากลางคืน อยู่เป็นฝูง'},
      counterSoundMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'},
      fullDescriptionMap: const {'zh': '狼是夜行性动物，具有极强的群体狩猎能力。狼嚎声能够模拟同类间的交流，传达领域占有信息，从而威慑狼群。', 'en': 'Wolves are nocturnal animals with strong pack hunting abilities. Wolf howls simulate intraspecific communication, conveying territorial possession to deter wolf packs.', 'ja': 'オオカミは夜行性で、群れでの狩猟能力が高い動物です。オオカミの遠吠えは種内コミュニケーションを模倣し、縄張り情報を伝えて群れを威嚇します。', 'ko': '늑대는 야행성 동물로 무리 사냥 능력이 뛰어납니다. 늑대 울음소리는 종내 소통을 모방하여 영역 정보를 전달하고 무리를 위협합니다.', 'fr': 'Les loups sont nocturnes avec de fortes capacités de chasse en meute. Les hurlements simulent la communication intraspécifique pour dissuader les meutes.', 'de': 'Wölfe sind nachtaktiv mit starker Rudeljagdfähigkeit. Wolfsheulen ahmen innerartliche Kommunikation nach und schrecken Rudel ab.', 'es': 'Los lobos son nocturnos con fuertes capacidades de caza en manada. Los aullidos simulan comunicación intraespecífica para disuadir a las manadas.', 'ru': 'Волки — ночные животные с сильными стайными способностями. Вой имитирует внутривидовую коммуникацию для отпугивания стай.', 'pt': 'Lobos são noturnos com fortes capacidades de caça em matilha. Os uivos simulam comunicação intraespecífica para dissuadir matilhas.', 'th': 'หมาป่าเป็นสัตว์หากินกลางคืนที่ล่าเป็นฝูงเก่ง เสียงหอนจำลองการสื่อสารในฝูงเพื่อขู่ฝูงหมาป่า'},
      category: AnimalCategory.beast,
      recommendedDb: 85.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.88,
      frequencyRange: '150Hz-5kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'}, rating: 5, soundGroup: 'wolf', soundCount: 3, volumeWeight: 1.0, frequencyRange: '150Hz-2kHz', estimatedDb: 85),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.95, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 3, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '1kHz-8kHz', estimatedDb: 70),
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
      nameMap: const {'zh': '狐狸', 'en': 'Fox', 'ja': 'キツネ', 'ko': '여우', 'fr': 'Renard', 'de': 'Fuchs', 'es': 'Zorro', 'ru': 'Лиса', 'pt': 'Raposa', 'th': 'สุนัขจิ้งจอก'},
      descriptionMap: const {'zh': '夜间活动，偷食家禽', 'en': 'Nocturnal, poultry thief', 'ja': '夜行性、家禽を盗む', 'ko': '야행성, 가금류 도둑', 'fr': 'Nocturne, voleur de volaille', 'de': 'Nachtaktiv, Geflügeldieb', 'es': 'Nocturno, ladrón de aves', 'ru': 'Ночной, вор домашней птицы', 'pt': 'Noturno, ladrão de aves', 'th': 'ออกหากินกลางคืน ขโมยสัตว์ปีก'},
      counterSoundMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'},
      fullDescriptionMap: const {'zh': '狐狸夜间活动，常偷食家禽。狗吠声能够模拟天敌威胁，驱赶狐狸。', 'en': 'Foxes are nocturnal and often steal poultry. Dog barking simulates predator threats, driving foxes away.', 'ja': 'キツネは夜行性で、よく家禽を盗みます。犬の吠え声は天敵の脅威を模倣し、キツネを追い払います。', 'ko': '여우는 야행성으로 가금류를 훔칩니다. 개 짖는 소리는 천적의 위협을 모방하여 여우를 쫓아냅니다.', 'fr': 'Les renards sont nocturnes et volent souvent la volaille. Les aboiements simulent la menace de prédateurs et chassent les renards.', 'de': 'Füchse sind nachtaktiv und stehlen oft Geflügel. Hundebellen simuliert Prädatorenbedrohung und vertreibt Füchse.', 'es': 'Los zorros son nocturnos y roban aves. Los ladridos simulan amenazas de depredadores y ahuyentan a los zorros.', 'ru': 'Лисы ведут ночной образ жизни и воруют птицу. Собачий лай имитирует угрозу хищников и отпугивает лис.', 'pt': 'Raposas são noturnas e roubam aves. Latidos simulam ameaças de predadores e afugentam raposas.', 'th': 'สุนัขจิ้งจอกออกหากินกลางคืนและขโมยสัตว์ปีก เสียงหอนหมาจำลองภัยจากผู้ล่าและไล่สุนัขจิ้งจอก'},
      category: AnimalCategory.beast,
      recommendedDb: 75.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.8,
      frequencyRange: '200Hz-6kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'}, rating: 5, soundGroup: 'dog', soundCount: 3, volumeWeight: 1.0, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
      ],
      iconName: 'pets',
      iconPaths: {
        'v3': 'assets/images/icons/v3/fox.jpg',
      },
    ),

    // ============ 爬行类 ============
    Animal(
      id: 'snake',
      nameMap: const {'zh': '毒蛇', 'en': 'Venomous Snake', 'ja': '毒蛇', 'ko': '독사', 'fr': 'Serpent venimeux', 'de': 'Giftschlange', 'es': 'Serpiente venenosa', 'ru': 'Ядовитая змея', 'pt': 'Cobra venenosa', 'th': 'งูพิษ'},
      descriptionMap: const {'zh': '夜间活动，毒性危险', 'en': 'Nocturnal, dangerously venomous', 'ja': '夜行性、猛毒の危険', 'ko': '야행성, 맹독 위험', 'fr': 'Nocturne, dangereusement venimeux', 'de': 'Nachtaktiv, gefährlich giftig', 'es': 'Nocturno, peligrosamente venenoso', 'ru': 'Ночной, опасно ядовитый', 'pt': 'Noturno, perigosamente venenoso', 'th': 'ออกหากินกลางคืน พิษอันตราย'},
      counterSoundMap: const {'zh': '雄鸡啼鸣', 'en': 'Rooster Crow', 'ja': '鶏の鳴き声', 'ko': '수탉 울음소리', 'fr': 'Chant de coq', 'de': 'Hahnenschrei', 'es': 'Canto del gallo', 'ru': 'Кукареканье петуха', 'pt': 'Canto do galo', 'th': 'เสียงไก่ขัน'},
      fullDescriptionMap: const {'zh': '毒蛇在野外是极其危险的生物，尤其在夜间活动频繁。雄鸡的啼鸣声模拟了蛇类天敌（如獴类动物）的警告声，能够有效驱赶毒蛇。', 'en': 'Venomous snakes are extremely dangerous in the wild, especially at night. Rooster crowing simulates the warning sound of snake predators (like mongooses), effectively driving them away.', 'ja': '毒蛇は野外で非常に危険な生き物であり、特に夜間に活動が活発です。鶏の鳴き声は蛇の天敵の警告音を模倣し、毒蛇を効果的に追い払います。', 'ko': '독사는 야외에서 극히 위험한 생물이며, 특히 야간에 활동이 빈번합니다. 수탉의 울음소리는 뱀의 천적의 경고 소리를 모방하여 독사를 효과적으로 쫓아냅니다.', 'fr': 'Les serpents venimeux sont extrêmement dangereux dans la nature, surtout la nuit. Le chant du coq simule le son d\'alerte des prédateurs de serpents, les chassant efficacement.', 'de': 'Giftschlangen sind in der Wildnis extrem gefährlich, besonders nachts. Hahnenschrei ahmt das Warnsignal von Schlangenprädatoren nach und vertreibt sie effektiv.', 'es': 'Las serpientes venenosas son extremadamente peligrosas en la naturaleza, especialmente de noche. El canto del gallo simula el sonido de alerta de depredadores, ahuyentándolas eficazmente.', 'ru': 'Ядовитые змеи крайне опасны в дикой природе, особенно ночью. Кукареканье петуха имитирует звук предупреждения хищников змей, эффективно отпугивая их.', 'pt': 'Cobras venenosas são extremamente perigosas na natureza, especialmente à noite. O canto do galo simula o som de alerta dos predadores, afugentando-as eficazmente.', 'th': 'งูพิษเป็นสัตว์อันตรายมากในธรรมชาติ โดยเฉพาะตอนกลางคืน เสียงไก่ขันจำลองเสียงเตือนจากศัตรูธรรมชาติของงู ไล่งูพิษออกไปได้อย่างมีประสิทธิภาพ'},
      category: AnimalCategory.reptile,
      recommendedDb: 65.0,
      effectiveRange: 8.0,
      recommendedVolume: 0.65,
      frequencyRange: '100Hz-4kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '雄鸡啼鸣', 'en': 'Rooster Crow', 'ja': '鶏の鳴き声', 'ko': '수탉 울음소리', 'fr': 'Chant de coq', 'de': 'Hahnenschrei', 'es': 'Canto del gallo', 'ru': 'Кукареканье петуха', 'pt': 'Canto do galo', 'th': 'เสียงไก่ขัน'}, rating: 5, soundGroup: 'rooster', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-4kHz', estimatedDb: 75),
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '300Hz-3kHz', estimatedDb: 70),
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 3, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '50Hz-500Hz', estimatedDb: 85),
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
      nameMap: const {'zh': '猴子', 'en': 'Monkey', 'ja': '猿', 'ko': '원숭이', 'fr': 'Singe', 'de': 'Affe', 'es': 'Mono', 'ru': 'Обезьяна', 'pt': 'Macaco', 'th': 'ลิง'},
      descriptionMap: const {'zh': '群体骚扰，抢夺物品', 'en': 'Pack harassment, snatching items', 'ja': '群れで嫌がらせ、物を奪う', 'ko': '무리 괴롭힘, 물건 약탈', 'fr': 'Harcèlement en groupe, vol d\'objets', 'de': 'Rudelbelästigung, Diebstahl', 'es': 'Acoso en manada, robo de objetos', 'ru': 'Стайное домогательство, хищение вещей', 'pt': 'Assédio em bando, roubo de itens', 'th': 'รบกวนเป็นฝูง ขโมยของ'},
      counterSoundMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'},
      fullDescriptionMap: const {'zh': '猴子虽然个体不大，但群体行动时会骚扰人类并抢夺食物。鹰作为天空霸主的啸声能够模拟天敌威胁，让猴群感到恐慌而逃离。', 'en': 'Monkeys may be small individually, but in packs they harass humans and snatch food. Eagle screeches simulate predator threats, causing panic in monkey troops and driving them away.', 'ja': '猿は個体としては小さいですが、群れで行動すると人間に嫌がらせをし、食べ物を奪います。鷹の鳴き声は天声は天敵の脅威を模倣し、猿の群れを追い払います。', 'ko': '원숭이는 개체는 작지만 무리로 행동하면 인간을 괴롭히고 음식을 약탈합니다. 독수리의 울음소리는 천적의 위협을 모방하여 원숭이 무리를 쫓아냅니다.', 'fr': 'Les singes peuvent être petits individuellement, mais en troupes ils harcèlent les humains et volent de la nourriture. Les cris d\'aigle simulent la menace de prédateurs et chassent les troupes.', 'de': 'Affen sind einzeln klein, aber in Trupps belästigen sie Menschen und stehlen Essen. Adlerschreie simulieren Prädatorenbedrohung und vertreiben Affentrupps.', 'es': 'Los monos pueden ser pequeños individualmente, pero en tropa acosan a los humanos y roban comida. Los chillidos de águila simulan amenazas de depredadores y ahuyentan a las tropas.', 'ru': 'Обезьяны могут быть небольшими по отдельности, но стаями досаждают людям и воруют еду. Крики орла имитируют угрозу хищников и отпугивают стаю.', 'pt': 'Macacos podem ser pequenos individualmente, mas em bando assediam humanos e roubam comida. Gritos de águia simulam ameaças de predadores e os afugentam.', 'th': 'ลิงแม้จะตัวเล็กแต่เมื่ออยู่เป็นฝูงจะรบกวนมนุษย์และขโมยอาหาร เสียงนกอินทรีจำลองภัยจากผู้ล่าและไล่ฝูงลิง'},
      category: AnimalCategory.primate,
      recommendedDb: 75.0,
      effectiveRange: 15.0,
      recommendedVolume: 0.78,
      frequencyRange: '500Hz-8kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'}, rating: 5, soundGroup: 'eagle', soundCount: 3, volumeWeight: 1.0, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
        RecommendedSound(nameMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'}, rating: 4, soundGroup: 'dog', soundCount: 3, volumeWeight: 0.85, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.7, frequencyRange: '2kHz-10kHz', estimatedDb: 75),
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
      nameMap: const {'zh': '老鼠', 'en': 'Mouse', 'ja': 'ネズミ', 'ko': '쥐', 'fr': 'Souris', 'de': 'Maus', 'es': 'Ratón', 'ru': 'Мышь', 'pt': 'Rato', 'th': 'หนู'},
      descriptionMap: const {'zh': '夜间活动，传播疾病', 'en': 'Nocturnal, disease carrier', 'ja': '夜行性、病気を媒介', 'ko': '야행성, 질병 매개', 'fr': 'Nocturne, porteur de maladies', 'de': 'Nachtaktiv, Krankheitsüberträger', 'es': 'Nocturno, transmisor de enfermedades', 'ru': 'Ночной, переносчик болезней', 'pt': 'Noturno, transmissor de doenças', 'th': 'ออกหากินกลางคืน พาหะนำโรค'},
      counterSoundMap: const {'zh': '猫叫声', 'en': 'Cat Meow', 'ja': '猫の鳴き声', 'ko': '고양이 울음소리', 'fr': 'Miaulement de chat', 'de': 'Katzenmaunzen', 'es': 'Maullido de gato', 'ru': 'Мяуканье кошки', 'pt': 'Miau de gato', 'th': 'เสียงแมว'},
      fullDescriptionMap: const {'zh': '老鼠是常见的害虫，不仅破坏物品还会传播疾病。猫作为老鼠的天敌，其叫声能够有效驱赶老鼠，保护居住环境。', 'en': 'Mice are common pests that damage property and spread disease. As natural predators of mice, cat sounds can effectively drive them away and protect your living space.', 'ja': 'ネズミは一般的な害獣であり、物を破壊するだけでなく病気も媒介します。ネズミの天敵である猫の鳴き声は、ネズミを効果的に追い払い、住環境を守ります。', 'ko': '쥐는 흔한 해충으로 재산을 파괴하고 질병을 옮깁니다. 쥐의 천적인 고양이 소리는 쥐를 효과적으로 쫓아내어 주거 환경을 보호합니다.', 'fr': 'Les souris sont des nuisibles courants qui endommagent les biens et propagent des maladies. Les sons de chat, prédateurs naturels, les chassent efficacement.', 'de': 'Mäuse sind häufige Schädlinge, die Eigentum beschädigen und Krankheiten verbreiten. Katzenlaute als natürliche Feinde vertreiben sie effektiv.', 'es': 'Los ratones son plagas comunes que dañan la propiedad y propagan enfermedades. Los sonidos de gato, sus depredadores naturales, los ahuyentan eficazmente.', 'ru': 'Мыши — распространённые вредители, разрушающие имущество и распространяющие болезни. Кошачьи звуки, как естественные хищники, эффективно отпугивают их.', 'pt': 'Ratos são pragas comuns que danificam propriedades e espalham doenças. Sons de gato, seus predadores naturais, os afugentam eficazmente.', 'th': 'หนูเป็นศัตรูพืชทั่วไปที่ทำลายทรัพย์สินและแพร่โรค เสียงแมวในฐานะศัตรูธรรมชาติของหนูสามารถไล่หนูออกไปได้อย่างมีประสิทธิภาพ'},
      category: AnimalCategory.rodent,
      recommendedDb: 55.0,
      effectiveRange: 5.0,
      recommendedVolume: 0.6,
      frequencyRange: '1kHz-22kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '猫叫声', 'en': 'Cat Meow', 'ja': '猫の鳴き声', 'ko': '고양이 울음소리', 'fr': 'Miaulement de chat', 'de': 'Katzenmaunzen', 'es': 'Maullido de gato', 'ru': 'Мяуканье кошки', 'pt': 'Miau de gato', 'th': 'เสียงแมว'}, rating: 5, soundGroup: 'cat', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-5kHz', estimatedDb: 65),
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.9, frequencyRange: '18kHz-22kHz', estimatedDb: 60),
      ],
      iconName: 'pest_control',
      iconPaths: {
        'v3': 'assets/images/icons/v3/mouse.jpg',
      },
    ),
    Animal(
      id: 'rabbit',
      nameMap: const {'zh': '野兔', 'en': 'Wild Rabbit', 'ja': '野ウサギ', 'ko': '토끼', 'fr': 'Lapin sauvage', 'de': 'Wildkaninchen', 'es': 'Conejo silvestre', 'ru': 'Дикий кролик', 'pt': 'Coelho selvagem', 'th': 'กระต่ายป่า'},
      descriptionMap: const {'zh': '农田害兽，繁殖快', 'en': 'Farm pest, rapid reproduction', 'ja': '農業害獣、繁殖が早い', 'ko': '농업 해수, 번식이 빠름', 'fr': 'Nuisible agricole, reproduction rapide', 'de': 'Agrarschädling, schnelle Vermehrung', 'es': 'Plaga agrícola, reproducción rápida', 'ru': 'Сельскохозяйственный вредитель, быстрое размножение', 'pt': 'Praga agrícola, reprodução rápida', 'th': 'ศัตรูพืชไร่นา ขยายพันธุ์เร็ว'},
      counterSoundMap: const {'zh': '猎犬吠叫', 'en': 'Hound Bark', 'ja': '猟犬の吠え声', 'ko': '사냥개 짖는 소리', 'fr': 'Aboiement de chien de chasse', 'de': 'Jagdhundbellen', 'es': 'Ladrido de sabueso', 'ru': 'Лай гончей', 'pt': 'Latido de cão de caça', 'th': 'เสียงหมาล่าเนื้อ'},
      fullDescriptionMap: const {'zh': '野兔繁殖能力强，对农作物造成损害。猎犬吠叫能够模拟天敌威胁，驱赶野兔。', 'en': 'Wild rabbits reproduce rapidly and damage crops. Hound barking simulates predator threats, driving rabbits away.', 'ja': '野ウサギは繁殖力が強く、農作物に被害を与えます。猟犬の吠え声は天天敵の脅威を模倣し、野ウサギを追い払います。', 'ko': '토끼는 번식력이 강해 농작물에 피해를 줍니다. 사냥개 짖는 소리는 천적의 위협을 모방하여 토끼를 쫓아냅니다.', 'fr': 'Les lapins sauvages se reproduisent rapidement et endommagent les cultures. Les aboiements de chien de chasse simulent la menace de prédateurs.', 'de': 'Wildkaninchen vermehren sich schnell und beschädigen Nutzpflanzen. Jagdhundbellen simuliert Prädatorenbedrohung.', 'es': 'Los conejos silvestres se reproducen rápidamente y dañan los cultivos. Los ladridos de sabueso simulan amenazas de depredadores.', 'ru': 'Дикие кролики быстро размножаются и повреждают посевы. Лай гончей имитирует угрозу хищников.', 'pt': 'Coelhos selvagens se reproduzem rapidamente e danificam plantações. Latidos de cão de caça simulam ameaças de predadores.', 'th': 'กระต่ายป่าขยายพันธุ์เร็วและทำลายพืชผล เสียงหมาล่าเนื้อจำลองภัยจากผู้ล่าและไล่กระต่ายป่า'},
      category: AnimalCategory.rodent,
      recommendedDb: 70.0,
      effectiveRange: 12.0,
      recommendedVolume: 0.7,
      frequencyRange: '300Hz-6kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'}, rating: 5, soundGroup: 'dog', soundCount: 3, volumeWeight: 1.0, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(nameMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'}, rating: 4, soundGroup: 'eagle', soundCount: 3, volumeWeight: 0.85, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
      ],
      iconName: 'grass',
      iconPaths: {
        'v3': 'assets/images/icons/v3/rabbit.jpg',
      },
    ),

    // ============ 昆虫类 ============
    Animal(
      id: 'spider',
      nameMap: const {'zh': '毒蜘蛛', 'en': 'Venomous Spider', 'ja': '毒蜘蛛', 'ko': '독거미', 'fr': 'Araignée venimeuse', 'de': 'Giftspinne', 'es': 'Araña venenosa', 'ru': 'Ядовитый паук', 'pt': 'Aranha venenosa', 'th': 'แมงมุมพิษ'},
      descriptionMap: const {'zh': '夜间活动，毒性危险', 'en': 'Nocturnal, dangerously venomous', 'ja': '夜行性、猛毒の危険', 'ko': '야행성, 맹독 위험', 'fr': 'Nocturne, dangereusement venimeux', 'de': 'Nachtaktiv, gefährlich giftig', 'es': 'Nocturno, peligrosamente venenoso', 'ru': 'Ночной, опасно ядовитый', 'pt': 'Noturno, perigosamente venenoso', 'th': 'ออกหากินกลางคืน พิษอันตราย'},
      counterSoundMap: const {'zh': '震动声', 'en': 'Vibration Sound', 'ja': '振動音', 'ko': '진동음', 'fr': 'Son de vibration', 'de': 'Vibrationsgeräusch', 'es': 'Sonido de vibración', 'ru': 'Звук вибрации', 'pt': 'Som de vibração', 'th': 'เสียงสั่น'},
      fullDescriptionMap: const {'zh': '毒蜘蛛多在夜间活动，具有较强的毒性。高频震动声能够干扰蜘蛛的感知系统，使其离开栖息地。', 'en': 'Venomous spiders are mostly nocturnal with potent venom. High-frequency vibration sounds can disrupt their sensory systems, driving them from their habitats.', 'ja': '毒蜘蛛は主に夜行性で、強い毒性を持っています。高周波振動音は蜘蛛の知覚システムを乱し、生息地から追い出します。', 'ko': '독거미는 대부분 야행성이며 강한 독을 가지고 있습니다. 고주파 진동음은 거미의 감각 시스템을 방해하여 서식지에서 쫓아냅니다.', 'fr': 'Les araignées venimeuses sont surtout nocturnes avec un venin puissant. Les sons de vibration haute fréquence perturbent leur système sensoriel et les chassent de leur habitat.', 'de': 'Giftspinnen sind meist nachtaktiv mit starkem Gift. Hochfrequente Vibrationssounds stören ihr Sinnessystem und vertreiben sie aus ihren Lebensräumen.', 'es': 'Las arañas venenosas son principalmente nocturnas con veneno potente. Los sonidos de vibración de alta frecuencia perturban su sistema sensorial y las ahuyentan.', 'ru': 'Ядовитые пауки в основном ночные с сильным ядом. Звуки высокочастотной вибрации нарушают их сенсорную систему и вынуждают покинуть места обитания.', 'pt': 'Aranhas venenosas são principalmente noturnas com veneno potente. Sons de vibração de alta frequência perturbam seu sistema sensorial e as afugentam.', 'th': 'แมงมุมพิษส่วนใหญ่ออกหากินกลางคืนและมีพิษรุนแรง เสียงสั่นความถี่สูงรบกวนระบบรับความรู้สึกของแมงมุมและไล่ออกจากที่อยู่'},
      category: AnimalCategory.insect,
      recommendedDb: 50.0,
      effectiveRange: 3.0,
      recommendedVolume: 0.55,
      frequencyRange: '15kHz-22kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 5, soundGroup: 'vibration', soundCount: 3, volumeWeight: 1.0, frequencyRange: '20kHz-22kHz', estimatedDb: 55),
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 4, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.7, frequencyRange: '200Hz-3kHz', estimatedDb: 65),
      ],
      iconName: 'bug_report',
      iconPaths: {
        'v3': 'assets/images/icons/v3/spider.jpg',
      },
    ),
    Animal(
      id: 'wasp',
      nameMap: const {'zh': '马蜂', 'en': 'Wasp', 'ja': 'スズメバチ', 'ko': '말벌', 'fr': 'Guêpe', 'de': 'Wespe', 'es': 'Avispa', 'ru': 'Оса', 'pt': 'Vespa', 'th': 'ต่อ'},
      descriptionMap: const {'zh': '群体攻击，毒性较强', 'en': 'Swarm attacks, highly venomous', 'ja': '群れで攻撃、毒性が強い', 'ko': '무리 공격, 독성이 강함', 'fr': 'Attaques en essaim, très venimeux', 'de': 'Schwarmangriffe, sehr giftig', 'es': 'Ataques en enjambre, muy venenosos', 'ru': 'Атаки роями, очень ядовиты', 'pt': 'Ataques em enxame, muito venenosos', 'th': 'โจมตีเป็นฝูง พิษรุนแรง'},
      counterSoundMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'},
      fullDescriptionMap: const {'zh': '马蜂具有强烈的护巢本能，一旦受到惊扰会群体攻击。低频声波能够干扰马蜂的飞行平衡，使其远离。', 'en': 'Wasps have strong nest-protecting instincts and attack in swarms when disturbed. Low-frequency waves can disrupt their flight balance, keeping them away.', 'ja': 'スズメバチは強い巣の防衛本能を持ち、驚かされると群れで攻撃してきます。低周波は飛行バランスを乱し、遠ざけます。', 'ko': '말벌은 강한 둥지 보호 본능이 있어 놀라면 무리로 공격합니다. 저주파는 비행 균형을 방해하여 멀어지게 합니다.', 'fr': 'Les guêpes ont de forts instincts de protection du nid et attaquent en essaim quand dérangées. Les ondes basse fréquence perturbent leur équilibre de vol et les éloignent.', 'de': 'Wespen haben starke Nestverteidigungsinstinkte und greifen im Schwarm an, wenn gestört. Niederfrequenzwellen stören ihr Fluggleichgewicht und halten sie fern.', 'es': 'Las avispas tienen fuertes instintos de protección del nido y atacan en enjambre al ser molestadas. Las ondas de baja frecuencia perturban su equilibrio de vuelo y las alejan.', 'ru': 'Осы обладают сильным инстинктом защиты гнезда и атакуют роями при беспокойстве. Низкочастотные волны нарушают их баланс полёта и отпугивают.', 'pt': 'Vespas têm fortes instintos de proteção do ninho e atacam em enxame quando perturbadas. Ondas de baixa frequência perturbam seu equilíbrio de voo e as afastam.', 'th': 'ต่อมีสัญชาตญูรักษารังแรงและโจมตีเป็นฝูงเมื่อถูกรบกวน คลื่นความถี่ต่ำรบกวนการทรงตัวบินและไล่ต่อออกไป'},
      category: AnimalCategory.insect,
      recommendedDb: 60.0,
      effectiveRange: 5.0,
      recommendedVolume: 0.65,
      frequencyRange: '15kHz-20kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 5, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 1.0, frequencyRange: '15kHz-18kHz', estimatedDb: 60),
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 4, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.8, frequencyRange: '2kHz-8kHz', estimatedDb: 65),
      ],
      iconName: 'hive',
      iconPaths: {
        'v3': 'assets/images/icons/v3/hornet.jpg',
      },
    ),

    // ============ 鸟类 ============
    Animal(
      id: 'crow',
      nameMap: const {'zh': '乌鸦', 'en': 'Crow', 'ja': 'カラス', 'ko': '까마귀', 'fr': 'Corbeau', 'de': 'Krähe', 'es': 'Cuervo', 'ru': 'Ворона', 'pt': 'Corvo', 'th': 'อีกา'},
      descriptionMap: const {'zh': '群体性强，破坏庄稼', 'en': 'Strong flocking, crop destroyer', 'ja': '群れ行動が強い、農作物を荒らす', 'ko': '무리 행동 강함, 농작물 파괴', 'fr': 'Fort comportement grégaire, destructeur de cultures', 'de': 'Starkes Schwarmverhalten, Erntevernichter', 'es': 'Fuerte comportamiento de bandada, destructor de cultivos', 'ru': 'Сильная стайность, уничтожитель посевов', 'pt': 'Forte comportamento de bando, destruidor de plantações', 'th': 'อยู่เป็นฝูง ทำลายพืชผล'},
      counterSoundMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'},
      fullDescriptionMap: const {'zh': '乌鸦群体性强，常破坏庄稼和果实。鹰啸声能够模拟天敌威胁，驱散乌鸦群。', 'en': 'Crows have strong flocking behavior and often destroy crops and fruits. Eagle screeches simulate predator threats, dispersing crow flocks.', 'ja': 'カラスは群れ行動が強く、農作物や果実を荒らします。鷹の鳴き声は天敵の脅威を模倣し、カラスの群れを散らします。', 'ko': '까마귀는 무리 행동이 강해 농작물과 과일을 파괴합니다. 독수리 울음소리는 천적의 위협을 모방하여 까마귀 무리를 흩어지게 합니다.', 'fr': 'Les corbeaux ont un fort comportement grégaire et détruisent souvent les cultures. Les cris d\'aigle simulent la menace de prédateurs et dispersent les volées.', 'de': 'Krähen haben starkes Schwarmverhalten und zerstören oft Ernten. Adlerschreie simulieren Prädatorenbedrohung und zerstreuen Krähenschwärme.', 'es': 'Los cuervos tienen fuerte comportamiento de bandada y destruyen cultivos. Los chillidos de águila simulan amenazas de depredadores y dispersan las bandadas.', 'ru': 'Вороны обладают сильной стайностью и часто уничтожают посевы. Крики орла имитируют угрозу хищников и разгоняют стаи ворон.', 'pt': 'Corvos têm forte comportamento de bando e destroem plantações. Gritos de águia simulam ameaças de predadores e dispersam bandos.', 'th': 'อีกาอยู่เป็นฝูงและมักทำลายพืชผล เสียงนกอินทรีจำลองภัยจากผู้ล่าและไล่ฝูงอีกาให้กระจัดกระจาย'},
      category: AnimalCategory.bird,
      recommendedDb: 75.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.78,
      frequencyRange: '500Hz-8kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'}, rating: 5, soundGroup: 'eagle', soundCount: 3, volumeWeight: 1.0, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
        RecommendedSound(nameMap: const {'zh': '震动声', 'en': 'Vibration', 'ja': '振動音', 'ko': '진동음', 'fr': 'Vibration', 'de': 'Vibration', 'es': 'Vibración', 'ru': 'Вибрация', 'pt': 'Vibração', 'th': 'เสียงสั่น'}, rating: 3, soundGroup: 'vibration', soundCount: 3, volumeWeight: 0.7, frequencyRange: '2kHz-8kHz', estimatedDb: 80),
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
