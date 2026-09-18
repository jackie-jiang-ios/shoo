/// 多语言翻译查找工具方法
/// 优先匹配当前语言，回退到英文，再回退到第一个可用值
String _t(Map<String, String> translations, String langCode) {
  return translations[langCode] ?? translations['en'] ?? translations.values.first;
}

/// 动物分类
enum AnimalCategory {
  all('all', const {'zh': '全部', 'en': 'All', 'ar': 'الكل', 'id': 'Semua', 'it': 'Tutti', 'ms': 'Semua', 'nl': 'Alle', 'pl': 'Wszystko', 'tr': 'Tümü', 'vi': 'Tất cả', 'hi': 'सभी', 'da': 'Alle', 'fi': 'Kaikki', 'gu': 'બધા', 'ca': 'Tot', 'cs': 'Vše', 'kn': 'ಎಲ್ಲಾ', 'hr': 'Sve', 'ro': 'Toate', 'mr': 'सर्व', 'ml': 'എല്ലാം', 'bn': 'সব', 'no': 'Alle', 'pa': 'ਸਭ', 'sv': 'Alla', 'sk': 'Všetko', 'sl': 'Vse', 'te': 'అన్ని', 'ta': 'அனைத்து', 'ur': 'سب', 'uk': 'Всі', 'he': 'הכל', 'el': 'Όλα', 'hu': 'Összes', 'or': 'ସମସ୍ତ', 'ja': 'すべて', 'ko': '전체', 'fr': 'Tout', 'de': 'Alle', 'es': 'Todo', 'ru': 'Все', 'pt': 'Todos', 'th': 'ทั้งหมด'}, '🐾'),
  beast('beast', const {'zh': '猛兽威胁', 'en': 'Beasts', 'ar': 'الوحوش', 'id': 'Buas', 'it': 'Bestie', 'ms': 'Buas', 'nl': 'Beesten', 'pl': 'Bestie', 'tr': 'Canavarlar', 'vi': 'Thú dữ', 'hi': 'जानवर', 'da': 'Dyr', 'fi': 'Pedot', 'gu': 'રાક્ષસો', 'ca': 'Bèsties', 'cs': 'Šelmy', 'kn': 'ಪ್ರಾಣಿಗಳು', 'hr': 'Zvijeri', 'ro': 'Bestii', 'mr': 'प्राणी', 'ml': 'മൃഗങ്ങൾ', 'bn': 'পশু', 'no': 'Dyr', 'pa': 'ਜਾਨਵਰ', 'sv': 'Djur', 'sk': 'Šelmy', 'sl': 'Zveri', 'te': 'జంతువులు', 'ta': 'விலங்குகள்', 'ur': 'جانور', 'uk': 'Хижаки', 'he': 'חיות', 'el': 'Θηρία', 'hu': 'Vadak', 'or': 'ପଶୁ', 'ja': '猛獣', 'ko': '맹수', 'fr': 'Bêtes féroces', 'de': 'Raubtiere', 'es': 'Bestias', 'ru': 'Хищники', 'pt': 'Feras', 'th': 'สัตว์นักล่า'}, '🦁'),
  reptile('reptile', const {'zh': '爬行类', 'en': 'Reptiles', 'ar': 'الزواحف', 'id': 'Reptil', 'it': 'Rettili', 'ms': 'Reptilia', 'nl': 'Reptielen', 'pl': 'Gady', 'tr': 'Sürüngenler', 'vi': 'Bò sát', 'hi': 'सरीसृप', 'da': 'Krybdyr', 'fi': 'Matelijat', 'gu': 'સરિસૃપ', 'ca': 'Rèptils', 'cs': 'Plazi', 'kn': 'ಹಾವುಗಳು', 'hr': 'Gmazovi', 'ro': 'Reptile', 'mr': 'सरीसृप', 'ml': 'ഇലപ്പരിപ്പികൾ', 'bn': 'সরীসৃপ', 'no': 'Krypdyr', 'pa': 'ਸਰੀਸੱਪ', 'sv': 'Kräldjur', 'sk': 'Plazy', 'sl': 'Plazilci', 'te': 'సరీసృపాలు', 'ta': 'ஊர்வன', 'ur': 'رینگنے والے', 'uk': 'Плазуни', 'he': 'זחלים', 'el': 'Ερπετά', 'hu': 'Hüllők', 'or': 'ସରୀସୃପ', 'ja': '爬虫類', 'ko': '파충류', 'fr': 'Reptiles', 'de': 'Reptilien', 'es': 'Reptiles', 'ru': 'Рептилии', 'pt': 'Répteis', 'th': 'สัตว์เลื้อยคลาน'}, '🐍'),
  primate('primate', const {'zh': '灵长类', 'en': 'Primates', 'ar': 'الرئيسيات', 'id': 'Primata', 'it': 'Primati', 'ms': 'Primate', 'nl': 'Primaten', 'pl': 'Naczelne', 'tr': 'Primatlar', 'vi': 'Linh trưởng', 'hi': 'वानर', 'da': 'Primater', 'fi': 'Kädelliset', 'gu': 'પ્રાઇમેટ્સ', 'ca': 'Primats', 'cs': 'Primáti', 'kn': 'ಪ್ರೈಮೇಟ್‌ಗಳು', 'hr': 'Primati', 'ro': 'Primate', 'mr': 'प्राइमेट्स', 'ml': 'പ്രൈമേറ്റുകൾ', 'bn': 'প्रাইমেট', 'no': 'Primater', 'pa': 'ਪ੍ਰਾਈਮੇਟ', 'sv': 'Primater', 'sk': 'Primáty', 'sl': 'Prvaki', 'te': 'ప್ರೈಮేట్‌లు', 'ta': 'முதன்மைக் குரங்குகள்', 'ur': 'پرائیمز', 'uk': 'Примати', 'he': 'פרימטים', 'el': 'Πρωτεύοντα', 'hu': 'Főemlősök', 'or': 'ପ୍ରାଇମେଟ୍', 'ja': '霊長類', 'ko': '영장류', 'fr': 'Primates', 'de': 'Primaten', 'es': 'Primates', 'ru': 'Приматы', 'pt': 'Primatas', 'th': 'สัตว์อันดับลิง'}, '🐒'),
  rodent('rodent', const {'zh': '啮齿类', 'en': 'Rodents', 'ar': 'القوارض', 'id': 'Rodensia', 'it': 'Roditori', 'ms': 'Rodensia', 'nl': 'Knaagdieren', 'pl': 'Gryzonie', 'tr': 'Kemirgenler', 'vi': 'Gặm nhấm', 'hi': 'कृंतक', 'da': 'Gnavere', 'fi': 'Jyrsijät', 'gu': 'કત્તલીદાર', 'ca': 'Roedors', 'cs': 'Hlodavci', 'kn': 'ಗಿಣಿಪ್ರಾಣಿಗಳು', 'hr': 'Glodavci', 'ro': 'Șoareci', 'mr': 'छोटे प्राणी', 'ml': 'ഉരല്ക്കിളികൾ', 'bn': 'ইদুর', 'no': 'Gnavere', 'pa': 'ਕਿਰਦਾਰ', 'sv': 'Gnagare', 'sk': 'Hlodavce', 'sl': 'Glodavci', 'te': 'గింజలు', 'ta': 'எலிக்கோதுகள்', 'ur': 'چوہے دار جانور', 'uk': 'Гризуни', 'he': 'מכרסמים', 'el': 'Τρωκτικά', 'hu': 'Rágcsálók', 'or': 'କ୍ଷୁଦ୍ର ପଶୁ', 'ja': '齧歯類', 'ko': '설치류', 'fr': 'Rongeurs', 'de': 'Nagetiere', 'es': 'Roedores', 'ru': 'Грызуны', 'pt': 'Roedores', 'th': 'สัตว์ฟันแทะ'}, '🐭'),
  insect('insect', const {'zh': '昆虫类', 'en': 'Insects', 'ar': 'الحشرات', 'id': 'Serangga', 'it': 'Insetti', 'ms': 'Serangga', 'nl': 'Insecten', 'pl': 'Owady', 'tr': 'Böcekler', 'vi': 'Côn trùng', 'hi': 'कीट', 'da': 'Insekter', 'fi': 'Hyönteiset', 'gu': 'જંતુઓ', 'ca': 'Insectes', 'cs': 'Hmyz', 'kn': 'ಕೀಟಗಳು', 'hr': 'Kukci', 'ro': 'Insecte', 'mr': 'कीटक', 'ml': 'പ്രാണികൾ', 'bn': 'পোকা', 'no': 'Insekter', 'pa': 'ਕੀੜੇ', 'sv': 'Insekter', 'sk': 'Hmyz', 'sl': 'Žuželke', 'te': 'కీటకాలు', 'ta': 'பூச்சிகள்', 'ur': 'کیڑے', 'uk': 'Комахи', 'he': 'חרקים', 'el': 'Έντομα', 'hu': 'Rovarok', 'or': 'କୀଟ', 'ja': '昆虫類', 'ko': '곤충류', 'fr': 'Insectes', 'de': 'Insekten', 'es': 'Insectos', 'ru': 'Насекомые', 'pt': 'Insetos', 'th': 'แมลง'}, '🐛'),
  bird('bird', const {'zh': '鸟类', 'en': 'Birds', 'ar': 'الطيور', 'id': 'Burung', 'it': 'Uccelli', 'ms': 'Burung', 'nl': 'Vogels', 'pl': 'Ptaki', 'tr': 'Kuşlar', 'vi': 'Chim', 'hi': 'पक्षी', 'da': 'Fugle', 'fi': 'Linnut', 'gu': 'પક્ષીઓ', 'ca': 'Ocells', 'cs': 'Ptáci', 'kn': 'ಪಕ್ಷಿಗಳು', 'hr': 'Ptice', 'ro': 'Păsări', 'mr': 'पक्षी', 'ml': 'പക്ഷികൾ', 'bn': 'পাখি', 'no': 'Fugler', 'pa': 'ਪੰਛੀ', 'sv': 'Fåglar', 'sk': 'Vtáky', 'sl': 'Ptice', 'te': 'పక్షులు', 'ta': 'பறவைகள்', 'ur': 'پرندے', 'uk': 'Птахи', 'he': 'עופות', 'el': 'Πουλιά', 'hu': 'Madarak', 'or': 'ପକ୍ଷୀ', 'ja': '鳥類', 'ko': '조류', 'fr': 'Oiseaux', 'de': 'Vögel', 'es': 'Aves', 'ru': 'Птицы', 'pt': 'Aves', 'th': 'นก'}, '🦅');

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
  global('global', const {'zh': '通用音量', 'en': 'Global Volume', 'ar': 'مستوى الصوت العام', 'id': 'Volume Global', 'it': 'Volume globale', 'ms': 'Volume Global', 'nl': 'Globaal Volume', 'pl': 'Głośność ogólna', 'tr': 'Genel Ses', 'vi': 'Âm lượng chung', 'hi': 'वैश्विक वॉल्यूम', 'da': 'Global lydstyrke', 'fi': 'Yleinen volyymi', 'gu': 'ગ્લોબલ વોલ્યુમ', 'ca': 'Volum global', 'cs': 'Obecná hlasitost', 'kn': 'ಜಾಗತಿಕ ಪರಿಮಾಣ', 'hr': 'Opća glasnoća', 'ro': 'Volum global', 'mr': 'ग्लोबल व्हॉल्यूम', 'ml': 'ആഗോള വോളിയം', 'bn': 'গ্লোবাল ভলিউম', 'no': 'Global volum', 'pa': 'ਗਲੋਬਲ ਵੌਲਿਊਮ', 'sv': 'Global volym', 'sk': 'Globálna hlasitosť', 'sl': 'Splošna glasnost', 'te': 'గ్లోబల్ వాల్యూమ్', 'ta': 'உலகளாவிய ஒலியளவு', 'ur': 'عالمی آواز', 'uk': 'Загальна гучність', 'he': 'עוצמה כללית', 'el': 'Γενική ένταση', 'hu': 'Általános hangerő', 'or': 'ଗ୍ଲୋବାଲ୍ ଭଲ୍ୟୁମ୍', 'ja': '共通音量', 'ko': '공통 볼륨', 'fr': 'Volume global', 'de': 'Globaler Volume', 'es': 'Volumen global', 'ru': 'Общая громкость', 'pt': 'Volume global', 'th': 'ระดับเสียงรวม'}),

  /// 独立模式：每种动物使用各自推荐的音量
  individual('individual', const {'zh': '独立音量', 'en': 'Individual Volume', 'ar': 'مستوى الصوت الفردي', 'id': 'Volume Individu', 'it': 'Volume individuale', 'ms': 'Volume Individu', 'nl': 'Individueel Volume', 'pl': 'Głośność indywidualna', 'tr': 'Bireysel Ses', 'vi': 'Âm lượng riêng', 'hi': 'व्यक्तिगत वॉल्यूम', 'da': 'Individuel lydstyrke', 'fi': 'Yksilöllinen volyymi', 'gu': 'વ્યક્તિગત વોલ્યુમ', 'ca': 'Volum individual', 'cs': 'Individuální hlasitost', 'kn': 'ವೈಯಕ್ತಿಕ ಪರಿಮಾಣ', 'hr': 'Pojedinačna glasnoća', 'ro': 'Volum individual', 'mr': 'वैयक्तिक व्हॉल्यूम', 'ml': 'വ്യക്തിഗത വോളിയം', 'bn': 'ব্যক্তিগত ভলিউম', 'no': 'Individuell volum', 'pa': 'ਵਿਅਕਤੀਗਤ ਵੌਲਿਊਮ', 'sv': 'Individuell volym', 'sk': 'Individuálna hlasitosť', 'sl': 'Posamezna glasnost', 'te': 'వ్యక్తిగత వాల్యూమ్', 'ta': 'தனிப்பட்ட ஒலியளவு', 'ur': 'انفرادی آواز', 'uk': 'Індивідуальна гучність', 'he': 'עוצמה אישית', 'el': 'Ατομική ένταση', 'hu': 'Egyedi hangerő', 'or': 'ବ୍ୟକ୍ତିଗତ ଭଲ୍ୟୁମ୍', 'ja': '個別音量', 'ko': '개별 볼륨', 'fr': 'Volume individuel', 'de': 'Individueller Volume', 'es': 'Volumen individual', 'ru': 'Индивидуальная громкость', 'pt': 'Volume individual', 'th': 'ระดับเสียงแยก'});

  const VolumeMode(this.id, this.nameMap);

  final String id;
  final Map<String, String> nameMap;

  /// 根据语言代码获取本地化名称
  String getLocalizedName(String langCode) => _t(nameMap, langCode);
}

/// 图标主题
enum IconTheme {
  /// 插画风格A
  v1('v1', const {'zh': '插画A', 'en': 'Illustration A', 'ar': 'رسم توضيحي أ', 'id': 'Ilustrasi A', 'it': 'Illustrazione A', 'ms': 'Ilustrasi A', 'nl': 'Illustratie A', 'pl': 'Ilustracja A', 'tr': 'İllüstrasyon A', 'vi': 'Minh họa A', 'hi': 'चित्र A', 'da': 'Illustration A', 'fi': 'Piirustus A', 'gu': 'ઇલસ્ટ્રેશન A', 'ca': 'Il·lustració A', 'cs': 'Ilustrace A', 'kn': 'ಚಿತ್ರ A', 'hr': 'Ilustracija A', 'ro': 'Ilustrație A', 'mr': 'चित्र A', 'ml': 'ചിത്രം A', 'bn': 'চিত্র A', 'no': 'Illustrasjon A', 'pa': 'ਚਿਤਰ A', 'sv': 'Illustration A', 'sk': 'Ilustrácia A', 'sl': 'Ilustracija A', 'te': 'చిత్రం A', 'ta': 'வரைபடம் A', 'ur': 'تصویر A', 'uk': 'Ілюстрація A', 'he': 'איור A', 'el': 'Απεικόνιση A', 'hu': 'Illusztráció A', 'or': 'ଚିତ୍ର A', 'ja': 'イラストA', 'ko': '일러스트A', 'fr': 'Illustration A', 'de': 'Illustration A', 'es': 'Ilustración A', 'ru': 'Иллюстрация A', 'pt': 'Ilustração A', 'th': 'ภาพประกอบ A'}),

  /// 插画风格B
  v2('v2', const {'zh': '插画B', 'en': 'Illustration B', 'ar': 'رسم توضيحي ب', 'id': 'Ilustrasi B', 'it': 'Illustrazione B', 'ms': 'Ilustrasi B', 'nl': 'Illustratie B', 'pl': 'Ilustracja B', 'tr': 'İllüstrasyon B', 'vi': 'Minh họa B', 'hi': 'चित्र B', 'da': 'Illustration B', 'fi': 'Piirustus B', 'gu': 'ઇલસ્ટ્રેશન B', 'ca': 'Il·lustració B', 'cs': 'Ilustrace B', 'kn': 'ಚಿತ್ರ B', 'hr': 'Ilustracija B', 'ro': 'Ilustrație B', 'mr': 'चित्र B', 'ml': 'ചിത്രം B', 'bn': 'চিত্র B', 'no': 'Illustrasjon B', 'pa': 'ਚਿਤਰ B', 'sv': 'Illustration B', 'sk': 'Ilustrácia B', 'sl': 'Ilustracija B', 'te': 'చిత్రం B', 'ta': 'வரைபடம் B', 'ur': 'تصویر B', 'uk': 'Ілюстрація B', 'he': 'איור B', 'el': 'Απεικόνιση B', 'hu': 'Illusztráció B', 'or': 'ଚିତ୍ର B', 'ja': 'イラストB', 'ko': '일러스트B', 'fr': 'Illustration B', 'de': 'Illustration B', 'es': 'Ilustración B', 'ru': 'Иллюстрация B', 'pt': 'Ilustração B', 'th': 'ภาพประกอบ B'}),

  /// 写实照片
  v3('v3', const {'zh': '写实', 'en': 'Photo', 'ar': 'صورة', 'id': 'Foto', 'it': 'Foto', 'ms': 'Foto', 'nl': 'Foto', 'pl': 'Zdjęcie', 'tr': 'Fotoğraf', 'vi': 'Ảnh', 'hi': 'फोटो', 'da': 'Foto', 'fi': 'Valokuva', 'gu': 'ફોટો', 'ca': 'Foto', 'cs': 'Foto', 'kn': 'ಫೋಟೋ', 'hr': 'Fotka', 'ro': 'Foto', 'mr': 'फोटो', 'ml': 'ഫോട്ടോ', 'bn': 'ছবি', 'no': 'Foto', 'pa': 'ਫੋਟੋ', 'sv': 'Foto', 'sk': 'Foto', 'sl': 'Foto', 'te': 'ఫోటో', 'ta': 'புகைப்படம்', 'ur': 'تصویر', 'uk': 'Фото', 'he': 'תמונה', 'el': 'Φωτογραφία', 'hu': 'Fénykép', 'or': 'ଫଟୋ', 'ja': '写真', 'ko': '사진', 'fr': 'Photo', 'de': 'Foto', 'es': 'Foto', 'ru': 'Фото', 'pt': 'Foto', 'th': 'ภาพถ่าย'});

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
  single('single', const {'zh': '单个', 'en': 'Single', 'ar': 'فردي', 'id': 'Tunggal', 'it': 'Singolo', 'ms': 'Tunggal', 'nl': 'Enkel', 'pl': 'Pojedynczy', 'tr': 'Tek', 'vi': 'Đơn', 'hi': 'एकल', 'da': 'Enkelt', 'fi': 'Yksittäinen', 'gu': 'એકલ', 'ca': 'Únic', 'cs': 'Jednotlivý', 'kn': 'ಏಕ', 'hr': 'Pojedinačni', 'ro': 'Unic', 'mr': 'एकल', 'ml': 'ഒറ്റ', 'bn': 'একক', 'no': 'Enkelt', 'pa': 'ਇੱਕਲਾ', 'sv': 'Enkel', 'sk': 'Jednotlivý', 'sl': 'Posamezen', 'te': 'ఒక్కటి', 'ta': 'ஒற்றை', 'ur': 'واحد', 'uk': 'Одиничний', 'he': 'יחיד', 'el': 'Μονό', 'hu': 'Egyedi', 'or': 'ଏକକ', 'ja': '単一', 'ko': '단일', 'fr': 'Unique', 'de': 'Einzeln', 'es': 'Único', 'ru': 'Одиночный', 'pt': 'Único', 'th': 'เดี่ยว'}),

  /// 播放组内多个选中声音的循环（多选）
  sequence('sequence', const {'zh': '多选', 'en': 'Multi', 'ar': 'متعدد', 'id': 'Multi', 'it': 'Multi', 'ms': 'Multi', 'nl': 'Multi', 'pl': 'Multi', 'tr': 'Çoklu', 'vi': 'Đa', 'hi': 'मल्टी', 'da': 'Multi', 'fi': 'Moni', 'gu': 'મલ્ટી', 'ca': 'Multi', 'cs': 'Vícenásobný', 'kn': 'ಬಹು', 'hr': 'Višestruki', 'ro': 'Multi', 'mr': 'मल्टी', 'ml': 'മൾട്ടി', 'bn': 'মাল্টी', 'no': 'Multi', 'pa': 'ਮਲਟੀ', 'sv': 'Multi', 'sk': 'Viacnásobný', 'sl': 'Večkratnik', 'te': 'బహుళ', 'ta': 'பல', 'ur': 'ملٹی', 'uk': 'Мульти', 'he': 'מרובה', 'el': 'Πολλαπלό', 'hu': 'Több', 'or': 'ମଲ୍ଟି', 'ja': '複数', 'ko': '다중', 'fr': 'Multi', 'de': 'Multi', 'es': 'Multi', 'ru': 'Мульти', 'pt': 'Multi', 'th': 'หลายรายการ'});

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
      nameMap: const {'zh': '野狗', 'en': 'Wild Dog', 'ar': 'كلب بري', 'id': 'Anjing Liar', 'it': 'Cane selvatico', 'ms': 'Anjing Liar', 'nl': 'Wilde hond', 'pl': 'Dziki pies', 'tr': 'Yabani köpek', 'vi': 'Chó hoang', 'hi': 'जंगली कुत्ता', 'da': 'Vild hund', 'fi': 'Villikoira', 'gu': 'જંગલી કૂતરો', 'ca': 'Gos salvatge', 'cs': 'Divoký pes', 'kn': 'ಕಾಡು ನಾಯಿ', 'hr': 'Divlji pas', 'ro': 'Câine sălbatic', 'mr': 'वाखर कुत्ता', 'ml': 'കാട്ട് നായ', 'bn': 'বুনো কুকুর', 'no': 'Villhund', 'pa': 'ਜੰਗਲੀ ਕੁੱਤਾ', 'sv': 'Vild hund', 'sk': 'Divý pes', 'sl': 'Divja žival', 'te': 'అడవి కుక్క', 'ta': 'காட்டாடு', 'ur': 'جنگلی کتا', 'uk': 'Дика собака', 'he': 'כלב בר', 'el': 'Άγριο σκύλος', 'hu': 'Vadkutya', 'or': 'ବଣ କୁକୁର', 'ja': '野良犬', 'ko': '들개', 'fr': 'Chien sauvage', 'de': 'Wildhund', 'es': 'Perro salvaje', 'ru': 'Дикая собака', 'pt': 'Cão selvagem', 'th': 'หมาป่า'},
      descriptionMap: const {'zh': '常见威胁，群体攻击性强', 'en': 'Common threat, aggressive in packs', 'ar': 'تهديد شائع، عدواني في مجموعات', 'id': 'Ancaman umum, agresif dalam kawanan', 'it': 'Minaccia comune, aggressivo in branco', 'ms': 'Ancaman biasa, agresif dalam kumpulan', 'nl': 'Veelvoorkomende bedreiging, aggressief in kudde', 'pl': 'Powszechne zagrożenie, agresywny w stadzie', 'tr': 'Yaygın tehdit, sürü halinde saldırgan', 'vi': 'Mối đe dọa phổ biến, hung hăng thành bầy', 'hi': 'सामान्य खतरा, समूह में आक्रामक', 'da': 'Almindelig trussel, aggressiv i flok', 'fi': 'Yleinen uhka, aggressiivinen laumassa', 'gu': 'સામાન્ય જોખમ, ટોળામાં આક્રામક', 'ca': 'Amenaça comuna, agressiu en ramat', 'cs': 'Běžné ohrožení, agresivní ve smečce', 'kn': 'ಸಾಮಾನ್ಯ ಬಾಧೆ, ಗುಂಪಿನಲ್ಲಿ ಆಕ್ರಮಣಶೀಲ', 'hr': 'Uobičajena prijetnja, agresivan u jatu', 'ro': 'Amenințare comună, agresiv în haită', 'mr': 'सामान्य धोका, गटात आक्रामक', 'ml': 'സാധാരണ ഭീഷണി, കൂട്ടത്തിൽ ആക്രമണാസക്തം', 'bn': 'সাধারণ হুমকি, পড়ে আক্রমণাত্মক', 'no': 'Vanlig trussel, aggressiv i flokk', 'pa': 'ਆਮ ਖਤਰਾ, ਝੁੰਡ ਵਿੱਚ ਹਮਲਾਵਰ', 'sv': 'Vanligt hot, aggressiv i flock', 'sk': 'Bežné ohrozenie, agresívny v smečke', 'sl': 'Pogosta grožnja, agresiven v jati', 'te': 'సాధారణ ముప్పు, మందలో దౌర్జన్యం', 'ta': 'பொதுவான அச்சுறுத்தல், குழுவில் தாக்குதல்', 'ur': 'عام خطرہ، جھنڑے میں جارحانہ', 'uk': 'Часта загроза, агресивний зграєю', 'he': 'איום נפוץ, אגריסיבי בלהקה', 'el': 'Κοινή απειλή, επιθετικός κατά σμήνη', 'hu': 'Gyakori veszély, falkában agresszív', 'or': 'ସାଧାରଣ ବିପଦ, ଝୁଣ୍ଡରେ ଆକ୍ରମଣାତ୍ମକ', 'ja': '一般的な脅威、群れで攻撃的', 'ko': '흔한 위협, 무리 공격성 강함', 'fr': 'Menace courante, agressif en meute', 'de': 'Häufige Bedrohung, aggressiv im Rudel', 'es': 'Amenaza común, agresivo en manada', 'ru': 'Частая угроза, агрессивны стаями', 'pt': 'Ameaça comum, agressivo em matilha', 'th': 'ภัยคุกคามทั่วไป ดุร้ายเมื่ออยู่เป็นฝูง'},
      counterSoundMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ar': 'عواء الذئب', 'id': 'Auman Serigala', 'it': 'Ululupo di lupo', 'ms': 'Auman Serigala', 'nl': 'Wolf gehuil', 'pl': 'Wilk zawodzi', 'tr': 'Kurt uluması', 'vi': 'Tiếng sói hú', 'hi': 'भेड़िया गर्जना', 'da': 'Ulv hyl', 'fi': 'Suden ulvaus', 'gu': 'ભેંસનો અવાજ', 'ca': 'Udol de llop', 'cs': 'Vlk zavytá', 'kn': 'ತೋಳ ಅರಚು', 'hr': 'Vuk urlik', 'ro': 'Lupul urlă', 'mr': 'लांडगा ओरडणे', 'ml': 'ചെന്നായ ഊളം', 'bn': 'নেকড়ে ডাক', 'no': 'Ulv ulin', 'pa': 'ਗਿੱਲੀਂ ਰੁਲਾਉਣੀ', 'sv': 'Varg yl', 'sk': 'Vlk zavýja', 'sl': 'Volk zavija', 'te': 'తోడేలు గర్జించే', 'ta': 'ஓநாய் குரைப்பு', 'ur': 'بھیڑیا چیغ', 'uk': 'Вовчий виття', 'he': 'זאב נוהק', 'el': 'Λύκος ουρλιάζει', 'hu': 'Farkas üvöltése', 'or': 'ବାଘ ଶବଦ', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'},
      fullDescriptionMap: const {'zh': '野狗具有强烈的领地意识和群体攻击性，在遇到危险时会集体围攻。狼嚎声能够模拟同类间的交流和领域占有信息，从而威慑野狗群，让它们感到恐惧而退却。', 'en': 'Wild dogs have strong territorial awareness and pack aggression. Wolf howls simulate intraspecific communication and territorial possession, effectively intimidating wild dog packs into retreat.', 'ja': '野良犬は強い縄張り意識と群れの攻撃性を持ちます。オオカミの遠吠えは種内コミュニケーションと縄張り情報を模倣し、野良犬の群れを効果的に威嚇して退散させます。', 'ko': '들개는 강한 영역 의식과 무리 공격성을 가집니다. 늑대 울음소리는 종내 소통과 영역 정보를 모방하여 들개 무리를 효과적으로 위협하여 물러나게 합니다.', 'fr': 'Les chiens sauvages ont un fort sens du territoire. Les hurlements de loup simulent la communication intraspécifique et la possession territoriale, intimidant les meutes.', 'de': 'Wildhunde haben ein starkes Revierbewusstsein. Wolfsheulen ahmt innerartliche Kommunikation und Revierbesitz nach und schüchtert Wildhundrudel ein.', 'es': 'Los perros salvajes tienen fuerte conciencia territorial. Los aullidos de lobo simulan comunicación intraespecífica y posesión territorial, intimidando a las manadas.', 'ru': 'Дикие собаки обладают сильным чувством территории. Вой волка имитирует внутривидовую коммуникацию и владение территорией, отпугивая стаи диких собак.', 'pt': 'Cães selvagens têm forte consciência territorial. Os uivos de lobo simulam comunicação intraespecífica e possessão territorial, intimidando as matilhas.', 'th': 'หมาป่ามีความรู้สึกถึงอาณาเขตแรง เสียงหมาป่าหอนจำลองการสื่อสารในฝูงและการครอบครองอาณาเขต ขู่ฝูงหมาป่าได้อย่างมีประสิทธิภาพ'},
      category: AnimalCategory.beast,
      recommendedDb: 80.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.85,
      frequencyRange: '100Hz-8kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '虎啸声', 'en': 'Tiger Roar', 'ja': '虎の咆哮', 'ko': '호랑이 포효', 'fr': 'Rugissement de tigre', 'de': 'Tigerbrüllen', 'es': 'Rugido de tigre', 'ru': 'Рёв тигра', 'pt': 'Rugido de tigre', 'th': 'เสียงเสือคำราม'}, rating: 5, soundGroup: 'tiger', soundCount: 3, volumeWeight: 1.0, frequencyRange: '100Hz-2kHz', estimatedDb: 90),
        RecommendedSound(nameMap: const {'zh': '狮吼声', 'en': 'Lion Roar', 'ar': 'زئير الأسد', 'id': 'Auman Singa', 'it': 'Ruggito di leone', 'ms': 'Auman Singa', 'nl': 'Leeuw gebrul', 'pl': 'Lew ryczy', 'tr': 'Aslan kükrüğü', 'vi': 'Tiếng sư tử gầm', 'hi': 'शेर गर्जना', 'da': 'Løve spektakel', 'fi': 'Leijona karjuu', 'gu': 'સિંહનો થડકાર', 'ca': 'Rugit de lleó', 'cs': 'Lev řve', 'kn': 'ಸಿಂಹ ಗರ್ಜನೆ', 'hr': 'Lav urlik', 'ro': 'Leul rage', 'mr': 'सिंह गार्ज', 'ml': 'സിംഹം ഗർജ്ജിക്കുന്നു', 'bn': 'সিংহ গর্জন', 'no': 'Løve ulin', 'pa': 'ਸ਼ੇਰ ਦਾ ਦਹਾਸ਼ਾ', 'sv': 'Lejon ryta', 'sk': 'Lev revúci', 'sl': 'Lev rije', 'te': 'సింహం గర్జింపు', 'ta': 'சிங்கம் கர்ச்சைல்', 'ur': 'شیر دہاڑ', 'uk': 'Левиний рев', 'he': 'אריה שואג', 'el': 'Λιοντάρι βρυχάται', 'hu': 'Oroszlán üvöltése', 'or': 'ସିଂହ ଗର୍ଜନ', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'}, rating: 4, soundGroup: 'lion', soundCount: 3, volumeWeight: 0.95, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(nameMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ar': 'عواء الذئب', 'id': 'Auman Serigala', 'it': 'Ululupo di lupo', 'ms': 'Auman Serigala', 'nl': 'Wolf gehuil', 'pl': 'Wilk zawodzi', 'tr': 'Kurt uluması', 'vi': 'Tiếng sói hú', 'hi': 'भेड़िया गर्जना', 'da': 'Ulv hyl', 'fi': 'Suden ulvaus', 'gu': 'ભેંસનો અવાજ', 'ca': 'Udol de llop', 'cs': 'Vlk zavytá', 'kn': 'ತೋಳ ಅರಚು', 'hr': 'Vuk urlik', 'ro': 'Lupul urlă', 'mr': 'लांडगा ओरडणे', 'ml': 'ചെന്നായ ഊളം', 'bn': 'নেকড়ে ডাক', 'no': 'Ulv ulin', 'pa': 'ਗਿੱਲੀਂ ਰੁਲਾਉਣੀ', 'sv': 'Varg yl', 'sk': 'Vlk zavýja', 'sl': 'Volk zavija', 'te': 'తోడేలు గర్జించే', 'ta': 'ஓநாய் குரைப்பு', 'ur': 'بھیڑیا چیغ', 'uk': 'Вовчий виття', 'he': 'זאב נוהק', 'el': 'Λύκος ουρλιάζει', 'hu': 'Farkas üvöltése', 'or': 'ବାଘ ଶବଦ', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'}, rating: 3, soundGroup: 'wolf', soundCount: 3, volumeWeight: 0.8, frequencyRange: '150Hz-2kHz', estimatedDb: 85),
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
      nameMap: const {'zh': '野猪', 'en': 'Wild Boar', 'ar': 'خنزير بري', 'id': 'Babi Hutan', 'it': 'Cinghiale', 'ms': 'Babi Hutan', 'nl': 'Wild zwijn', 'pl': 'Dzik', 'tr': 'Yabani domuz', 'vi': 'Lợn rừng', 'hi': 'जंगली सूअर', 'da': 'Vildsvin', 'fi': 'Villisika', 'gu': 'જંગલી ભૂંડ', 'ca': 'Senglar', 'cs': 'Divočák', 'kn': 'ಕಾಡು ಹಂದಿ', 'hr': 'Divlja svinja', 'ro': 'Mistret', 'mr': 'रानडूकर', 'ml': 'കാട്ടാനക്കി', 'bn': 'বুনো শুয়োর', 'no': 'Villsvin', 'pa': 'ਜੰਗਲੀ ਸੂਅਰ', 'sv': 'Vildsvin', 'sk': 'Diviak', 'sl': 'Divja prašič', 'te': 'అడవి పంది', 'ta': 'காட்டுப்பன்றி', 'ur': 'جنگلی سوؤر', 'uk': 'Кабан', 'he': 'חזיר בר', 'el': 'Άγριος γουρούνιος', 'hu': 'Vaddisznó', 'or': 'ବଣ ଘୁଷୁରୀ', 'ja': 'イノシシ', 'ko': '멧돼지', 'fr': 'Sanglier', 'de': 'Wildschwein', 'es': 'Jabalí', 'ru': 'Кабан', 'pt': 'Javali', 'th': 'หมูป่า'},
      descriptionMap: const {'zh': '力量强大，攻击性强', 'en': 'Powerful and aggressive', 'ar': 'قوي وعدواني', 'id': 'Kuat dan agresif', 'it': 'Potente e aggressivo', 'ms': 'Kuat dan agresif', 'nl': 'Krachtig en aggressief', 'pl': 'Potężny i agresywny', 'tr': 'Güçlü ve saldırgan', 'vi': 'Mạnh mẽ và hung hăng', 'hi': 'शक्तिशाली और आก्रामक', 'da': 'Kraftfuld og aggressiv', 'fi': 'Voimakas ja aggressiivinen', 'gu': 'શક્તિશાળી અને આક્રામક', 'ca': 'Potent i agressiu', 'cs': 'Silný a agresivní', 'kn': 'ಶಕ್ತಿಶಾಲಿ ಮತ್ತು ಆಕ್ರಮಣಶೀಲ', 'hr': 'Snažan i agresivan', 'ro': 'Puternic și agresiv', 'mr': 'शक्तिशाली आणि आक्रामक', 'ml': 'ശക്തനും ആക്രമണാസക്തനും', 'bn': 'শক্তিশালী এবং আক্রমণাত্মক', 'no': 'Kraftig og aggressiv', 'pa': 'ਸ਼ਕਤੀਸ਼ਾਲੀ ਅਤੇ ਹਮਲਾਵਰ', 'sv': 'Kraftfull och aggressiv', 'sk': 'Silný a agresívny', 'sl': 'Močan in agresiven', 'te': 'శక్తివంతమైన మరియు దౌర్జన్యం', 'ta': 'வலுவான மற்றும் தாக்குதல்', 'ur': 'طاقتور اور جارحانہ', 'uk': 'Могутній і агресивний', 'he': 'עוצמתי ואגריסיבי', 'el': 'Ισχυρό και επιθετικό', 'hu': 'Erős és agresszív', 'or': 'ଶକ୍ତିଶାଳୀ ଏବଂ ଆକ୍ରମଣାତ୍ମକ', 'ja': '力が強く、攻撃的', 'ko': '힘이 세고 공격적', 'fr': 'Puissant et agressif', 'de': 'Kraftvoll und aggressiv', 'es': 'Potente y agresivo', 'ru': 'Мощный и агрессивный', 'pt': 'Poderoso e agressivo', 'th': 'แข็งแกร่งและดุร้าย'},
      counterSoundMap: const {'zh': '狮子吼叫', 'en': 'Lion Roar', 'ar': 'زئير الأسد', 'id': 'Auman Singa', 'it': 'Ruggito di leone', 'ms': 'Auman Singa', 'nl': 'Leeuw gebrul', 'pl': 'Lew ryczy', 'tr': 'Aslan kükrüğü', 'vi': 'Tiếng sư tử gầm', 'hi': 'शेर गर्जना', 'da': 'Løve spektakel', 'fi': 'Leijona karjuu', 'gu': 'સિંહનો થડકાર', 'ca': 'Rugit de lleó', 'cs': 'Lev řve', 'kn': 'ಸಿಂಹ ಗರ್ಜನೆ', 'hr': 'Lav urlik', 'ro': 'Leul rage', 'mr': 'सिंह गार्ज', 'ml': 'സിംഹം ഗർജ്ജിക്കുന്നു', 'bn': 'সিংহ গর্জন', 'no': 'Løve ulin', 'pa': 'ਸ਼ੇਰ ਦਾ ਦਹਾਸ਼ਾ', 'sv': 'Lejon ryta', 'sk': 'Lev revúci', 'sl': 'Lev rije', 'te': 'సింహం గర్జింపు', 'ta': 'சிங்கம் கர்ச்சைல்', 'ur': 'شیر دہاڑ', 'uk': 'Левиний рев', 'he': 'אריה שואג', 'el': 'Λιοντάρι βρυχάται', 'hu': 'Oroszlán üvöltése', 'or': 'ସିଂହ ଗର୍ଜନ', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'},
      fullDescriptionMap: const {'zh': '野猪体型庞大，力量惊人，遇到威胁时会主动攻击。狮子作为森林之王的吼叫声能够传达强大的威慑力，让野猪感知到潜在威胁而避开。', 'en': 'Wild boars are massive and incredibly strong, actively attacking when threatened. The roar of a lion conveys powerful deterrence, making boars stay away.', 'ja': 'イノシシは体が大きく力が強く、脅威を感じると攻撃してきます。ライオンの咆哮は強力な威嚇力を伝え、イノシシを遠ざけます。', 'ko': '멧돼지는 체구가 크고 힘이 엄청나며, 위협을 받으면 공격합니다. 사자의 포효는 강력한 위협을 전달하여 멧돼지를 쫓아냅니다.', 'fr': 'Les sangliers sont massifs et forts, attaquant activement quand menacés. Le rugissement du lion transmet une forte dissuasion.', 'de': 'Wildschweine sind massiv und stark. Das Brüllen des Löwen vermittelt starke Abschreckung und hält sie auf Abstand.', 'es': 'Los jabalíes son masivos y fuertes. El rugido del león transmite poderosa disuasión, haciéndolos alejarse.', 'ru': 'Кабаны массивны и сильны, атакуют при угрозе. Рык льва передаёт мощное устрашение, заставляя их держаться подальше.', 'pt': 'Javalis são massivos e fortes. O rugido do leão transmite poderosa dissuasão, fazendo-os se afastar.', 'th': 'หมูป่าตัวใหญ่และแข็งแกร่ง เสียงคำรามของสิงโตส่งผลขู่อย่างทรงพลัง ทำให้หมูป่าหนีห่าง'},
      category: AnimalCategory.beast,
      recommendedDb: 90.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.9,
      frequencyRange: '50Hz-5kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狮子吼叫', 'en': 'Lion Roar', 'ar': 'زئير الأسد', 'id': 'Auman Singa', 'it': 'Ruggito di leone', 'ms': 'Auman Singa', 'nl': 'Leeuw gebrul', 'pl': 'Lew ryczy', 'tr': 'Aslan kükrüğü', 'vi': 'Tiếng sư tử gầm', 'hi': 'शेर गर्जना', 'da': 'Løve spektakel', 'fi': 'Leijona karjuu', 'gu': 'સિંહનો થડકાર', 'ca': 'Rugit de lleó', 'cs': 'Lev řve', 'kn': 'ಸಿಂಹ ಗರ್ಜನೆ', 'hr': 'Lav urlik', 'ro': 'Leul rage', 'mr': 'सिंह गार्ज', 'ml': 'സിംഹം ഗർജ്ജിക്കുന്നു', 'bn': 'সিংহ গর্জন', 'no': 'Løve ulin', 'pa': 'ਸ਼ੇਰ ਦਾ ਦਹਾਸ਼ਾ', 'sv': 'Lejon ryta', 'sk': 'Lev revúci', 'sl': 'Lev rije', 'te': 'సింహం గర్జింపు', 'ta': 'சிங்கம் கர்ச்சைல்', 'ur': 'شیر دہاڑ', 'uk': 'Левиний рев', 'he': 'אריה שואג', 'el': 'Λιοντάρι βρυχάται', 'hu': 'Oroszlán üvöltése', 'or': 'ସିଂହ ଗର୍ଜନ', 'ja': 'ライオンの咆哮', 'ko': '사자 포효', 'fr': 'Rugissement de lion', 'de': 'Löwenbrüllen', 'es': 'Rugido de león', 'ru': 'Рёв льва', 'pt': 'Rugido de leão', 'th': 'เสียงสิงโตคำราม'}, rating: 5, soundGroup: 'lion', soundCount: 3, volumeWeight: 1.0, frequencyRange: '80Hz-3kHz', estimatedDb: 92),
        RecommendedSound(nameMap: const {'zh': '低频声波', 'en': 'Low-freq Wave', 'ja': '低周波', 'ko': '저주파', 'fr': 'Onde basse fréquence', 'de': 'Niederfrequenz-Welle', 'es': 'Onda de baja frecuencia', 'ru': 'Низкочастотная волна', 'pt': 'Onda de baixa frequência', 'th': 'คลื่นความถี่ต่ำ'}, rating: 4, soundGroup: 'low_freq', soundCount: 1, volumeWeight: 0.95, frequencyRange: '20Hz-1kHz', estimatedDb: 95),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.85, frequencyRange: '200Hz-6kHz', estimatedDb: 85),
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
      nameMap: const {'zh': '熊', 'en': 'Bear', 'ar': 'دب', 'id': 'Beruang', 'it': 'Orso', 'ms': 'Beruang', 'nl': 'Beer', 'pl': 'Niedźwiedź', 'tr': 'Ayı', 'vi': 'Gấu', 'hi': 'भालू', 'da': 'Bjørn', 'fi': 'Karhu', 'gu': 'રીંછ', 'ca': 'Ós', 'cs': 'Medvěd', 'kn': 'ಕರಡಿ', 'hr': 'Medvjed', 'ro': 'Urs', 'mr': 'अस्वल', 'ml': 'കരടി', 'bn': 'ভল্লুক', 'no': 'Bjørn', 'pa': 'ਰਿੱਛ', 'sv': 'Björn', 'sk': 'Medveď', 'sl': 'Medved', 'te': 'ఎలుగుబంటి', 'ta': 'கரடி', 'ur': 'ریچھ', 'uk': 'Ведмідь', 'he': 'דוב', 'el': 'Αρκούδα', 'hu': 'Medve', 'or': 'ଭାଲୁ', 'ja': '熊', 'ko': '곰', 'fr': 'Ours', 'de': 'Bär', 'es': 'Oso', 'ru': 'Медведь', 'pt': 'Urso', 'th': 'หมี'},
      descriptionMap: const {'zh': '大型猛兽，破坏力强', 'en': 'Large predator, highly destructive', 'ar': 'مفترس كبير، مدمر للغاية', 'id': 'Pemangsa besar, sangat destruktif', 'it': 'Grande predatore, molto distruttivo', 'ms': 'Pemangsa besar, sangat merosakkan', 'nl': 'Groot roofdier, zeer destructief', 'pl': 'Wielki drapieżnik, bardzo destrukcyjny', 'tr': 'Büyük avcı, oldukça yıkıcı', 'vi': 'Kẻ thịt lớn, cực kỳ phá hoại', 'hi': 'बड़ा शिकारी, अत्यधिक विनाशकारी', 'da': 'Stort rovdyr, meget destruktiv', 'fi': 'Suuri petoeläin, erittäin tuhoisa', 'gu': 'મોટો શિકારી, ખૂબ વિનાશકારક', 'ca': 'Gran depredador, molt destructiu', 'cs': 'Velký predátor, velmi destruktivní', 'kn': 'ದೊಡ್ಡ ಪ್ರಾಣಿಬಾಧೆ, ಅತ್ಯಂತ ವಿನಾಶಕಾರಕ', 'hr': 'Velik predator, vrlo destruktivan', 'ro': 'Mare prădător, foarte distructiv', 'mr': 'मोठा शिकारी, अत्यंत विनाशकारक', 'ml': 'വലിയ ഇരപിടിയന്‍, വളരെ നശിപ്പിക്കുന്ന', 'bn': 'বড় শিকারি, অত্যন্ত ধ্বংসাত্মক', 'no': 'Stort rovdyr, svært destruktiv', 'pa': 'ਵੱਡਾ ਸ਼ਿਕਾਰੀ, ਬਹੁਤ ਤਬਾਹ ਕਰਨ ਵਾਲਾ', 'sv': 'Stort rovdjur, mycket destruktiv', 'sk': 'Veľký predátor, veľmi destruktívny', 'sl': 'Velik plen, zelo destruktiven', 'te': 'పెద్ద వెతుకుడు, చాలా విధ్వంసకం', 'ta': 'பெரிய வேட்டையாடு, மிகவும் அழிவு', 'ur': 'بڑا شکاری، انتہائی تباہ کن', 'uk': 'Великий хижак, дуже руйнівний', 'he': 'טורף גדול, הרסני מאוד', 'el': 'Μεγάλος θηρευτής, εξαιρετικά καταστροφικός', 'hu': 'Nagy ragadozó, nagyon pusztító', 'or': 'ବଡ଼ ଶିକାରୀ, ଅତ୍ୟନ୍ତ ବିନାଶକାରକ', 'ja': '大型猛獣、破壊力が強い', 'ko': '대형 맹수, 파괴력 강함', 'fr': 'Grand prédateur, très destructeur', 'de': 'Großes Raubtier, sehr zerstörerisch', 'es': 'Gran depredador, muy destructivo', 'ru': 'Крупный хищник, очень разрушительный', 'pt': 'Grande predador, muito destrutivo', 'th': 'สัตว์นักล่าขนาดใหญ่ ทำลายล้างมาก'},
      counterSoundMap: const {'zh': '枪声模拟', 'en': 'Gunshot Simulation', 'ar': 'محاكاة طلقات نارية', 'id': 'Simulasi tembakan', 'it': 'Simulazione sparo', 'ms': 'Simulasi tembakan', 'nl': 'Schot simulatie', 'pl': 'Symulacja strzału', 'tr': 'Kurşun simülasyonu', 'vi': 'Mô phỏng phát súng', 'hi': 'गोली सिमुलेशन', 'da': 'Skud simulering', 'fi': 'Ampumasimulaatio', 'gu': 'ગોળીની સિમ્યુલેશન', 'ca': 'Simulació de tret', 'cs': 'Simulace střelby', 'kn': 'ಗುಂಡಿನ ಅನುಕರಣ', 'hr': 'Simulacija pucanja', 'ro': 'Simulare foc de armă', 'mr': 'गोलीबारचे अनुकरण', 'ml': 'വെടിയുതിർത്തൽ അനുകരണം', 'bn': 'গুলির অনুকরণ', 'no': 'Skudd simulering', 'pa': 'ਗੋਲੀ ਸਿਮੂਲੇਸ਼ਨ', 'sv': 'Skjut simulering', 'sk': 'Simulácia výstrelu', 'sl': 'Simulacija strela', 'te': 'కాల్పుల అనుకరణ', 'ta': 'சுடுதல் ஒப்புதல்', 'ur': 'گولی کی نقل', 'uk': 'Симуляція пострілу', 'he': 'סימולציה של ירי', 'el': 'Προσομοίωση πυροβολισμού', 'hu': 'Lövés szimuláció', 'or': 'ଗୋଳି ଅନୁକରଣ', 'ja': '銃声シミュレーション', 'ko': '총소리 시뮬레이션', 'fr': 'Simulation de coup de feu', 'de': 'Schusssimulation', 'es': 'Simulación de disparo', 'ru': 'Имитация выстрела', 'pt': 'Simulação de tiro', 'th': 'จำลองเสียงปืน'},
      fullDescriptionMap: const {'zh': '熊是极具攻击性的大型猛兽，遇到人类时可能造成致命伤害。枪声的模拟能够传达人类武器的威胁，让熊意识到潜在危险而远离。', 'en': 'Bears are extremely aggressive large predators that can cause fatal injuries. Gunshot simulation conveys the threat of human weapons, making bears stay away.', 'ja': '熊は非常に攻撃的な大型猛獣であり、人間に致命的な被害を与える可能性があります。銃声のシミュレーションは武器の脅威を伝え、熊を遠ざけます。', 'ko': '곰은 극히 공격적인 대형 맹수로, 치명적인 상해를 입힐 수 있습니다. 총소리 시뮬레이션은 무기의 위협을 전달하여 곰을 쫓아냅니다.', 'fr': 'Les ours sont de grands prédateurs extrêmement agressifs. La simulation de coup de feu transmet la menace des armes humaines et les éloigne.', 'de': 'Bären sind extrem aggressive Großraubtiere. Die Schusssimulation vermittelt die Bedrohung durch Waffen und hält Bären auf Abstand.', 'es': 'Los osos son grandes depredadores extremadamente agresivos. La simulación de disparo transmite la amenaza de armas humanas y los aleja.', 'ru': 'Медведи — крайне агрессивные крупные хищники. Имитация выстрела передаёт угрозу оружия и заставляет их держаться подальше.', 'pt': 'Ursos são grandes predadores extremamente agressivos. A simulação de tiro transmite a ameaça de armas e os afasta.', 'th': 'หมีเป็นสัตว์นักล่าขนาดใหญ่ที่ดุร้ายมาก การจำลองเสียงปืนส่งผลขู่ของอาวุธและทำให้หมีหนีห่าง'},
      category: AnimalCategory.beast,
      recommendedDb: 95.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.95,
      frequencyRange: '50Hz-10kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 5, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 1.0, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
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
      nameMap: const {'zh': '狼', 'en': 'Wolf', 'ar': 'ذئب', 'id': 'Serigala', 'it': 'Lupo', 'ms': 'Serigala', 'nl': 'Wolf', 'pl': 'Wilk', 'tr': 'Kurt', 'vi': 'Sói', 'hi': 'भेड़िया', 'da': 'Ulv', 'fi': 'Susi', 'gu': 'ભેંસ', 'ca': 'Llop', 'cs': 'Vlk', 'kn': 'ತೋಳ', 'hr': 'Vuk', 'ro': 'Lup', 'mr': 'लांडगा', 'ml': 'ചെന്നാয', 'bn': 'নেকড়ে', 'no': 'Ulv', 'pa': 'ਗਿੱਲੀਂ', 'sv': 'Varg', 'sk': 'Vlk', 'sl': 'Volk', 'te': 'తోడేలు', 'ta': 'ஓநாய்', 'ur': 'بھیڑیا', 'uk': 'Вовك', 'he': 'זאב', 'el': 'Λύκος', 'hu': 'Farkas', 'or': 'ବାଘ', 'ja': 'オオカミ', 'ko': '늑대', 'fr': 'Loup', 'de': 'Wolf', 'es': 'Lobo', 'ru': 'Волк', 'pt': 'Lobo', 'th': 'หมาป่า'},
      descriptionMap: const {'zh': '夜间狩猎，群体性强', 'en': 'Nocturnal hunter, strong pack behavior', 'ar': 'صياد ليلي، سلوك قطيعي قوي', 'id': 'Pemangsa nokturnal, perilaku kawanan kuat', 'it': 'Cacciatore notturno, forte comportamento del branco', 'ms': 'Pemangsa nokturnal, tingkahlaku kumpulan kuat', 'nl': 'Nachtelijke jager, sterk kuddegedrag', 'pl': 'Nocny łowca, silne stadne zachowanie', 'tr': 'Gece avcı, güçlü sürü davranışı', 'vi': 'Kẻ săn đêm, bầy đàn mạnh mẽ', 'hi': 'रात्रि शिकारी, मजबूत समूह व्यवहार', 'da': 'Nats jager, stærk flokadfærd', 'fi': 'Yömetseinä, vahva laumakäyttäytyminen', 'gu': 'રાત્રિ શિકારી, મજબૂત ટોળાની વર્તણૂક', 'ca': 'Caçador nocturn, fort comportament de ramat', 'cs': 'Noční lovec, silné stádové chování', 'kn': 'ರಾತ್ರಿ ಬೇಟೆಗಾರ, ಬಲವಾದ ಗುಂಪಿನ ವರ್ತನೆ', 'hr': 'Noćni lovac, jako ponašanje u jatu', 'ro': 'Vânător nocturn, comportament puternic de haită', 'mr': 'रात्र शिकारी, मजबूत गट वर्तणूक', 'ml': 'രാത്രി വേട്ടക്കാരന്‍, ശക്തമായ കൂട്ടായ പെരുമാറ്റം', 'bn': 'রাতারাতি শিকারি, শক্তিশালী পড়ে আচরণ', 'no': 'Nattlig jeger, sterk flokkatferd', 'pa': 'ਰਾਤ ਸ਼ਿਕਾਰੀ, ਮਜ਼ਬੂਤ ਝੁੰਡ ਵਿਵਹਾਰ', 'sv': 'Nattlig jägare, starkt beteende i flock', 'sk': 'Nočný lovec, silné stádové správanie', 'sl': 'Nočni lovec, močno čeden v jati', 'te': 'రాత్రి వేటగాడు, బలమైన మంద ప్రవర్తన', 'ta': 'இரவு வேட்டையாடு, வலுவான குழு நடத்தை', 'ur': 'رات کا شکاری، مضبوط گروہی رویہ', 'uk': 'Нічний мисливець, сильна зграйна поведінка', 'he': 'צייד לילי, התנהגות להקה חזקה', 'el': 'Νυχτιός κυνηγός, ισχυρή σμυνική συμπεριφορά', 'hu': 'Éjjeli vadász, erős falkaviselkedés', 'or': 'ରାତ୍ରି ଶିକାରୀ, ଶକ୍ତିଶାଳୀ ଝୁଣ୍ଡ ଆଚରଣ', 'ja': '夜行性、群れ行動が強い', 'ko': '야행성 사냥꾼, 무리 행동 강함', 'fr': 'Chasseur nocturne, fort comportement de meute', 'de': 'Nächtlicher Jäger, starkes Rudelverhalten', 'es': 'Cazador nocturno, fuerte comportamiento de manada', 'ru': 'Ночной охотник, сильное стайное поведение', 'pt': 'Caçador noturno, forte comportamento de matilha', 'th': 'นักล่ากลางคืน อยู่เป็นฝูง'},
      counterSoundMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ar': 'عواء الذئب', 'id': 'Auman Serigala', 'it': 'Ululupo di lupo', 'ms': 'Auman Serigala', 'nl': 'Wolf gehuil', 'pl': 'Wilk zawodzi', 'tr': 'Kurt uluması', 'vi': 'Tiếng sói hú', 'hi': 'भेड़िया गर्जना', 'da': 'Ulv hyl', 'fi': 'Suden ulvaus', 'gu': 'ભેંસનો અવાજ', 'ca': 'Udol de llop', 'cs': 'Vlk zavytá', 'kn': 'ತೋಳ ಅರಚು', 'hr': 'Vuk urlik', 'ro': 'Lupul urlă', 'mr': 'लांडगा ओरडणे', 'ml': 'ചെന്നായ ഊളം', 'bn': 'নেকড়ে ডাক', 'no': 'Ulv ulin', 'pa': 'ਗਿੱਲੀਂ ਰੁਲਾਉਣੀ', 'sv': 'Varg yl', 'sk': 'Vlk zavýja', 'sl': 'Volk zavija', 'te': 'తోడేలు గర్జించే', 'ta': 'ஓநாய் குரைப்பு', 'ur': 'بھیڑیا چیغ', 'uk': 'Вовчий виття', 'he': 'זאב נוהק', 'el': 'Λύκος ουρλιάζει', 'hu': 'Farkas üvöltése', 'or': 'ବାଘ ଶବଦ', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'},
      fullDescriptionMap: const {'zh': '狼是夜行性动物，具有极强的群体狩猎能力。狼嚎声能够模拟同类间的交流，传达领域占有信息，从而威慑狼群。', 'en': 'Wolves are nocturnal animals with strong pack hunting abilities. Wolf howls simulate intraspecific communication, conveying territorial possession to deter wolf packs.', 'ja': 'オオカミは夜行性で、群れでの狩猟能力が高い動物です。オオカミの遠吠えは種内コミュニケーションを模倣し、縄張り情報を伝えて群れを威嚇します。', 'ko': '늑대는 야행성 동물로 무리 사냥 능력이 뛰어납니다. 늑대 울음소리는 종내 소통을 모방하여 영역 정보를 전달하고 무리를 위협합니다.', 'fr': 'Les loups sont nocturnes avec de fortes capacités de chasse en meute. Les hurlements simulent la communication intraspécifique pour dissuader les meutes.', 'de': 'Wölfe sind nachtaktiv mit starker Rudeljagdfähigkeit. Wolfsheulen ahmen innerartliche Kommunikation nach und schrecken Rudel ab.', 'es': 'Los lobos son nocturnos con fuertes capacidades de caza en manada. Los aullidos simulan comunicación intraespecífica para disuadir a las manadas.', 'ru': 'Волки — ночные животные с сильными стайными способностями. Вой имитирует внутривидовую коммуникацию для отпугивания стай.', 'pt': 'Lobos são noturnos com fortes capacidades de caça em matilha. Os uivos simulam comunicação intraespecífica para dissuadir matilhas.', 'th': 'หมาป่าเป็นสัตว์หากินกลางคืนที่ล่าเป็นฝูงเก่ง เสียงหอนจำลองการสื่อสารในฝูงเพื่อขู่ฝูงหมาป่า'},
      category: AnimalCategory.beast,
      recommendedDb: 85.0,
      effectiveRange: 25.0,
      recommendedVolume: 0.88,
      frequencyRange: '150Hz-5kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狼嚎声', 'en': 'Wolf Howl', 'ar': 'عواء الذئب', 'id': 'Auman Serigala', 'it': 'Ululupo di lupo', 'ms': 'Auman Serigala', 'nl': 'Wolf gehuil', 'pl': 'Wilk zawodzi', 'tr': 'Kurt uluması', 'vi': 'Tiếng sói hú', 'hi': 'भेड़िया गर्जना', 'da': 'Ulv hyl', 'fi': 'Suden ulvaus', 'gu': 'ભેંસનો અવાજ', 'ca': 'Udol de llop', 'cs': 'Vlk zavytá', 'kn': 'ತೋಳ ಅರಚು', 'hr': 'Vuk urlik', 'ro': 'Lupul urlă', 'mr': 'लांडगा ओरडणे', 'ml': 'ചെന്നായ ഊളം', 'bn': 'নেকড়ে ডাক', 'no': 'Ulv ulin', 'pa': 'ਗਿੱਲੀਂ ਰੁਲਾਉਣੀ', 'sv': 'Varg yl', 'sk': 'Vlk zavýja', 'sl': 'Volk zavija', 'te': 'తోడేలు గర్జించే', 'ta': 'ஓநாய் குரைப்பு', 'ur': 'بھیڑیا چیغ', 'uk': 'Вовчий виття', 'he': 'זאב נוהק', 'el': 'Λύκος ουρλιάζει', 'hu': 'Farkas üvöltése', 'or': 'ବାଘ ଶବଦ', 'ja': 'オオカミの遠吠え', 'ko': '늑대 울음소리', 'fr': 'Hurlement de loup', 'de': 'Wolfheulen', 'es': 'Aullido de lobo', 'ru': 'Вой волка', 'pt': 'Uivo de lobo', 'th': 'เสียงหมาป่าหอน'}, rating: 5, soundGroup: 'wolf', soundCount: 3, volumeWeight: 1.0, frequencyRange: '150Hz-2kHz', estimatedDb: 85),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.95, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
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
      nameMap: const {'zh': '狐狸', 'en': 'Fox', 'ar': 'ثعلب', 'id': 'Rubah', 'it': 'Volpe', 'ms': 'Rubah', 'nl': 'Vos', 'pl': 'Lis', 'tr': 'Tilki', 'vi': 'Cáo', 'hi': 'लोमड़ी', 'da': 'Ræv', 'fi': 'Kettu', 'gu': 'શિયાળ', 'ca': 'Guineu', 'cs': 'Liška', 'kn': 'ನರಿ', 'hr': 'Lisica', 'ro': 'Vulpe', 'mr': 'कोल्हा', 'ml': 'കുറുക്കൻ', 'bn': 'শিয়াল', 'no': 'Rev', 'pa': 'ਲੂਮੜ', 'sv': 'Räv', 'sk': 'Líška', 'sl': 'Lisica', 'te': 'నక్క', 'ta': 'குருவி', 'ur': 'لومڑ', 'uk': 'Лисиця', 'he': 'שועל', 'el': 'Αλεπού', 'hu': 'Róka', 'or': 'ଶିଆଳ', 'ja': 'キツネ', 'ko': '여우', 'fr': 'Renard', 'de': 'Fuchs', 'es': 'Zorro', 'ru': 'Лиса', 'pt': 'Raposa', 'th': 'สุนัขจิ้งจอก'},
      descriptionMap: const {'zh': '夜间活动，偷食家禽', 'en': 'Nocturnal, poultry thief', 'ar': 'ليلي، سارق دواجن', 'id': 'Nokturnal, pencuri unggas', 'it': 'Notturno, ladro di pollame', 'ms': 'Nokturnal, pencuri unggas', 'nl': 'Nachtelijk, pluimveedief', 'pl': 'Nocny, kradziaty drobiu', 'tr': 'Gececil, kümes hayvanı hırsızı', 'vi': 'Đêm, ăn trộm gia cầm', 'hi': 'रात्रिचर, मुर्गी चोर', 'da': 'Natlig, fjerkrætyv', 'fi': 'Yöaktiivinen, siipikarjavarkaat', 'gu': 'રાત્રિ, કૂકડા ચોર', 'ca': 'Nocturn, lladre d\'aus', 'cs': 'Noční, lupič drůbeže', 'kn': 'ರಾತ್ರಿ, ಕೋಳಿ ಕಳ್ಳ', 'hr': 'Noćni, kradljivač peradi', 'ro': 'Nocturn, hoț de păsări', 'mr': 'रात्रिचर, कोंबडी चोर', 'ml': 'രാത്രിപ്രവർത്തകന്‍, കോഴി കള്ളന്‍', 'bn': 'রাতারাতি, মুরগি চুরি', 'no': 'Nattaktig, fjærfe-tyv', 'pa': 'ਰਾਤੀ, ਪਸ਼ੂਾਂ ਚੋਰ', 'sv': 'Nattaktiv, fågeltjuv', 'sk': 'Nočný, kradný vtáctva', 'sl': 'Nočni, kurnik tat', 'te': 'రాత్రಿ, కోడి దొంగ', 'ta': 'இரவு, கோழிக் திருடன்', 'ur': 'رات کا، مرغی چور', 'uk': 'Нічний, крадій птиці', 'he': 'לילי, גונב עופות', 'el': 'Νυκτιός, κλέφτης πουλερικών', 'hu': 'Éjjeli, baromfitolvaj', 'or': 'ରାତ୍ରି, କୁକୁଡ଼ା ଚୋର', 'ja': '夜行性、家禽を盗む', 'ko': '야행성, 가금류 도둑', 'fr': 'Nocturne, voleur de volaille', 'de': 'Nachtaktiv, Geflügeldieb', 'es': 'Nocturno, ladrón de aves', 'ru': 'Ночной, вор домашней птицы', 'pt': 'Noturno, ladrão de aves', 'th': 'ออกหากินกลางคืน ขโมยสัตว์ปีก'},
      counterSoundMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'},
      fullDescriptionMap: const {'zh': '狐狸夜间活动，常偷食家禽。狗吠声能够模拟天敌威胁，驱赶狐狸。', 'en': 'Foxes are nocturnal and often steal poultry. Dog barking simulates predator threats, driving foxes away.', 'ja': 'キツネは夜行性で、よく家禽を盗みます。犬の吠え声は天敵の脅威を模倣し、キツネを追い払います。', 'ko': '여우는 야행성으로 가금류를 훔칩니다. 개 짖는 소리는 천적의 위협을 모방하여 여우를 쫓아냅니다.', 'fr': 'Les renards sont nocturnes et volent souvent la volaille. Les aboiements simulent la menace de prédateurs et chassent les renards.', 'de': 'Füchse sind nachtaktiv und stehlen oft Geflügel. Hundebellen simuliert Prädatorenbedrohung und vertreibt Füchse.', 'es': 'Los zorros son nocturnos y roban aves. Los ladridos simulan amenazas de depredadores y ahuyentan a los zorros.', 'ru': 'Лисы ведут ночной образ жизни и воруют птицу. Собачий лай имитирует угрозу хищников и отпугивает лис.', 'pt': 'Raposas são noturnas e roubam aves. Latidos simulam ameaças de predadores e afugentam raposas.', 'th': 'สุนัขจิ้งจอกออกหากินกลางคืนและขโมยสัตว์ปีก เสียงหอนหมาจำลองภัยจากผู้ล่าและไล่สุนัขจิ้งจอก'},
      category: AnimalCategory.beast,
      recommendedDb: 75.0,
      effectiveRange: 20.0,
      recommendedVolume: 0.8,
      frequencyRange: '200Hz-6kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '狗吠声', 'en': 'Dog Bark', 'ja': '犬の吠え声', 'ko': '개 짖는 소리', 'fr': 'Aboiement de chien', 'de': 'Hundebellen', 'es': 'Ladrido de perro', 'ru': 'Собачий лай', 'pt': 'Latido de cão', 'th': 'เสียงหอนหมา'}, rating: 5, soundGroup: 'dog', soundCount: 3, volumeWeight: 1.0, frequencyRange: '300Hz-3kHz', estimatedDb: 80),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
      ],
      iconName: 'pets',
      iconPaths: {
        'v3': 'assets/images/icons/v3/fox.jpg',
      },
    ),

    // ============ 爬行类 ============
    Animal(
      id: 'snake',
      nameMap: const {'zh': '毒蛇', 'en': 'Venomous Snake', 'ar': 'أفعى سامة', 'id': 'Ular Berbisa', 'it': 'Serpente velenoso', 'ms': 'Ular Berbisa', 'nl': 'Gifslang', 'pl': 'Jadowity wąż', 'tr': 'Zehirli yılan', 'vi': 'Rắn độc', 'hi': 'विषैला साँप', 'da': 'Giftig slange', 'fi': 'Myrkkylisko', 'gu': 'ઝેરી સાપ', 'ca': 'Serp verinosa', 'cs': 'Jedovatý had', 'kn': 'ವಿಷಹುಬ್ಬು', 'hr': 'Otrovni zmija', 'ro': 'Șarpe veninos', 'mr': 'विषारी साप', 'ml': 'വിഷപ്പാമ്പ്', 'bn': 'বিষধর সাপ', 'no': 'Giftig slange', 'pa': 'ਜ਼ਹਿਰੀਲਾ ਸੱਪ', 'sv': 'Giftig orm', 'sk': 'Jedovatý had', 'sl': 'Strupena kača', 'te': 'విషపు పాము', 'ta': 'விஷப்பாம்பு', 'ur': 'زہریلا سانپ', 'uk': 'Отруйна змія', 'he': 'נחש ארסי', 'el': 'Ιοβόφιδο', 'hu': 'Mérges kígyó', 'or': 'ବିଷଧର ସାପ', 'ja': '毒蛇', 'ko': '독사', 'fr': 'Serpent venimeux', 'de': 'Giftschlange', 'es': 'Serpiente venenosa', 'ru': 'Ядовитая змея', 'pt': 'Cobra venenosa', 'th': 'งูพิษ'},
      descriptionMap: const {'zh': '夜间活动，毒性危险', 'en': 'Nocturnal, dangerously venomous', 'ar': 'ليلي، سام بشكل خطير', 'id': 'Nokturnal, berbahaya berbisa', 'it': 'Notturno, pericolosamente velenoso', 'ms': 'Nokturnal, berbahaya berbisa', 'nl': 'Nachtelijk, gevaarlijk giftig', 'pl': 'Nocny, niebezpiecznie jadowity', 'tr': 'Gececil, tehlikeli zehirli', 'vi': 'Đêm, nguy hiểm độc địa', 'hi': 'रात्रिचर, खतरनाक विषैला', 'da': 'Natlig, farligt giftig', 'fi': 'Yöaktiivinen, vaarallisesti myrkyllinen', 'gu': 'રાત્રિ, ખતરનાક ઝેરી', 'ca': 'Nocturn, perillósament verinós', 'cs': 'Noční, nebezpečně jedovatý', 'kn': 'ರಾತ್ರಿ, ಅಪಾಯಕಾರಿವಿಷ', 'hr': 'Noćni, opasno otrovan', 'ro': 'Nocturn, periculos de veninos', 'mr': 'रात्रिचर, धोकादायक विषारी', 'ml': 'രാത്രിപ്രവർത്തകന്‍, അപായകരമായി വിഷം', 'bn': 'রাতারাতি, বিপজ্জনক বিষ', 'no': 'Nattaktig, farlig giftig', 'pa': 'ਰਾਤੀ, ਖਤਰਨਾਕ ਜ਼ਹਿਰੀਲਾ', 'sv': 'Nattaktiv, farligt giftig', 'sk': 'Nočný, nebezpečne jedovatý', 'sl': 'Nočni, nevarno strupen', 'te': 'రాత్రి, ప్రమాదకరంగా విషపు', 'ta': 'இரவு, ஆபத்தான விஷம்', 'ur': 'رات کا، خطرناک زہریلا', 'uk': 'Нічний, небезпечно руйнівний', 'he': 'לילי, רעיל בצורה מסוכנת', 'el': 'Νυκτιός, επικίνδυνα ιοβό', 'hu': 'Éjjeli, veszélyesen mérges', 'or': 'ରାତ୍ରି, ବିପଦପୂର୍ଣ୍ଣ ବିଷାଲ', 'ja': '夜行性、猛毒の危険', 'ko': '야행성, 맹독 위험', 'fr': 'Nocturne, dangereusement venimeux', 'de': 'Nachtaktiv, gefährlich giftig', 'es': 'Nocturno, peligrosamente venenoso', 'ru': 'Ночной, опасно ядовитый', 'pt': 'Noturno, perigosamente venenoso', 'th': 'ออกหากินกลางคืน พิษอันตราย'},
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
      nameMap: const {'zh': '猴子', 'en': 'Monkey', 'ar': 'قرد', 'id': 'Monyet', 'it': 'Scimmia', 'ms': 'Monyet', 'nl': 'Aap', 'pl': 'Małpa', 'tr': 'Maymun', 'vi': 'Khỉ', 'hi': 'बंदर', 'da': 'Abekat', 'fi': 'Apina', 'gu': 'વાંદરો', 'ca': 'Mico', 'cs': 'Opice', 'kn': 'ಕೋಪಿ', 'hr': 'Majmun', 'ro': 'Maimuță', 'mr': 'माकड', 'ml': 'കുരങ്ങ്', 'bn': 'বাঁদর', 'no': 'Ape', 'pa': 'ਬੰਦਰ', 'sv': 'Apa', 'sk': 'Opica', 'sl': 'Opica', 'te': 'కోతి', 'ta': 'குரங்கு', 'ur': 'بندر', 'uk': 'Макака', 'he': 'קוף', 'el': 'Πίθηκος', 'hu': 'Majom', 'or': 'ମାକୁଡ଼', 'ja': '猿', 'ko': '원숭이', 'fr': 'Singe', 'de': 'Affe', 'es': 'Mono', 'ru': 'Обезьяна', 'pt': 'Macaco', 'th': 'ลิง'},
      descriptionMap: const {'zh': '群体骚扰，抢夺物品', 'en': 'Pack harassment, snatching items', 'ar': 'مضايقات جماعية، انتزاع الأشياء', 'id': 'Pelecehan kawanan, mencuri barang', 'it': 'Molestie in branco, rubare oggetti', 'ms': 'Pergaulan kumpulan, mencuri barang', 'nl': 'Kudde-last, stelen van voorwerpen', 'pl': 'Stadne nękanie, kradzieży przedmiotów', 'tr': 'Sürü tacizi, eşya çalma', 'vi': 'Quấy rối đàn, lấy cắp đồ vật', 'hi': 'समूह उत्पीड़न, वस्तुएं चुराना', 'da': 'Flok chikane, tyveri af genstande', 'fi': 'Laumohäirintä, esineiden varastaminen', 'gu': 'ગુંપ ત્રાસ, વસ્તુઓ ચોરવું', 'ca': 'Assetjament de ramat, robatori d\'objectes', 'cs': 'Škodění ve smečce, krádeže předmětů', 'kn': 'ಗುಂಪು ಕಾಟ, ವಸ್ತುಗಳನ್ನು ಕದಿಯುವುದು', 'hr': 'Jato uznemiravanje, kradljivanje predmeta', 'ro': 'Hărțuire de haită, furturi de obiecte', 'mr': 'गट छळ, वसूल माल', 'ml': 'കൂട്ടം പ്രകോപനം, വസ്തുക്കൾ മോഷ്ടിക്കൽ', 'bn': 'পড়ে হয়রানি, জিনিস চুরি', 'no': 'Flokkforfølging, tyveri av gjenstanders', 'pa': 'ਝੁੰਡ ਪਰੇਸ਼ਾਨੀ, ਸਮਾਨ ਚੋਰੀ', 'sv': 'Flocktrakasseri, stöld av föremål', 'sk': 'Obťažovanie v smečke, krádeže predmetov', 'sl': 'Nadlegovanje v jati, kraja predmetov', 'te': 'మంద వేధింపులు, వస్తువులను దొంగించడం', 'ta': 'குழு தொந்தரவு, பொருட்களை திருடுதல்', 'ur': 'گروہی تنگی، سامان چوری', 'uk': 'Образа зграї, крадіжка речей', 'he': 'הטרדת להקה, גניבת חפצים', 'el': 'Παρενόχληση σμήνης, κλοπή αντικειμένων', 'hu': 'Falkavisztesés, tárgyak ellopása', 'or': 'ଝୁଣ୍ଡ ଉତ୍ପୀଡ଼ା, ବସ୍ତୁ ଚୋରାଇବା', 'ja': '群れで嫌がらせ、物を奪う', 'ko': '무리 괴롭힘, 물건 약탈', 'fr': 'Harcèlement en groupe, vol d\'objets', 'de': 'Rudelbelästigung, Diebstahl', 'es': 'Acoso en manada, robo de objetos', 'ru': 'Стайное домогательство, хищение вещей', 'pt': 'Assédio em bando, roubo de itens', 'th': 'รบกวนเป็นฝูง ขโมยของ'},
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
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 3, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.7, frequencyRange: '2kHz-10kHz', estimatedDb: 75),
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
      nameMap: const {'zh': '老鼠', 'en': 'Mouse', 'ar': 'فأر', 'id': 'Tikus', 'it': 'Topo', 'ms': 'Tikus', 'nl': 'Muis', 'pl': 'Mysz', 'tr': 'Fare', 'vi': 'Chuột', 'hi': 'चूहा', 'da': 'Mus', 'fi': 'Hiiri', 'gu': 'ઉંદર', 'ca': 'Ratolí', 'cs': 'Myš', 'kn': 'ಇಲಿ', 'hr': 'Miš', 'ro': 'Șobolan', 'mr': 'उंदीर', 'ml': 'ചുണ്ടെല്ലി', 'bn': 'ইঁদুর', 'no': 'Mus', 'pa': 'ਚੂਹਾ', 'sv': 'Mus', 'sk': 'Myš', 'sl': 'Miš', 'te': 'ఎలుక', 'ta': 'எலி', 'ur': 'چوہا', 'uk': 'Миша', 'he': 'עכבר', 'el': 'Ποντίκι', 'hu': 'Egér', 'or': 'ଚୂହା', 'ja': 'ネズミ', 'ko': '쥐', 'fr': 'Souris', 'de': 'Maus', 'es': 'Ratón', 'ru': 'Мышь', 'pt': 'Rato', 'th': 'หนู'},
      descriptionMap: const {'zh': '夜间活动，传播疾病', 'en': 'Nocturnal, disease carrier', 'ar': 'ليلي، ناقل للأمراض', 'id': 'Nokturnal, pembawa penyakit', 'it': 'Notturno, portatore di malattie', 'ms': 'Nokturnal, pembawa penyakit', 'nl': 'Nachtelijk, ziekteverspreider', 'pl': 'Nocny, roznosiciel chorób', 'tr': 'Gececil, hastalık taşıyıcı', 'vi': 'Đêm, truyền bệnh', 'hi': 'रात्रिचर, रोग वाहक', 'da': 'Natlig, sygdomsbærer', 'fi': 'Yöaktiivinen, taudinkantaja', 'gu': 'રાત્રિ, રોગ વાહક', 'ca': 'Nocturn, portador de malalties', 'cs': 'Noční, přenosce nemocí', 'kn': 'ರಾತ್ರಿ, ರೋಗ ವಾಹಕ', 'hr': 'Noćni, prenositelj bolesti', 'ro': 'Nocturn, purtător de boli', 'mr': 'रात्रिचर, रोग वाहक', 'ml': 'രാത്രിപ്രവർത്തകന്‍, രോഗം വഹിക്കുന്ന', 'bn': 'রাতারাতি, রোগবাহক', 'no': 'Nattaktig, sykdomsbærer', 'pa': 'ਰਾਤੀ, ਰੋਗ ਵਾਹਕ', 'sv': 'Nattaktiv, sjukdomsbärare', 'sk': 'Nočný, prenášač chorôb', 'sl': 'Nočni, prenašalec bolezni', 'te': 'రాత్రి, వ్యాధి వాహకుడు', 'ta': 'இரவு, நோய் காலன்', 'ur': 'رات کا، بیماری بنانے والا', 'uk': 'Нічний, переносник хвороб', 'he': 'לילי, נושא מחלות', 'el': 'Νυκτιός, φορέας ασθενειών', 'hu': 'Éjjeli, betegségterjesztő', 'or': 'ରାତ୍ରି, ରୋଗ ବାହକ', 'ja': '夜行性、病気を媒介', 'ko': '야행성, 질병 매개', 'fr': 'Nocturne, porteur de maladies', 'de': 'Nachtaktiv, Krankheitsüberträger', 'es': 'Nocturno, transmisor de enfermedades', 'ru': 'Ночной, переносчик болезней', 'pt': 'Noturno, transmissor de doenças', 'th': 'ออกหากินกลางคืน พาหะนำโรค'},
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
      nameMap: const {'zh': '野兔', 'en': 'Wild Rabbit', 'ar': 'أرنب بري', 'id': 'Kelinci Liar', 'it': 'Coniglio selvatico', 'ms': 'Arnab Liar', 'nl': 'Wild konijn', 'pl': 'Dziki królik', 'tr': 'Yabani tavşan', 'vi': 'Thỏ hoang', 'hi': 'जंगली खरगोश', 'da': 'Vild kanin', 'fi': 'Villijänö', 'gu': 'જંગલી સસલું', 'ca': 'Conill salvatge', 'cs': 'Divoký králík', 'kn': 'ಕಾಡು ಮೊಲ', 'hr': 'Divlji zec', 'ro': 'Iepure sălbatic', 'mr': 'वाखर ससा', 'ml': 'കാട്ടുമുയൽ', 'bn': 'বুনো খরগোশ', 'no': 'Villkanin', 'pa': 'ਜੰਗਲੀ ਖਰਗੋਸ਼', 'sv': 'Vildkanin', 'sk': 'Divoký králik', 'sl': 'Divja zajec', 'te': 'అడవి కుందేలు', 'ta': 'காட்டு முயல்', 'ur': 'جنگلی خرگوش', 'uk': 'Дикий кролик', 'he': 'ארנב בר', 'el': 'Άγριο κουνέλι', 'hu': 'Vadnyúl', 'or': 'ବଣ ଠେକୁଆ', 'ja': '野ウサギ', 'ko': '토끼', 'fr': 'Lapin sauvage', 'de': 'Wildkaninchen', 'es': 'Conejo silvestre', 'ru': 'Дикий кролик', 'pt': 'Coelho selvagem', 'th': 'กระต่ายป่า'},
      descriptionMap: const {'zh': '农田害兽，繁殖快', 'en': 'Farm pest, rapid reproduction', 'ar': 'آفة زراعية، تكاثر سريع', 'id': 'Hama pertanian, reproduksi cepat', 'it': 'Parassita agricolo, riproduzione rapida', 'ms': 'Perosak pertanian, pembiakan pantas', 'nl': 'Boerderijplaag, snelle reproductie', 'pl': 'Szkodnik rolny, szybka reprodukcja', 'tr': 'Tarım zararlısı, hızlı üreme', 'vi': 'Sâu hoại nông nghiệp, sinh sản nhanh', 'hi': 'खेती की तकलीफ, तेज प्रजनन', 'da': 'Landbrugskadedyr, hurtig formering', 'fi': 'Maataloustuholainen, nopea lisääntyminen', 'gu': 'ખેતી જંતુ, ઝડપી પ્રજનન', 'ca': 'Plaga agrícola, reproducció ràpida', 'cs': 'Zemědělský škůdce, rychlá reprodukce', 'kn': 'ಕೃಷಿ ಹಾನಿ, ವೇಗವಾಗಿ ಪ್ರಜನನ', 'hr': 'Poljoprivredna štetočina, brza reprodukcija', 'ro': 'Daunător agricol, reproducere rapidă', 'mr': 'शेती नुकसान, जलद प्रजनन', 'ml': 'കാര്ഷിക കീട, വേഗത്തിൽ പ്രജനനം', 'bn': 'কৃষি ক্ষতি, দ্রুত প্রজনন', 'no': 'Landbrugsskadelig, hurtig formering', 'pa': 'ਖੇਤੀ ਨੁਕਸਾਨ, ਤੇਜ਼ ਪ੍ਰਜਨਨ', 'sv': 'Jordbruksskadedjur, snabb fortplantning', 'sk': 'Poľnohospodársky škúdec, rýchla reprodukcia', 'sl': 'Kmetijski škodljivec, hitra razmnoževanje', 'te': 'వ్యవసాయ పెరుగుదల, వేగవంతమైన ప్రజనన', 'ta': 'விவசாய பூச்சி, வேகமான இனப்பெருக்கம்', 'ur': 'زرعی نقصان، تیزی سے تولید', 'uk': 'Сільськогосподарський шкідник, швидке розмноження', 'he': 'מזיק חקלאי, רבייה מהירה', 'el': 'Αγροτικός παράσιτος, ταχεία αναπαραγωγή', 'hu': 'Mezőgazdasági kártevő, gyors szaporodás', 'or': 'କୃଷି କୀଟ, ଦ୍ରୁତ ପ୍ରଜନନ', 'ja': '農業害獣、繁殖が早い', 'ko': '농업 해수, 번식이 빠름', 'fr': 'Nuisible agricole, reproduction rapide', 'de': 'Agrarschädling, schnelle Vermehrung', 'es': 'Plaga agrícola, reproducción rápida', 'ru': 'Сельскохозяйственный вредитель, быстрое размножение', 'pt': 'Praga agrícola, reprodução rápida', 'th': 'ศัตรูพืชไร่นา ขยายพันธุ์เร็ว'},
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
      nameMap: const {'zh': '毒蜘蛛', 'en': 'Venomous Spider', 'ar': 'عنكبوت سام', 'id': 'Laba-laba Berbisa', 'it': 'Ragno velenoso', 'ms': 'Labah-labah Berbisa', 'nl': 'Gifspin', 'pl': 'Jadowity pająk', 'tr': 'Zehirli örümcek', 'vi': 'Nhện độc', 'hi': 'विषैला मकड़ी', 'da': 'Giftig edderkop', 'fi': 'Myrkkylukko', 'gu': 'ઝેરી કારોળિયો', 'ca': 'Aranya verinosa', 'cs': 'Jedovatý pavouk', 'kn': 'ವಿಷಜೇವಾಜ್', 'hr': 'Otrovni pauk', 'ro': 'Păianjen veninos', 'mr': 'विषारी कोळी', 'ml': 'വിഷച്ചില്ല്', 'bn': 'বিষধর মাকশা', 'no': 'Giftig edderkop', 'pa': 'ਜ਼ਹਿਰੀਲੀ ਮੱਕੜੀ', 'sv': 'Giftig spindel', 'sk': 'Jedovatý pavúk', 'sl': 'Strupeni pajek', 'te': 'విషపు సాలీడు', 'ta': 'விஷச் சிலந்தி', 'ur': 'زہریلا مکڑی', 'uk': 'Отруйний павук', 'he': 'עכביש ארסי', 'el': 'Ιοβόαραχνος', 'hu': 'Mérges pók', 'or': 'ବିଷଧର ମାକଡ଼ା', 'ja': '毒蜘蛛', 'ko': '독거미', 'fr': 'Araignée venimeuse', 'de': 'Giftspinne', 'es': 'Araña venenosa', 'ru': 'Ядовитый паук', 'pt': 'Aranha venenosa', 'th': 'แมงมุมพิษ'},
      descriptionMap: const {'zh': '夜间活动，毒性危险', 'en': 'Nocturnal, dangerously venomous', 'ar': 'ليلي، سام بشكل خطير', 'id': 'Nokturnal, berbahaya berbisa', 'it': 'Notturno, pericolosamente velenoso', 'ms': 'Nokturnal, berbahaya berbisa', 'nl': 'Nachtelijk, gevaarlijk giftig', 'pl': 'Nocny, niebezpiecznie jadowity', 'tr': 'Gececil, tehlikeli zehirli', 'vi': 'Đêm, nguy hiểm độc địa', 'hi': 'रात्रिचर, खतरनाक विषैला', 'da': 'Natlig, farligt giftig', 'fi': 'Yöaktiivinen, vaarallisesti myrkyllinen', 'gu': 'રાત્રિ, ખતરનાક ઝેરી', 'ca': 'Nocturn, perillósament verinós', 'cs': 'Noční, nebezpečně jedovatý', 'kn': 'ರಾತ್ರಿ, ಅಪಾಯಕಾರಿವಿಷ', 'hr': 'Noćni, opasno otrovan', 'ro': 'Nocturn, periculos de veninos', 'mr': 'रात्रिचर, धोकादायक विषारी', 'ml': 'രാത്രിപ്രവർത്തകന്‍, അപായകരമായി വിഷം', 'bn': 'রাতারাতি, বিপজ্জনক বিষ', 'no': 'Nattaktig, farlig giftig', 'pa': 'ਰਾਤੀ, ਖਤਰਨਾਕ ਜ਼ਹਿਰੀਲਾ', 'sv': 'Nattaktiv, farligt giftig', 'sk': 'Nočný, nebezpečne jedovatý', 'sl': 'Nočni, nevarno strupen', 'te': 'రాత్రి, ప్రమాదకరంగా విషపు', 'ta': 'இரவு, ஆபத்தான விஷம்', 'ur': 'رات کا، خطرناک زہریلا', 'uk': 'Нічний, небезпечно руйнівний', 'he': 'לילי, רעיל בצורה מסוכנת', 'el': 'Νυκτιός, επικίνδυνα ιοβό', 'hu': 'Éjjeli, veszélyesen mérges', 'or': 'ରାତ୍ରି, ବିପଦପୂର୍ଣ୍ଣ ବିଷାଲ', 'ja': '夜行性、猛毒の危険', 'ko': '야행성, 맹독 위험', 'fr': 'Nocturne, dangereusement venimeux', 'de': 'Nachtaktiv, gefährlich giftig', 'es': 'Nocturno, peligrosamente venenoso', 'ru': 'Ночной, опасно ядовитый', 'pt': 'Noturno, perigosamente venenoso', 'th': 'ออกหากินกลางคืน พิษอันตราย'},
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
      nameMap: const {'zh': '马蜂', 'en': 'Wasp', 'ar': 'دبور', 'id': 'Tawon', 'it': 'Vespa', 'ms': 'Tebuan', 'nl': 'Wesp', 'pl': 'Osa', 'tr': 'Eşek arısı', 'vi': 'Ong bắp cày', 'hi': 'ततैया', 'da': 'Hvepse', 'fi': 'Ampiainen', 'gu': 'ભમરો', 'ca': 'Vespa', 'cs': 'Vosa', 'kn': 'ಸುತ್ತಿಗೆ', 'hr': 'Osa', 'ro': 'Viespe', 'mr': 'तत्तीर', 'ml': 'കടന്നം', 'bn': 'ভোলতা', 'no': 'Veps', 'pa': 'ਭੌਂਡ', 'sv': 'Geting', 'sk': 'Osa', 'sl': 'Osa', 'te': 'తుమ్మెట', 'ta': 'குடமுள்ளி', 'ur': 'بور مکھی', 'uk': 'Оса', 'he': 'צרעה', 'el': 'Σφήκα', 'hu': 'Darazsak', 'or': 'ଭୋମ୍ବା', 'ja': 'スズメバチ', 'ko': '말벌', 'fr': 'Guêpe', 'de': 'Wespe', 'es': 'Avispa', 'ru': 'Оса', 'pt': 'Vespa', 'th': 'ต่อ'},
      descriptionMap: const {'zh': '群体攻击，毒性较强', 'en': 'Swarm attacks, highly venomous', 'ar': 'هجمات سربية، شديدة السمومة', 'id': 'Serangan kawanan, sangat berbisa', 'it': 'Attacchi in sciame, altamente velenoso', 'ms': 'Serangan kumpulan, sangat berbisa', 'nl': 'Zwerm aanvallen, zeer giftig', 'pl': 'Ataki rojne, silnie jadowite', 'tr': 'Sürü saldırıları, oldukça zehirli', 'vi': 'Tấn công đàn, cực kỳ độc địa', 'hi': 'झुंड हमले, अत्यधिक विषैला', 'da': 'Flokangreb, meget giftig', 'fi': 'Hyökkäyksen parvet, erittäin myrkyllinen', 'gu': 'ટોળાના હુમલા, ખૂબ ઝેરી', 'ca': 'Atacs d\'eixambra, molt verinosos', 'cs': 'Útok rojů, velmi jedovatý', 'kn': 'ಗುಂಪು ದಾಳಿ, ಅತ್ಯಂತ ವಿಷಕಾರಕ', 'hr': 'Jato napadi, vrlo otrovni', 'ro': 'Atac de ceată, foarte veninos', 'mr': 'गट हल्ले, अत्यंत विषारी', 'ml': 'കൂട്ടം ആക്രമണങ്ങൾ, വളരെ വിഷം', 'bn': 'পড়ে আক্রমণ, অত্যন্ত বিষ', 'no': 'Flokkangrep, svært giftig', 'pa': 'ਝੁੰਡ ਹਮਲੇ, ਬਹੁਤ ਜ਼ਹਿਰੀਲੇ', 'sv': 'Flickangrepp, mycket giftig', 'sk': 'Útok rojov, veľmi jedovatý', 'sl': 'Jato napadi, zelo strupeni', 'te': 'మంద దాళ్లు, చాలా విషపు', 'ta': 'குழு தாக்குதல், மிகவும் விஷம்', 'ur': 'گروہی حملے، انتہائی زہریلے', 'uk': 'Зграєні атаки, дуже отруйний', 'he': 'תקיפת להקה, מאוד רעיל', 'el': 'Επίθεση σμήνης, εξαιρετικά ιοβό', 'hu': 'Falkatámadás, nagyon mérges', 'or': 'ଝୁଣ୍ଡ ଆକ୍ରମଣ, ଅତ୍ୟନ୍ତ ବିଷାଲ', 'ja': '群れで攻撃、毒性が強い', 'ko': '무리 공격, 독성이 강함', 'fr': 'Attaques en essaim, très venimeux', 'de': 'Schwarmangriffe, sehr giftig', 'es': 'Ataques en enjambre, muy venenosos', 'ru': 'Атаки роями, очень ядовиты', 'pt': 'Ataques em enxame, muito venenosos', 'th': 'โจมตีเป็นฝูง พิษรุนแรง'},
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
      nameMap: const {'zh': '乌鸦', 'en': 'Crow', 'ar': 'غراب', 'id': 'Gagak', 'it': 'Corvo', 'ms': 'Gagak', 'nl': 'Kraai', 'pl': 'Kruk', 'tr': 'Karga', 'vi': 'Quạ', 'hi': 'कौआ', 'da': 'Krage', 'fi': 'Varis', 'gu': 'કાગડો', 'ca': 'Corb', 'cs': 'Vran', 'kn': 'ಕಾಗೆ', 'hr': 'Vrana', 'ro': 'Cioară', 'mr': 'कावळा', 'ml': 'കാക്ക', 'bn': 'কাক', 'no': 'Kråke', 'pa': 'ਕਾਂ', 'sv': 'Kråka', 'sk': 'Vrana', 'sl': 'Vrana', 'te': 'కాకి', 'ta': 'காகம்', 'ur': 'کاوا', 'uk': 'Ворона', 'he': 'עורב', 'el': 'Κόρακας', 'hu': 'Varjú', 'or': 'କାକ', 'ja': 'カラス', 'ko': '까마귀', 'fr': 'Corbeau', 'de': 'Krähe', 'es': 'Cuervo', 'ru': 'Ворона', 'pt': 'Corvo', 'th': 'อีกา'},
      descriptionMap: const {'zh': '群体性强，破坏庄稼', 'en': 'Strong flocking, crop destroyer', 'ar': 'قطيع قوي، مدمر المحاصيل', 'id': 'Kawanan kuat, penghancur tanaman', 'it': 'Branco forte, distruttore di raccolti', 'ms': 'Kumpulan kuat, pemusnah tanaman', 'nl': 'Sterke kudde, gewasvernietiger', 'pl': 'Silne stadniszczeńcze upraw', 'tr': 'Güçlü sürü, mahsul yıkımcısı', 'vi': 'Bầy đàn mạnh, phá hoại mùa màng', 'hi': 'मजबूत झुंड, फसल विनाशक', 'da': 'Stærk flok, afgrødeødelægger', 'fi': 'Vahva lauma, satovahingoittaja', 'gu': 'મજબૂત ટોળો, પાક નાશક', 'ca': 'Ramat fort, destrossador de collites', 'cs': 'Silné stádni, ničitel plodin', 'kn': 'ಬಲವಾದ ಗುಂಪು, ಬೆಳೆ ನಾಶಕ', 'hr': 'Jato, uništavač usjeva', 'ro': 'Haită puternică, distrugerea culturilor', 'mr': 'मजबूत गट, पीक नाशक', 'ml': 'ശക്തമായ കൂട്ടം, വിള നശിപ്പിക്കുന്ന', 'bn': 'শক্তিশালী পড়ে, ফসল ধ্বংসকারী', 'no': 'Sterk flokk, avggryødyr', 'pa': 'ਮਜ਼ਬੂਤ ਝੁੰਡ, ਫਸਲ ਤਬਾਹ ਕਰਨ ਵਾਲਾ', 'sv': 'Stor flock, gröödjur', 'sk': 'Silné stádo, ničiteľ plodín', 'sl': 'Močno jato, uničevalec pridelkov', 'te': 'బలమైన మంద, పంట నాశకం', 'ta': 'வலுவான குழு, பயிர் அழிவு', 'ur': 'مضبوط گروہ، فصل تباہ کن', 'uk': 'Сильна зграя, руйнівник врожаю', 'he': 'לְהָקָה חֲזָקָה, משחית יבול', 'el': 'Ισχυρό σμήνος, καταστροφέας σοδειάς', 'hu': 'Erős falka, termés pusztító', 'or': 'ଶକ୍ତିଶାଳୀ ଝୁଣ୍ଡ, ଫସଲ ନାଶକ', 'ja': '群れ行動が強い、農作物を荒らす', 'ko': '무리 행동 강함, 농작물 파괴', 'fr': 'Fort comportement grégaire, destructeur de cultures', 'de': 'Starkes Schwarmverhalten, Erntevernichter', 'es': 'Fuerte comportamiento de bandada, destructor de cultivos', 'ru': 'Сильная стайность, уничтожитель посевов', 'pt': 'Forte comportamento de bando, destruidor de plantações', 'th': 'อยู่เป็นฝูง ทำลายพืชผล'},
      counterSoundMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'},
      fullDescriptionMap: const {'zh': '乌鸦群体性强，常破坏庄稼和果实。鹰啸声能够模拟天敌威胁，驱散乌鸦群。', 'en': 'Crows have strong flocking behavior and often destroy crops and fruits. Eagle screeches simulate predator threats, dispersing crow flocks.', 'ja': 'カラスは群れ行動が強く、農作物や果実を荒らします。鷹の鳴き声は天敵の脅威を模倣し、カラスの群れを散らします。', 'ko': '까마귀는 무리 행동이 강해 농작물과 과일을 파괴합니다. 독수리 울음소리는 천적의 위협을 모방하여 까마귀 무리를 흩어지게 합니다.', 'fr': 'Les corbeaux ont un fort comportement grégaire et détruisent souvent les cultures. Les cris d\'aigle simulent la menace de prédateurs et dispersent les volées.', 'de': 'Krähen haben starkes Schwarmverhalten und zerstören oft Ernten. Adlerschreie simulieren Prädatorenbedrohung und zerstreuen Krähenschwärme.', 'es': 'Los cuervos tienen fuerte comportamiento de bandada y destruyen cultivos. Los chillidos de águila simulan amenazas de depredadores y dispersan las bandadas.', 'ru': 'Вороны обладают сильной стайностью и часто уничтожают посевы. Крики орла имитируют угрозу хищников и разгоняют стаи ворон.', 'pt': 'Corvos têm forte comportamento de bando e destroem plantações. Gritos de águia simulam ameaças de predadores e dispersam bandos.', 'th': 'อีกาอยู่เป็นฝูงและมักทำลายพืชผล เสียงนกอินทรีจำลองภัยจากผู้ล่าและไล่ฝูงอีกาให้กระจัดกระจาย'},
      category: AnimalCategory.bird,
      recommendedDb: 75.0,
      effectiveRange: 30.0,
      recommendedVolume: 0.78,
      frequencyRange: '500Hz-8kHz',
      sounds: [
        RecommendedSound(nameMap: const {'zh': '鹰啸声', 'en': 'Eagle Screech', 'ja': '鷹の鳴き声', 'ko': '독수리 울음소리', 'fr': 'Cri d\'aigle', 'de': 'Adlerschrei', 'es': 'Chillido de águila', 'ru': 'Крик орла', 'pt': 'Grito de águia', 'th': 'เสียงนกอินทรี'}, rating: 5, soundGroup: 'eagle', soundCount: 3, volumeWeight: 1.0, frequencyRange: '1kHz-8kHz', estimatedDb: 78),
        RecommendedSound(nameMap: const {'zh': '枪声', 'en': 'Gunshot', 'ar': 'طلقة نارية', 'id': 'Tembakan', 'it': 'Sparo', 'ms': 'Tembakan', 'nl': 'Schot', 'pl': 'Strzał', 'tr': 'Kurşun', 'vi': 'Phát súng', 'hi': 'गोली', 'da': 'Skud', 'fi': 'Laukaus', 'gu': 'ગોળી', 'ca': 'Tret', 'cs': 'Střela', 'kn': 'ಗುಂಡು', 'hr': 'Pucanj', 'ro': 'Foc de armă', 'mr': 'गोली', 'ml': 'വെടി', 'bn': 'গুলি', 'no': 'Skudd', 'pa': 'ਗੋਲੀ', 'sv': 'Skott', 'sk': 'Výstrel', 'sl': 'Strel', 'te': 'కాల్పు', 'ta': 'சுடுதல்', 'ur': 'گولی', 'uk': 'Стрілба', 'he': 'ירי', 'el': 'Πυροβολισμός', 'hu': 'Lövés', 'or': 'ଗୋଳି', 'ja': '銃声', 'ko': '총소리', 'fr': 'Coup de feu', 'de': 'Schuss', 'es': 'Disparo', 'ru': 'Выстрел', 'pt': 'Tiro', 'th': 'เสียงปืน'}, rating: 4, soundGroup: 'gunshot', soundCount: 3, volumeWeight: 0.9, frequencyRange: '500Hz-12kHz', estimatedDb: 100),
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

  /// 免费可用的动物 ID 列表（其余动物需要 Pro 解锁）
  static const freeAnimalIds = {'wild_dog', 'mouse'};

  /// 免费动物可免费播放的声音组列表（其余声音组需要 Pro 解锁）
  /// key: 动物ID, value: 可免费播放的 soundGroup 集合
static const freeSoundGroups = <String, Set<String>>{
  'wild_dog': {'tiger'},
  'mouse': {'cat'},
};

  /// 判断指定动物的指定声音组是否在免费列表中（不考虑 Pro 状态）
  /// 调用方需要额外检查 PurchaseManager.instance.isPro
  static bool isSoundInFreeList(String animalId, String soundGroup) {
    final freeGroups = freeSoundGroups[animalId];
    return freeGroups?.contains(soundGroup) ?? false;
  }

  /// 根据分类获取动物列表
  static List<Animal> findByCategory(AnimalCategory category) {
    if (category == AnimalCategory.all) return animals;
    return animals.where((a) => a.category == category).toList();
  }
}
