import 'package:flutter/widgets.dart';

/// 应用国际化支持 - 多语言
class S {
  final Locale locale;

  S(this.locale);

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('en', 'US'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('es', 'ES'),
    Locale('ru', 'RU'),
    Locale('pt', 'BR'),
    Locale('th', 'TH'),
  ];

  /// 支持的语言代码列表（zh_TW 单独列出以区分繁体）
  static const List<String> supportedLanguageCodes = [
    'zh', 'zh_TW', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'ru', 'pt', 'th',
  ];

  /// 语言代码对应的本地语言名称（用于设置页显示）
  static const Map<String, String> nativeLanguageNames = {
    'zh': '中文（简体）',
    'zh_TW': '中文（繁體）',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'ru': 'Русский',
    'pt': 'Português',
    'th': 'ภาษาไทย',
  };

  /// 翻译 Map 的 key：zh_TW 单独区分，其余用 languageCode
  String get _code {
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') return 'zh_TW';
    return locale.languageCode;
  }

  /// 当前是否为中文环境（简体或繁体）
  bool get isZh => _code == 'zh' || _code == 'zh_TW';

  /// 多语言翻译查找：zh -> en -> fallback
  String _t(Map<String, String> translations) {
    return translations[_code] ?? translations['en'] ?? translations.values.first;
  }

  // ============ 通用 ============
  String get appName => _t(const {
    'zh': '防兽神器', 'zh_TW': '防獸神器', 'en': 'Shoo', 'ja': 'Shoo', 'ko': 'Shoo',
    'fr': 'Shoo', 'de': 'Shoo', 'es': 'Shoo', 'ru': 'Shoo',
    'pt': 'Shoo', 'th': 'Shoo',
  });
  String get appSubtitle => _t(const {
    'zh': '用声音守护你的安全', 'zh_TW': '用聲音守護你的安全', 'en': 'Sound-powered safety', 'ja': '音で守る安全',
    'ko': '소리로 지키는 안전', 'fr': 'Sécurité par le son', 'de': 'Sicherheit durch Klang',
    'es': 'Seguridad a través del sonido', 'ru': 'Безопасность через звук',
    'pt': 'Segurança pelo som', 'th': 'ความปลอดภัยด้วยเสียง',
  });
  String get confirm => _t(const {
    'zh': '确认', 'zh_TW': '確認', 'en': 'Confirm', 'ja': '確認', 'ko': '확인',
    'fr': 'Confirmer', 'de': 'Bestätigen', 'es': 'Confirmar', 'ru': 'Подтвердить',
    'pt': 'Confirmar', 'th': 'ยืนยัน',
  });
  String get cancel => _t(const {
    'zh': '取消', 'zh_TW': '取消', 'en': 'Cancel', 'ja': 'キャンセル', 'ko': '취소',
    'fr': 'Annuler', 'de': 'Abbrechen', 'es': 'Cancelar', 'ru': 'Отмена',
    'pt': 'Cancelar', 'th': 'ยกเลิก',
  });
  String get close => _t(const {
    'zh': '关闭', 'zh_TW': '關閉', 'en': 'Close', 'ja': '閉じる', 'ko': '닫기',
    'fr': 'Fermer', 'de': 'Schließen', 'es': 'Cerrar', 'ru': 'Закрыть',
    'pt': 'Fechar', 'th': 'ปิด',
  });
  String get done => _t(const {
    'zh': '完成', 'zh_TW': '完成', 'en': 'Done', 'ja': '完了', 'ko': '완료',
    'fr': 'Terminé', 'de': 'Fertig', 'es': 'Listo', 'ru': 'Готово',
    'pt': 'Concluído', 'th': 'เสร็จ',
  });
  String get play => _t(const {
    'zh': '播放', 'zh_TW': '播放', 'en': 'Play', 'ja': '再生', 'ko': '재생',
    'fr': 'Lire', 'de': 'Abspielen', 'es': 'Reproducir', 'ru': 'Воспроизвести',
    'pt': 'Reproduzir', 'th': 'เล่น',
  });
  String get stop => _t(const {
    'zh': '停止', 'zh_TW': '停止', 'en': 'Stop', 'ja': '停止', 'ko': '정지',
    'fr': 'Arrêter', 'de': 'Stoppen', 'es': 'Detener', 'ru': 'Остановить',
    'pt': 'Parar', 'th': 'หยุด',
  });
  String get pause => _t(const {
    'zh': '暂停', 'zh_TW': '暫停', 'en': 'Pause', 'ja': '一時停止', 'ko': '일시정지',
    'fr': 'Pause', 'de': 'Pause', 'es': 'Pausar', 'ru': 'Пауза',
    'pt': 'Pausar', 'th': 'หยุดชั่วคราว',
  });
  String get loading => _t(const {
    'zh': '加载中...', 'zh_TW': '載入中...', 'en': 'Loading...', 'ja': '読み込み中...', 'ko': '로딩 중...',
    'fr': 'Chargement...', 'de': 'Laden...', 'es': 'Cargando...', 'ru': 'Загрузка...',
    'pt': 'Carregando...', 'th': 'กำลังโหลด...',
  });
  String get retry => _t(const {
    'zh': '重试', 'zh_TW': '重試', 'en': 'Retry', 'ja': '再試行', 'ko': '재시도',
    'fr': 'Réessayer', 'de': 'Erneut versuchen', 'es': 'Reintentar', 'ru': 'Повторить',
    'pt': 'Tentar novamente', 'th': 'ลองอีกครั้ง',
  });

  // ============ 首页 ============
  String get smartRecommend => _t(const {
    'zh': '智能推荐', 'zh_TW': '智能推薦', 'en': 'Smart Tips', 'ja': 'おすすめ', 'ko': '스마트 추천',
    'fr': 'Conseils intelligents', 'de': 'Smart-Tipps', 'es': 'Consejos inteligentes', 'ru': 'Умные советы',
    'pt': 'Dicas inteligentes', 'th': 'คำแนะนำอัจฉริยะ',
  });
  String get smartRecommendHint => _t(const {
    'zh': '当前时段建议：防蛇/野猪', 'zh_TW': '當前時段建議：防蛇/野豬', 'en': 'Suggested now: Snake/Boar', 'ja': '今の時間帯：蛇/イノシシ',
    'ko': '현재 시간대 추천: 뱀/멧돼지', 'fr': 'Suggestion : Serpent/Sanglier', 'de': 'Empfehlung: Schlange/Wildschwein',
    'es': 'Sugerencia: Serpiente/Jabalí', 'ru': 'Рекомендация: Змея/Кабан',
    'pt': 'Sugestão: Cobra/Javali', 'th': 'แนะนำตอนนี้: งู/หมูป่า',
  });
  String get counterSound => _t(const {
    'zh': '克制声音', 'zh_TW': '剋制聲音', 'en': 'Counter Sound', 'ja': '対抗音', 'ko': '대응 소리',
    'fr': 'Son répulsif', 'de': 'Abwehrsound', 'es': 'Sonido repelente', 'ru': 'Отпугивающий звук',
    'pt': 'Som repelente', 'th': 'เสียงไล่',
  });
  String get detail => _t(const {
    'zh': '详情', 'zh_TW': '詳情', 'en': 'Details', 'ja': '詳細', 'ko': '상세',
    'fr': 'Détails', 'de': 'Details', 'es': 'Detalles', 'ru': 'Подробнее',
    'pt': 'Detalhes', 'th': 'รายละเอียด',
  });
  String get recommendedSounds => _t(const {
    'zh': '推荐声音', 'zh_TW': '推薦聲音', 'en': 'Recommended Sounds', 'ja': 'おすすめの音', 'ko': '추천 소리',
    'fr': 'Sons recommandés', 'de': 'Empfohlene Sounds', 'es': 'Sonidos recomendados', 'ru': 'Рекомендуемые звуки',
    'pt': 'Sons recomendados', 'th': 'เสียงแนะนำ',
  });
  String get nowPlaying => _t(const {
    'zh': '正在播放', 'zh_TW': '正在播放', 'en': 'Now Playing', 'ja': '再生中', 'ko': '재생 중',
    'fr': 'En cours', 'de': 'Jetzt läuft', 'es': 'Reproduciendo', 'ru': 'Сейчас играет',
    'pt': 'Reproduzindo', 'th': 'กำลังเล่น',
  });
  String get noSoundPlaying => _t(const {
    'zh': '点击动物开始驱赶', 'zh_TW': '點擊動物開始驅趕', 'en': 'Tap an animal to start', 'ja': '動物をタップして開始',
    'ko': '동물을 탭하여 시작', 'fr': 'Touchez un animal pour commencer', 'de': 'Tier antippen zum Starten',
    'es': 'Toca un animal para empezar', 'ru': 'Нажмите на животное для старта',
    'pt': 'Toque um animal para começar', 'th': 'แตะสัตว์เพื่อเริ่ม',
  });
  String get startScaring => _t(const {
    'zh': '开始驱赶', 'zh_TW': '開始驅趕', 'en': 'Start Scaring', 'ja': '追い払い開始', 'ko': '쫓아내기 시작',
    'fr': 'Commencer la répulsion', 'de': 'Vertreibung starten', 'es': 'Empezar a ahuyentar', 'ru': 'Начать отпугивание',
    'pt': 'Começar a espantar', 'th': 'เริ่มไล่',
  });
  String get stopScaring => _t(const {
    'zh': '停止驱赶', 'zh_TW': '停止驅趕', 'en': 'Stop Scaring', 'ja': '追い払い停止', 'ko': '쫓아내기 중지',
    'fr': 'Arrêter la répulsion', 'de': 'Vertreibung stoppen', 'es': 'Dejar de ahuyentar', 'ru': 'Остановить отпугивание',
    'pt': 'Parar de espantar', 'th': 'หยุดไล่',
  });

  // ============ 分类 ============
  String get allCategories => _t(const {
    'zh': '全部', 'zh_TW': '全部', 'en': 'All', 'ja': 'すべて', 'ko': '전체',
    'fr': 'Tout', 'de': 'Alle', 'es': 'Todo', 'ru': 'Все',
    'pt': 'Todos', 'th': 'ทั้งหมด',
  });
  String get beastCategory => _t(const {
    'zh': '猛兽威胁', 'zh_TW': '猛獸威脅', 'en': 'Beasts', 'ja': '猛獣', 'ko': '맹수',
    'fr': 'Bêtes féroces', 'de': 'Raubtiere', 'es': 'Bestias', 'ru': 'Хищники',
    'pt': 'Feras', 'th': 'สัตว์นักล่า',
  });
  String get reptileCategory => _t(const {
    'zh': '爬行类', 'zh_TW': '爬行類', 'en': 'Reptiles', 'ja': '爬虫類', 'ko': '파충류',
    'fr': 'Reptiles', 'de': 'Reptilien', 'es': 'Reptiles', 'ru': 'Рептилии',
    'pt': 'Répteis', 'th': 'สัตว์เลื้อยคลาน',
  });
  String get primateCategory => _t(const {
    'zh': '灵长类', 'zh_TW': '靈長類', 'en': 'Primates', 'ja': '霊長類', 'ko': '영장류',
    'fr': 'Primates', 'de': 'Primaten', 'es': 'Primates', 'ru': 'Приматы',
    'pt': 'Primatas', 'th': 'สัตว์อันดับลิง',
  });
  String get rodentCategory => _t(const {
    'zh': '啮齿类', 'zh_TW': '齧齒類', 'en': 'Rodents', 'ja': '齧歯類', 'ko': '설치류',
    'fr': 'Rongeurs', 'de': 'Nagetiere', 'es': 'Roedores', 'ru': 'Грызуны',
    'pt': 'Roedores', 'th': 'สัตว์ฟันแทะ',
  });
  String get insectCategory => _t(const {
    'zh': '昆虫类', 'zh_TW': '昆蟲類', 'en': 'Insects', 'ja': '昆虫類', 'ko': '곤충류',
    'fr': 'Insectes', 'de': 'Insekten', 'es': 'Insectos', 'ru': 'Насекомые',
    'pt': 'Insetos', 'th': 'แมลง',
  });
  String get birdCategory => _t(const {
    'zh': '鸟类', 'zh_TW': '鳥類', 'en': 'Birds', 'ja': '鳥類', 'ko': '조류',
    'fr': 'Oiseaux', 'de': 'Vögel', 'es': 'Aves', 'ru': 'Птицы',
    'pt': 'Aves', 'th': 'นก',
  });

  // ============ 动物名称 ============
  String get wildDog => _t(const {
    'zh': '野狗', 'zh_TW': '野狗', 'en': 'Wild Dog', 'ja': '野良犬', 'ko': '들개',
    'fr': 'Chien sauvage', 'de': 'Wildhund', 'es': 'Perro salvaje', 'ru': 'Дикая собака',
    'pt': 'Cão selvagem', 'th': 'หมาป่า',
  });
  String get snake => _t(const {
    'zh': '毒蛇', 'zh_TW': '毒蛇', 'en': 'Venomous Snake', 'ja': '毒蛇', 'ko': '독사',
    'fr': 'Serpent venimeux', 'de': 'Giftschlange', 'es': 'Serpiente venenosa', 'ru': 'Ядовитая змея',
    'pt': 'Cobra venenosa', 'th': 'งูพิษ',
  });
  String get wildBoar => _t(const {
    'zh': '野猪', 'zh_TW': '野豬', 'en': 'Wild Boar', 'ja': 'イノシシ', 'ko': '멧돼지',
    'fr': 'Sanglier', 'de': 'Wildschwein', 'es': 'Jabalí', 'ru': 'Кабан',
    'pt': 'Javali', 'th': 'หมูป่า',
  });
  String get bear => _t(const {
    'zh': '熊', 'zh_TW': '熊', 'en': 'Bear', 'ja': '熊', 'ko': '곰',
    'fr': 'Ours', 'de': 'Bär', 'es': 'Oso', 'ru': 'Медведь',
    'pt': 'Urso', 'th': 'หมี',
  });
  String get monkey => _t(const {
    'zh': '猴子', 'zh_TW': '猴子', 'en': 'Monkey', 'ja': '猿', 'ko': '원숭이',
    'fr': 'Singe', 'de': 'Affe', 'es': 'Mono', 'ru': 'Обезьяна',
    'pt': 'Macaco', 'th': 'ลิง',
  });
  String get mouse => _t(const {
    'zh': '老鼠', 'zh_TW': '老鼠', 'en': 'Mouse', 'ja': 'ネズミ', 'ko': '쥐',
    'fr': 'Souris', 'de': 'Maus', 'es': 'Ratón', 'ru': 'Мышь',
    'pt': 'Rato', 'th': 'หนู',
  });
  String get wolf => _t(const {
    'zh': '狼', 'zh_TW': '狼', 'en': 'Wolf', 'ja': 'オオカミ', 'ko': '늑대',
    'fr': 'Loup', 'de': 'Wolf', 'es': 'Lobo', 'ru': 'Волк',
    'pt': 'Lobo', 'th': 'หมาป่า',
  });
  String get spider => _t(const {
    'zh': '毒蜘蛛', 'zh_TW': '毒蜘蛛', 'en': 'Venomous Spider', 'ja': '毒蜘蛛', 'ko': '독거미',
    'fr': 'Araignée venimeuse', 'de': 'Giftspinne', 'es': 'Araña venenosa', 'ru': 'Ядовитый паук',
    'pt': 'Aranha venenosa', 'th': 'แมงมุมพิษ',
  });
  String get wasp => _t(const {
    'zh': '马蜂', 'zh_TW': '馬蜂', 'en': 'Wasp', 'ja': 'スズメバチ', 'ko': '말벌',
    'fr': 'Guêpe', 'de': 'Wespe', 'es': 'Avispa', 'ru': 'Оса',
    'pt': 'Vespa', 'th': 'ต่อ',
  });
  String get rabbit => _t(const {
    'zh': '野兔', 'zh_TW': '野兔', 'en': 'Wild Rabbit', 'ja': '野ウサギ', 'ko': '토끼',
    'fr': 'Lapin sauvage', 'de': 'Wildkaninchen', 'es': 'Conejo silvestre', 'ru': 'Дикий кролик',
    'pt': 'Coelho selvagem', 'th': 'กระต่ายป่า',
  });
  String get crow => _t(const {
    'zh': '乌鸦', 'zh_TW': '烏鴉', 'en': 'Crow', 'ja': 'カラス', 'ko': '까마귀',
    'fr': 'Corbeau', 'de': 'Krähe', 'es': 'Cuervo', 'ru': 'Ворона',
    'pt': 'Corvo', 'th': 'อีกา',
  });
  String get fox => _t(const {
    'zh': '狐狸', 'zh_TW': '狐狸', 'en': 'Fox', 'ja': 'キツネ', 'ko': '여우',
    'fr': 'Renard', 'de': 'Fuchs', 'es': 'Zorro', 'ru': 'Лиса',
    'pt': 'Raposa', 'th': 'สุนัขจิ้งจอก',
  });

  // ============ 播放器 ============
  String get volume => _t(const {
    'zh': '音量', 'zh_TW': '音量', 'en': 'Volume', 'ja': '音量', 'ko': '볼륨',
    'fr': 'Volume', 'de': 'Lautstärke', 'es': 'Volumen', 'ru': 'Громкость',
    'pt': 'Volume', 'th': 'ระดับเสียง',
  });
  String get playMode => _t(const {
    'zh': '播放模式', 'zh_TW': '播放模式', 'en': 'Play Mode', 'ja': '再生モード', 'ko': '재생 모드',
    'fr': 'Mode de lecture', 'de': 'Wiedergabemodus', 'es': 'Modo de reproducción', 'ru': 'Режим воспроизведения',
    'pt': 'Modo de reprodução', 'th': 'โหมดการเล่น',
  });
  String get continuous => _t(const {
    'zh': '持续播放', 'zh_TW': '持續播放', 'en': 'Continuous', 'ja': '連続再生', 'ko': '연속 재생',
    'fr': 'Continu', 'de': 'Dauerbetrieb', 'es': 'Continuo', 'ru': 'Непрерывный',
    'pt': 'Contínuo', 'th': 'เล่นต่อเนื่อง',
  });
  String get intervalPlay => _t(const {
    'zh': '间隔播放', 'zh_TW': '間隔播放', 'en': 'Interval', 'ja': '間隔再生', 'ko': '간격 재생',
    'fr': 'Intervalle', 'de': 'Intervall', 'es': 'Intervalo', 'ru': 'Интервальный',
    'pt': 'Intervalo', 'th': 'เล่นช่วงห่าง',
  });
  String get intervalTime => _t(const {
    'zh': '间隔时间', 'zh_TW': '間隔時間', 'en': 'Interval Time', 'ja': '間隔時間', 'ko': '간격 시간',
    'fr': 'Temps d\'intervalle', 'de': 'Intervallzeit', 'es': 'Tiempo de intervalo', 'ru': 'Время интервала',
    'pt': 'Tempo de intervalo', 'th': 'เวลาช่วงห่าง',
  });

  // ============ 混合器 ============
  String get soundMix => _t(const {
    'zh': '声音混合', 'zh_TW': '聲音混合', 'en': 'Sound Mix', 'ja': 'サウンドミックス', 'ko': '소리 믹스',
    'fr': 'Mixage sonore', 'de': 'Sound-Mix', 'es': 'Mezcla de sonido', 'ru': 'Микширование',
    'pt': 'Mixagem de som', 'th': 'ผสมเสียง',
  });
  String get addSound => _t(const {
    'zh': '添加声音', 'zh_TW': '新增聲音', 'en': 'Add Sound', 'ja': '音を追加', 'ko': '소리 추가',
    'fr': 'Ajouter un son', 'de': 'Sound hinzufügen', 'es': 'Añadir sonido', 'ru': 'Добавить звук',
    'pt': 'Adicionar som', 'th': 'เพิ่มเสียง',
  });
  String get startMix => _t(const {
    'zh': '开始混合', 'zh_TW': '開始混合', 'en': 'Start Mix', 'ja': 'ミックス開始', 'ko': '믹스 시작',
    'fr': 'Commencer le mixage', 'de': 'Mix starten', 'es': 'Iniciar mezcla', 'ru': 'Начать микс',
    'pt': 'Iniciar mixagem', 'th': 'เริ่มผสม',
  });
  String get stopMix => _t(const {
    'zh': '停止混合', 'zh_TW': '停止混合', 'en': 'Stop Mix', 'ja': 'ミックス停止', 'ko': '믹스 중지',
    'fr': 'Arrêter le mixage', 'de': 'Mix stoppen', 'es': 'Detener mezcla', 'ru': 'Остановить микс',
    'pt': 'Parar mixagem', 'th': 'หยุดผสม',
  });

  // ============ 定时器 ============
  String get timer => _t(const {
    'zh': '定时播放', 'zh_TW': '定時播放', 'en': 'Timer', 'ja': 'タイマー', 'ko': '타이머',
    'fr': 'Minuteur', 'de': 'Timer', 'es': 'Temporizador', 'ru': 'Таймер',
    'pt': 'Timer', 'th': 'ตั้งเวลา',
  });
  String get setTimer => _t(const {
    'zh': '设置定时', 'zh_TW': '設定定時', 'en': 'Set Timer', 'ja': 'タイマー設定', 'ko': '타이머 설정',
    'fr': 'Régler le minuteur', 'de': 'Timer einstellen', 'es': 'Configurar temporizador', 'ru': 'Установить таймер',
    'pt': 'Configurar timer', 'th': 'ตั้งเวลา',
  });
  String get selectDuration => _t(const {
    'zh': '选择时长', 'zh_TW': '選擇時長', 'en': 'Duration', 'ja': '時間選択', 'ko': '시간 선택',
    'fr': 'Durée', 'de': 'Dauer', 'es': 'Duración', 'ru': 'Длительность',
    'pt': 'Duração', 'th': 'ระยะเวลา',
  });
  String get minutes => _t(const {
    'zh': '分钟', 'zh_TW': '分鐘', 'en': 'min', 'ja': '分', 'ko': '분',
    'fr': 'min', 'de': 'Min.', 'es': 'min', 'ru': 'мин',
    'pt': 'min', 'th': 'นาที',
  });
  String get hours => _t(const {
    'zh': '小时', 'zh_TW': '小時', 'en': 'hr', 'ja': '時間', 'ko': '시간',
    'fr': 'h', 'de': 'Std.', 'es': 'h', 'ru': 'ч',
    'pt': 'h', 'th': 'ชั่วโมง',
  });
  String get seconds => _t(const {
    'zh': '秒', 'zh_TW': '秒', 'en': 'sec', 'ja': '秒', 'ko': '초',
    'fr': 's', 'de': 'Sek.', 'es': 's', 'ru': 'с',
    'pt': 's', 'th': 'วินาที',
  });
  String get noInterval => _t(const {
    'zh': '无间隔', 'zh_TW': '無間隔', 'en': 'No interval', 'ja': '間隔なし', 'ko': '간격 없음',
    'fr': 'Pas d\'intervalle', 'de': 'Kein Intervall', 'es': 'Sin intervalo', 'ru': 'Без интервала',
    'pt': 'Sem intervalo', 'th': 'ไม่มีช่วงห่าง',
  });
  String get startTimer => _t(const {
    'zh': '开始定时', 'zh_TW': '開始定時', 'en': 'Start', 'ja': '開始', 'ko': '시작',
    'fr': 'Démarrer', 'de': 'Starten', 'es': 'Iniciar', 'ru': 'Старт',
    'pt': 'Iniciar', 'th': 'เริ่ม',
  });
  String get cancelTimer => _t(const {
    'zh': '取消定时', 'zh_TW': '取消定時', 'en': 'Cancel', 'ja': 'キャンセル', 'ko': '취소',
    'fr': 'Annuler', 'de': 'Abbrechen', 'es': 'Cancelar', 'ru': 'Отмена',
    'pt': 'Cancelar', 'th': 'ยกเลิก',
  });
  String get timerFinished => _t(const {
    'zh': '定时结束，已停止播放', 'zh_TW': '定時結束，已停止播放', 'en': 'Timer done, stopped', 'ja': 'タイマー終了、再生停止',
    'ko': '타이머 종료, 재생 중지', 'fr': 'Minuteur terminé, arrêté', 'de': 'Timer beendet, gestoppt',
    'es': 'Temporizador terminado, detenido', 'ru': 'Таймер завершён, остановлено',
    'pt': 'Timer encerrado, parado', 'th': 'หมดเวลาแล้ว หยุดเล่น',
  });
  String get noAutoStop => _t(const {
    'zh': '不自动停止', 'zh_TW': '不自動停止', 'en': 'No auto stop', 'ja': '自動停止しない', 'ko': '자동 정지 안함',
    'fr': 'Pas d\'arrêt auto', 'de': 'Kein Auto-Stopp', 'es': 'Sin parada automática', 'ru': 'Без автостопа',
    'pt': 'Sem parada automática', 'th': 'ไม่หยุดอัตโนมัติ',
  });

  // ============ 手表 ============
  String get watchConnect => _t(const {
    'zh': '手表连接', 'zh_TW': '手錶連接', 'en': 'Watch', 'ja': '時計接続', 'ko': '워치 연결',
    'fr': 'Montre', 'de': 'Uhr', 'es': 'Reloj', 'ru': 'Часы',
    'pt': 'Relógio', 'th': 'นาฬิกา',
  });
  String get watchConnected => _t(const {
    'zh': '手表已连接', 'zh_TW': '手錶已連接', 'en': 'Watch Connected', 'ja': '時計接続済み', 'ko': '워치 연결됨',
    'fr': 'Montre connectée', 'de': 'Uhr verbunden', 'es': 'Reloj conectado', 'ru': 'Часы подключены',
    'pt': 'Relógio conectado', 'th': 'นาฬิกาเชื่อมต่อแล้ว',
  });
  String get watchDisconnected => _t(const {
    'zh': '未检测到手表', 'zh_TW': '未偵測到手錶', 'en': 'No Watch', 'ja': '時計未検出', 'ko': '워치 없음',
    'fr': 'Pas de montre', 'de': 'Keine Uhr', 'es': 'Sin reloj', 'ru': 'Нет часов',
    'pt': 'Sem relógio', 'th': 'ไม่พบนาฬิกา',
  });
  String get remotePlay => _t(const {
    'zh': '遥控播放', 'zh_TW': '遙控播放', 'en': 'Remote Play', 'ja': 'リモート再生', 'ko': '원격 재생',
    'fr': 'Lecture à distance', 'de': 'Fernbedienung', 'es': 'Reproducción remota', 'ru': 'Дистанционное управление',
    'pt': 'Reprodução remota', 'th': 'เล่นระยะไกล',
  });
String get emergencyBtn => _t(const {
'zh': '一键驱赶', 'zh_TW': '一鍵驅趕', 'en': 'Quick Repel', 'ja': 'すぐ追い払う', 'ko': '원터치 퇴치',
'fr': 'Répulsion rapide', 'de': 'Sofort vertreiben', 'es': 'Repeler al instante', 'ru': 'Мгновенное отпугивание',
'pt': 'Repulsão rápida', 'th': 'ไล่ทันที',
});
  String get hapticFeedback => _t(const {
    'zh': '触觉反馈', 'zh_TW': '觸覺回饋', 'en': 'Haptic', 'ja': 'ハプティック', 'ko': '햅틱 피드백',
    'fr': 'Haptique', 'de': 'Haptik', 'es': 'Háptico', 'ru': 'Тактильная отдача',
    'pt': 'Háptico', 'th': 'สัมผัส',
  });
  String get rescanWatch => _t(const {
    'zh': '重新搜索', 'zh_TW': '重新搜尋', 'en': 'Rescan', 'ja': '再スキャン', 'ko': '다시 검색',
    'fr': 'Rechercher', 'de': 'Erneut suchen', 'es': 'Escanear de nuevo', 'ru': 'Пересканировать',
    'pt': 'Escanear novamente', 'th': 'ค้นหาใหม่',
  });

  // ============ 设置 ============
  String get settings => _t(const {
    'zh': '设置', 'zh_TW': '設定', 'en': 'Settings', 'ja': '設定', 'ko': '설정',
    'fr': 'Paramètres', 'de': 'Einstellungen', 'es': 'Ajustes', 'ru': 'Настройки',
    'pt': 'Configurações', 'th': 'การตั้งค่า',
  });
  String get appearance => _t(const {
    'zh': '外观', 'zh_TW': '外觀', 'en': 'Appearance', 'ja': '外観', 'ko': '외관',
    'fr': 'Apparence', 'de': 'Erscheinungsbild', 'es': 'Apariencia', 'ru': 'Внешний вид',
    'pt': 'Aparência', 'th': 'ลักษณะที่ปรากฏ',
  });
  String get themeMode => _t(const {
    'zh': '主题模式', 'zh_TW': '主題模式', 'en': 'Theme', 'ja': 'テーマ', 'ko': '테마',
    'fr': 'Thème', 'de': 'Design', 'es': 'Tema', 'ru': 'Тема',
    'pt': 'Tema', 'th': 'ธีม',
  });
  String get followSystem => _t(const {
    'zh': '跟随系统', 'zh_TW': '跟隨系統', 'en': 'System', 'ja': 'システムに従う', 'ko': '시스템 설정',
    'fr': 'Système', 'de': 'System', 'es': 'Sistema', 'ru': 'Системная',
    'pt': 'Sistema', 'th': 'ตามระบบ',
  });
  String get lightMode => _t(const {
    'zh': '浅色', 'zh_TW': '淺色', 'en': 'Light', 'ja': 'ライト', 'ko': '라이트',
    'fr': 'Clair', 'de': 'Hell', 'es': 'Claro', 'ru': 'Светлая',
    'pt': 'Claro', 'th': 'สว่าง',
  });
  String get darkMode => _t(const {
    'zh': '深色', 'zh_TW': '深色', 'en': 'Dark', 'ja': 'ダーク', 'ko': '다크',
    'fr': 'Sombre', 'de': 'Dunkel', 'es': 'Oscuro', 'ru': 'Тёмная',
    'pt': 'Escuro', 'th': 'มืด',
  });
  String get language => _t(const {
    'zh': '语言', 'zh_TW': '語言', 'en': 'Language', 'ja': '言語', 'ko': '언어',
    'fr': 'Langue', 'de': 'Sprache', 'es': 'Idioma', 'ru': 'Язык',
    'pt': 'Idioma', 'th': 'ภาษา',
  });
  String get defaultVolume => _t(const {
    'zh': '默认音量', 'zh_TW': '預設音量', 'en': 'Default Volume', 'ja': 'デフォルト音量', 'ko': '기본 볼륨',
    'fr': 'Volume par défaut', 'de': 'Standardlautstärke', 'es': 'Volumen predeterminado', 'ru': 'Громкость по умолчанию',
    'pt': 'Volume padrão', 'th': 'ระดับเสียงเริ่มต้น',
  });
  String get keepScreenOn => _t(const {
    'zh': '保持屏幕常亮', 'zh_TW': '保持螢幕常亮', 'en': 'Keep Screen On', 'ja': '画面を点灯したまま', 'ko': '화면 켜짐 유지',
    'fr': 'Garder l\'écran allumé', 'de': 'Bildschirm aktiv halten', 'es': 'Mantener pantalla encendida', 'ru': 'Не выключать экран',
    'pt': 'Manter tela ligada', 'th': 'คงหน้าจอไว้',
  });
  String get autoStop => _t(const {
    'zh': '自动停止', 'zh_TW': '自動停止', 'en': 'Auto Stop', 'ja': '自動停止', 'ko': '자동 정지',
    'fr': 'Arrêt automatique', 'de': 'Auto-Stopp', 'es': 'Parada automática', 'ru': 'Автостоп',
    'pt': 'Parada automática', 'th': 'หยุดอัตโนมัติ',
  });
  String get about => _t(const {
    'zh': '关于', 'zh_TW': '關於', 'en': 'About', 'ja': 'について', 'ko': '정보',
    'fr': 'À propos', 'de': 'Über', 'es': 'Acerca de', 'ru': 'О приложении',
    'pt': 'Sobre', 'th': 'เกี่ยวกับ',
  });
  String get version => _t(const {
    'zh': '版本', 'zh_TW': '版本', 'en': 'Version', 'ja': 'バージョン', 'ko': '버전',
    'fr': 'Version', 'de': 'Version', 'es': 'Versión', 'ru': 'Версия',
    'pt': 'Versão', 'th': 'เวอร์ชัน',
  });
  String get rateUs => _t(const {
    'zh': '给我们评分', 'zh_TW': '給我們評分', 'en': 'Rate Us', 'ja': '評価する', 'ko': '평가하기',
    'fr': 'Nous noter', 'de': 'Bewerten Sie uns', 'es': 'Califíquenos', 'ru': 'Оцените нас',
    'pt': 'Avalie-nos', 'th': 'ให้คะแนน',
  });
  String get feedback => _t(const {
    'zh': '意见反馈', 'zh_TW': '意見回饋', 'en': 'Feedback', 'ja': 'フィードバック', 'ko': '피드백',
    'fr': 'Commentaires', 'de': 'Feedback', 'es': 'Comentarios', 'ru': 'Обратная связь',
    'pt': 'Feedback', 'th': 'ข้อเสนอแนะ',
  });
  String get legal => _t(const {
    'zh': '法律条款', 'zh_TW': '法律條款', 'en': 'Legal', 'ja': '法的事項', 'ko': '법적 고지',
    'fr': 'Mentions légales', 'de': 'Rechtliches', 'es': 'Legal', 'ru': 'Правовая информация',
    'pt': 'Legal', 'th': 'ข้อกฎหมาย',
  });
  String get termsOfService => _t(const {
    'zh': '用户服务协议', 'zh_TW': '使用者服務協議', 'en': 'Terms of Service', 'ja': '利用規約', 'ko': '이용약관',
    'fr': 'Conditions d\'utilisation', 'de': 'Nutzungsbedingungen', 'es': 'Términos de servicio', 'ru': 'Условия использования',
    'pt': 'Termos de serviço', 'th': 'ข้อกำหนดการใช้บริการ',
  });
  String get privacyPolicy => _t(const {
    'zh': '隐私政策', 'zh_TW': '隱私權政策', 'en': 'Privacy Policy', 'ja': 'プライバシーポリシー', 'ko': '개인정보 처리방침',
    'fr': 'Politique de confidentialité', 'de': 'Datenschutzrichtlinie', 'es': 'Política de privacidad', 'ru': 'Политика конфиденциальности',
    'pt': 'Política de privacidade', 'th': 'นโยบายความเป็นส่วนตัว',
  });
  String get playback => _t(const {
    'zh': '播放', 'zh_TW': '播放', 'en': 'Playback', 'ja': '再生', 'ko': '재생',
    'fr': 'Lecture', 'de': 'Wiedergabe', 'es': 'Reproducción', 'ru': 'Воспроизведение',
    'pt': 'Reprodução', 'th': 'การเล่น',
  });

  // ============ 声音库 ============
  String get soundLibrary => _t(const {
    'zh': '声音库', 'zh_TW': '聲音庫', 'en': 'Sounds', 'ja': 'サウンドライブラリ', 'ko': '소리 라이브러리',
    'fr': 'Bibliothèque sonore', 'de': 'Sound-Bibliothek', 'es': 'Biblioteca de sonidos', 'ru': 'Библиотека звуков',
    'pt': 'Biblioteca de sons', 'th': 'ไลบรารีเสียง',
  });
  String get ultrasonic => _t(const {
    'zh': '超声波', 'zh_TW': '超聲波', 'en': 'Ultrasonic', 'ja': '超音波', 'ko': '초음파',
    'fr': 'Ultrason', 'de': 'Ultraschall', 'es': 'Ultrasonido', 'ru': 'Ультразвук',
    'pt': 'Ultrassom', 'th': 'อัลตราซาวด์',
  });
  String get animalDeterrent => _t(const {
    'zh': '动物威慑', 'zh_TW': '動物威懾', 'en': 'Animal', 'ja': '動物忌避', 'ko': '동물 퇴치',
    'fr': 'Répulsif animal', 'de': 'Tierabwehr', 'es': 'Repelente animal', 'ru': 'Отпугиватель животных',
    'pt': 'Repelente animal', 'th': 'ไล่สัตว์',
  });
  String get firecracker => _t(const {
    'zh': '炮仗', 'zh_TW': '炮仗', 'en': 'Firecracker', 'ja': '爆竹', 'ko': '폭죽',
    'fr': 'Pétard', 'de': 'Feuerwerk', 'es': 'Petardo', 'ru': 'Петарда',
    'pt': 'Foguete', 'th': 'ประทัด',
  });
  String get alarm => _t(const {
    'zh': '警报', 'zh_TW': '警報', 'en': 'Alarm', 'ja': 'アラーム', 'ko': '알람',
    'fr': 'Alarme', 'de': 'Alarm', 'es': 'Alarma', 'ru': 'Тревога',
    'pt': 'Alarme', 'th': 'สัญญาณเตือน',
  });
  String get metalImpact => _t(const {
    'zh': '金属撞击', 'zh_TW': '金屬撞擊', 'en': 'Metal', 'ja': '金属衝突', 'ko': '금속 충격',
    'fr': 'Impact métallique', 'de': 'Metall Schlag', 'es': 'Impacto metálico', 'ru': 'Металлический удар',
    'pt': 'Impacto metálico', 'th': 'เสียงโลหะ',
  });
  String get targetAnimal => _t(const {
    'zh': '驱赶目标', 'zh_TW': '驅趕目標', 'en': 'Target', 'ja': '追い払い対象', 'ko': '퇴치 대상',
    'fr': 'Cible', 'de': 'Ziel', 'es': 'Objetivo', 'ru': 'Цель',
    'pt': 'Alvo', 'th': 'เป้าหมาย',
  });
  String get frequencyRange => _t(const {
    'zh': '频率范围', 'zh_TW': '頻率範圍', 'en': 'Frequency', 'ja': '周波数範囲', 'ko': '주파수 범위',
    'fr': 'Fréquence', 'de': 'Frequenz', 'es': 'Frecuencia', 'ru': 'Частота',
    'pt': 'Frequência', 'th': 'ความถี่',
  });

  // ============ 底部导航 ============
  String get navHome => _t(const {
    'zh': '首页', 'zh_TW': '首頁', 'en': 'Home', 'ja': 'ホーム', 'ko': '홈',
    'fr': 'Accueil', 'de': 'Start', 'es': 'Inicio', 'ru': 'Главная',
    'pt': 'Início', 'th': 'หน้าแรก',
  });
  String get navSounds => _t(const {
    'zh': '声音', 'zh_TW': '聲音', 'en': 'Sounds', 'ja': 'サウンド', 'ko': '소리',
    'fr': 'Sons', 'de': 'Sounds', 'es': 'Sonidos', 'ru': 'Звуки',
    'pt': 'Sons', 'th': 'เสียง',
  });
  String get navMix => _t(const {
    'zh': '混合', 'zh_TW': '混合', 'en': 'Mix', 'ja': 'ミックス', 'ko': '믹스',
    'fr': 'Mix', 'de': 'Mix', 'es': 'Mezcla', 'ru': 'Микс',
    'pt': 'Mix', 'th': 'ผสม',
  });
  String get navTimer => _t(const {
    'zh': '定时', 'zh_TW': '定時', 'en': 'Timer', 'ja': 'タイマー', 'ko': '타이머',
    'fr': 'Minuteur', 'de': 'Timer', 'es': 'Temporizador', 'ru': 'Таймер',
    'pt': 'Timer', 'th': 'ตั้งเวลา',
  });
  String get navWatch => _t(const {
    'zh': '手表', 'zh_TW': '手錶', 'en': 'Watch', 'ja': '時計', 'ko': '워치',
    'fr': 'Montre', 'de': 'Uhr', 'es': 'Reloj', 'ru': 'Часы',
    'pt': 'Relógio', 'th': 'นาฬิกา',
  });
  String get navSettings => _t(const {
    'zh': '设置', 'zh_TW': '設定', 'en': 'Settings', 'ja': '設定', 'ko': '설정',
    'fr': 'Paramètres', 'de': 'Einstellungen', 'es': 'Ajustes', 'ru': 'Настройки',
    'pt': 'Configurações', 'th': 'การตั้งค่า',
  });

  // ============ 首页补充 ============
  String get iconStyle => _t(const {
    'zh': '图标风格', 'zh_TW': '圖示風格', 'en': 'Icon Style', 'ja': 'アイコンスタイル', 'ko': '아이콘 스타일',
    'fr': 'Style d\'icône', 'de': 'Icon-Stil', 'es': 'Estilo de icono', 'ru': 'Стиль иконок',
    'pt': 'Estilo de ícone', 'th': 'สไตล์ไอคอน',
  });
  String get mode => _t(const {
    'zh': '播放模式', 'zh_TW': '播放模式', 'en': 'Mode', 'ja': 'モード', 'ko': '모드',
    'fr': 'Mode', 'de': 'Modus', 'es': 'Modo', 'ru': 'Режим',
    'pt': 'Modo', 'th': 'โหมด',
  });
  String get single => _t(const {
    'zh': '单个', 'zh_TW': '單個', 'en': 'Single', 'ja': '単一', 'ko': '단일',
    'fr': 'Unique', 'de': 'Einzeln', 'es': 'Único', 'ru': 'Одиночный',
    'pt': 'Único', 'th': 'เดี่ยว',
  });
  String get sequence => _t(const {
    'zh': '多选', 'zh_TW': '多選', 'en': 'Multi', 'ja': '複数', 'ko': '다중',
    'fr': 'Multi', 'de': 'Multi', 'es': 'Multi', 'ru': 'Мульти',
    'pt': 'Multi', 'th': 'หลายรายการ',
  });
  String get selectSound => _t(const {
    'zh': '选择声音', 'zh_TW': '選擇聲音', 'en': 'Select', 'ja': '音声選択', 'ko': '소리 선택',
    'fr': 'Sélectionner', 'de': 'Auswählen', 'es': 'Seleccionar', 'ru': 'Выбрать',
    'pt': 'Selecionar', 'th': 'เลือก',
  });
  String get singleLoop => _t(const {
    'zh': '单个循环', 'zh_TW': '單個循環', 'en': 'Single loop', 'ja': '単一ループ', 'ko': '단일 루프',
    'fr': 'Boucle unique', 'de': 'Einzelschleife', 'es': 'Bucle único', 'ru': 'Одиночный цикл',
    'pt': 'Loop único', 'th': 'วนซ้ำเดี่ยว',
  });
  String get sequenceLoop => _t(const {
    'zh': '多选循环', 'zh_TW': '多選循環', 'en': 'Multi loop', 'ja': '複数ループ', 'ko': '다중 루프',
    'fr': 'Boucle multi', 'de': 'Multi-Schleife', 'es': 'Bucle múltiple', 'ru': 'Мульти-цикл',
    'pt': 'Loop múltiplo', 'th': 'วนซ้ำหลายรายการ',
  });
  String get nFiles => _t(const {
    'zh': '个文件', 'zh_TW': '個檔案', 'en': ' files', 'ja': 'ファイル', 'ko': '개 파일',
    'fr': ' fichiers', 'de': ' Dateien', 'es': ' archivos', 'ru': ' файлов',
    'pt': ' arquivos', 'th': ' ไฟล์',
  });
  String get singleFile => _t(const {
    'zh': '单文件', 'zh_TW': '單檔案', 'en': 'Single file', 'ja': '単一ファイル', 'ko': '단일 파일',
    'fr': 'Fichier unique', 'de': 'Einzeldatei', 'es': 'Archivo único', 'ru': 'Одиночный файл',
    'pt': 'Arquivo único', 'th': 'ไฟล์เดียว',
  });
  String get sequenceLoopDesc => _t(const {
    'zh': '勾选的声音文件会按顺序循环播放，播完后从头继续。',
    'zh_TW': '勾選的聲音檔案會按順序循環播放，播完後從頭繼續。',
    'en': 'Selected files play in order on loop, then start over.',
    'ja': '選択したファイルを順番にループ再生し、終わったら最初から繰り返します。',
    'ko': '선택한 파일을 순서대로 반복 재생하며, 끝나면 처음부터 다시 시작합니다.',
    'fr': 'Les fichiers sélectionnés sont lus en boucle, puis recommencent.',
    'de': 'Ausgewählte Dateien werden in Schleife abgespielt und beginnen dann von vorn.',
    'es': 'Los archivos seleccionados se reproducen en bucle y luego vuelven a empezar.',
    'ru': 'Выбранные файлы воспроизводятся по порядку в цикле, затем начинаются сначала.',
    'pt': 'Os arquivos selecionados são reproduzidos em loop e recomeçam do início.',
    'th': 'ไฟล์ที่เลือกจะเล่นตามลำดับวนซ้ำ เมื่อจบจะเริ่มใหม่',
  });
  String get loopInterval => _t(const {
    'zh': '循环间隔', 'zh_TW': '循環間隔', 'en': 'Loop Interval', 'ja': 'ループ間隔', 'ko': '루프 간격',
    'fr': 'Intervalle de boucle', 'de': 'Schleifenintervall', 'es': 'Intervalo de bucle', 'ru': 'Интервал цикла',
    'pt': 'Intervalo de loop', 'th': 'ช่วงห่างการวนซ้ำ',
  });
  String get closed => _t(const {
    'zh': '关闭', 'zh_TW': '關閉', 'en': 'Off', 'ja': 'オフ', 'ko': '끄기',
    'fr': 'Désactivé', 'de': 'Aus', 'es': 'Desactivado', 'ru': 'Выкл',
    'pt': 'Desativado', 'th': 'ปิด',
  });
  String get tapToPreview => _t(const {
    'zh': '点击试听驱赶声音', 'zh_TW': '點擊試聽驅趕聲音', 'en': 'Tap to preview sounds', 'ja': 'タップして音を試聴',
    'ko': '탭하여 소리 미리듣기', 'fr': 'Appuyez pour écouter', 'de': 'Antippen zum Anhören',
    'es': 'Toca para escuchar', 'ru': 'Нажмите для прослушивания',
    'pt': 'Toque para ouvir', 'th': 'แตะเพื่อฟังตัวอย่าง',
  });

  // ============ 波形/音频文件 ============
  String get audioFile => _t(const {
    'zh': '音频', 'zh_TW': '音訊', 'en': 'File', 'ja': 'ファイル', 'ko': '파일',
    'fr': 'Fichier', 'de': 'Datei', 'es': 'Archivo', 'ru': 'Файл',
    'pt': 'Arquivo', 'th': 'ไฟล์',
  });
  String get generatingWaveform => _t(const {
    'zh': '波形生成中', 'zh_TW': '波形生成中', 'en': 'Generating waveform', 'ja': '波形生成中', 'ko': '파형 생성 중',
    'fr': 'Génération de forme d\'onde', 'de': 'Wellenform wird erstellt', 'es': 'Generando forma de onda', 'ru': 'Генерация волновой формы',
    'pt': 'Gerando forma de onda', 'th': 'กำลังสร้างรูปคลื่น',
  });
  String get switchAndPlay => _t(const {
    'zh': '切换后立即播放', 'zh_TW': '切換後立即播放', 'en': 'Switch and play', 'ja': '切り替えて即再生', 'ko': '전환 후 즉시 재생',
    'fr': 'Changer et lire', 'de': 'Wechseln und abspielen', 'es': 'Cambiar y reproducir', 'ru': 'Переключить и воспроизвести',
    'pt': 'Trocar e reproduzir', 'th': 'สลับแล้วเล่นทันที',
  });
  String get selected => _t(const {
    'zh': '已选中', 'zh_TW': '已選取', 'en': 'Selected', 'ja': '選択済み', 'ko': '선택됨',
    'fr': 'Sélectionné', 'de': 'Ausgewählt', 'es': 'Seleccionado', 'ru': 'Выбрано',
    'pt': 'Selecionado', 'th': 'เลือกแล้ว',
  });
  String get notSelected => _t(const {
    'zh': '未选中', 'zh_TW': '未選取', 'en': 'Not selected', 'ja': '未選択', 'ko': '미선택',
    'fr': 'Non sélectionné', 'de': 'Nicht ausgewählt', 'es': 'No seleccionado', 'ru': 'Не выбрано',
    'pt': 'Não selecionado', 'th': 'ยังไม่เลือก',
  });

  // ============ 声波卡片 ============
  String get waveformPreview => _t(const {
    'zh': '声音波形示意', 'zh_TW': '聲音波形示意', 'en': 'Waveform Preview', 'ja': '波形プレビュー', 'ko': '파형 미리보기',
    'fr': 'Aperçu de forme d\'onde', 'de': 'Wellenformvorschau', 'es': 'Vista previa de forma de onda', 'ru': 'Предпросмотр волновой формы',
    'pt': 'Visualização de forma de onda', 'th': 'ดูตัวอย่างรูปคลื่น',
  });
  String get output => _t(const {
    'zh': '输出', 'zh_TW': '輸出', 'en': 'Output', 'ja': '出力', 'ko': '출력',
    'fr': 'Sortie', 'de': 'Ausgabe', 'es': 'Salida', 'ru': 'Выход',
    'pt': 'Saída', 'th': 'เอาต์พุต',
  });
  String get freq => _t(const {
    'zh': '频率', 'zh_TW': '頻率', 'en': 'Freq', 'ja': '周波数', 'ko': '주파수',
    'fr': 'Fréq', 'de': 'Freq', 'es': 'Frec', 'ru': 'Частота',
    'pt': 'Freq', 'th': 'ความถี่',
  });
  String get intensity => _t(const {
    'zh': '强度', 'zh_TW': '強度', 'en': 'Intensity', 'ja': '強度', 'ko': '강도',
    'fr': 'Intensité', 'de': 'Intensität', 'es': 'Intensidad', 'ru': 'Интенсивность',
    'pt': 'Intensidade', 'th': 'ความเข้ม',
  });
  String get shape => _t(const {
    'zh': '形态', 'zh_TW': '形態', 'en': 'Shape', 'ja': '形状', 'ko': '형태',
    'fr': 'Forme', 'de': 'Form', 'es': 'Forma', 'ru': 'Форма',
    'pt': 'Forma', 'th': 'รูปร่าง',
  });
  String get intensitySoft => _t(const {
    'zh': '轻柔', 'zh_TW': '輕柔', 'en': 'Soft', 'ja': 'ソフト', 'ko': '부드러움',
    'fr': 'Doux', 'de': 'Leise', 'es': 'Suave', 'ru': 'Мягкая',
    'pt': 'Suave', 'th': 'เบา',
  });
  String get intensityBalanced => _t(const {
    'zh': '适中', 'zh_TW': '適中', 'en': 'Balanced', 'ja': 'バランス', 'ko': '균형',
    'fr': 'Équilibré', 'de': 'Ausgeglichen', 'es': 'Equilibrado', 'ru': 'Сбалансированная',
    'pt': 'Equilibrado', 'th': 'สมดุล',
  });
  String get intensityStrong => _t(const {
    'zh': '明显', 'zh_TW': '明顯', 'en': 'Strong', 'ja': 'ストロング', 'ko': '강함',
    'fr': 'Fort', 'de': 'Stark', 'es': 'Fuerte', 'ru': 'Сильная',
    'pt': 'Forte', 'th': 'แรง',
  });
  String get intensityPowerful => _t(const {
    'zh': '强烈', 'zh_TW': '強烈', 'en': 'Powerful', 'ja': 'パワフル', 'ko': '매우 강함',
    'fr': 'Puissant', 'de': 'Kraftvoll', 'es': 'Potente', 'ru': 'Мощная',
    'pt': 'Poderoso', 'th': 'ทรงพลัง',
  });
  String get toneBassLed => _t(const {
    'zh': '低频主导', 'zh_TW': '低頻主導', 'en': 'Bass-led', 'ja': '低域主導', 'ko': '저역 중심',
    'fr': 'Graves dominants', 'de': 'Bass-lastig', 'es': 'Graves dominantes', 'ru': 'Низкие частоты',
    'pt': 'Graves dominantes', 'th': 'เบสนำ',
  });
  String get toneMidBalanced => _t(const {
    'zh': '中频均衡', 'zh_TW': '中頻均衡', 'en': 'Mid-balanced', 'ja': '中域バランス', 'ko': '중역 균형',
    'fr': 'Médiums équilibrés', 'de': 'Mitten-ausgeglichen', 'es': 'Medios equilibrados', 'ru': 'Сбалансированные средние',
    'pt': 'Médios equilibrados', 'th': 'กลางสมดุล',
  });
  String get toneTrebleClear => _t(const {
    'zh': '高频清晰', 'zh_TW': '高頻清晰', 'en': 'Treble-clear', 'ja': '高域クリア', 'ko': '고역 명료',
    'fr': 'Aigus clairs', 'de': 'Höhen-klar', 'es': 'Agudos claros', 'ru': 'Чистые высокие',
    'pt': 'Agudos claros', 'th': 'สูงชัด',
  });
  String get toneUltraHigh => _t(const {
    'zh': '超高频', 'zh_TW': '超高頻', 'en': 'Ultra-high', 'ja': '超高域', 'ko': '초고역',
    'fr': 'Ultra-aigus', 'de': 'Ultra-hoch', 'es': 'Ultra-agudos', 'ru': 'Ультравысокие',
    'pt': 'Ultra-agudos', 'th': 'อัลตราสูง',
  });
  String get waveformPlayingDesc => _t(const {
    'zh': '播放中波形会持续起伏，便于感知当前声音的强弱变化。',
    'zh_TW': '播放中波形會持續起伏，便於感知當前聲音的強弱變化。',
    'en': 'Wave motion stays active during playback so the output feels easier to read.',
    'ja': '再生中は波形が変動し、音の強さの変化を感じやすくなります。',
    'ko': '재생 중 파형이 계속 변하여 소리의 강도 변화를 쉽게 느낄 수 있습니다.',
    'fr': 'Le mouvement de l\'onde reste actif pendant la lecture pour une lecture plus facile.',
    'de': 'Wellenbewegung bleibt während der Wiedergabe aktiv zur besseren Ablesbarkeit.',
    'es': 'El movimiento de onda permanece activo durante la reproducción para facilitar la lectura.',
    'ru': 'Волновое движение остаётся активным во время воспроизведения для удобства чтения.',
    'pt': 'O movimento da onda permanece ativo durante a reprodução para facilitar a leitura.',
    'th': 'คลื่นเคลื่อนไหวตลอดการเล่นเพื่อให้อ่านง่ายขึ้น',
  });
  String get waveformStaticDesc => _t(const {
    'zh': '未播放时展示静态声波轮廓，播放后会变成动态效果。',
    'zh_TW': '未播放時展示靜態聲波輪廓，播放後會變成動態效果。',
    'en': 'The preview stays static when idle and animates during playback.',
    'ja': '停止中は静的波形を表示し、再生時にアニメーションします。',
    'ko': '미재생 시 정적 파형을 표시하고, 재생 시 애니메이션으로 전환됩니다.',
    'fr': 'L\'aperçu reste statique au repos et s\'anime pendant la lecture.',
    'de': 'Die Vorschau bleibt im Leerlauf statisch und animiert während der Wiedergabe.',
    'es': 'La vista previa permanece estática en reposo y se anima durante la reproducción.',
    'ru': 'Предпросмотр статичен в покое и анимируется при воспроизведении.',
    'pt': 'A visualização permanece estática em repouso e anima durante a reprodução.',
    'th': 'ตัวอย่างอยู่นิ่งเมื่อไม่เล่น และเคลื่อนไหวเมื่อเล่น',
  });

  // ============ 手表页面补充 ============
  String get watchRemoteFeature => _t(const {
    'zh': '手表遥控功能', 'zh_TW': '手錶遙控功能', 'en': 'Watch Remote', 'ja': '時計リモート機能', 'ko': '워치 리모컨 기능',
    'fr': 'Télécommande montre', 'de': 'Uhr-Fernbedienung', 'es': 'Control remoto del reloj', 'ru': 'Дистанционное управление часами',
    'pt': 'Controle remoto do relógio', 'th': 'รีโมตนาฬิกา',
  });
  String get remotePlayDesc => _t(const {
    'zh': '在手表上选择并播放声音', 'zh_TW': '在手錶上選擇並播放聲音', 'en': 'Select and play sounds on watch', 'ja': '時計で音声を選択して再生', 'ko': '워치에서 소리 선택 및 재생',
    'fr': 'Sélectionner et lire des sons sur la montre', 'de': 'Sounds auf der Uhr auswählen und abspielen', 'es': 'Seleccionar y reproducir sonidos en el reloj', 'ru': 'Выбирайте и воспроизводите звуки на часах',
    'pt': 'Selecionar e reproduzir sons no relógio', 'th': 'เลือกและเล่นเสียงบนนาฬิกา',
  });
String get emergencyBtnDesc => _t(const {
'zh': '一键播放最大音量驱赶声', 'zh_TW': '一鍵播放最大音量驅趕聲', 'en': 'Play max volume repelling sound instantly', 'ja': 'ワンタップで最大音量の追い払い音再生', 'ko': '원터치 최대 볼륨 퇴치 소리 재생',
'fr': 'Son de répulsion au volume maximum en un clic', 'de': 'Vertreibungston mit maximaler Lautstärke auf Knopfdruck', 'es': 'Sonido de repulsión a volumen máximo con un toque', 'ru': 'Мгновенный звук отпугивания на максимальной громкости',
'pt': 'Som de repulsão de volume máximo com um toque', 'th': 'เล่นเสียงไล่เสียงดังสุดทันที',
});
  String get hapticFeedbackDesc => _t(const {
    'zh': '播放时手表振动提醒', 'zh_TW': '播放時手錶振動提醒', 'en': 'Watch vibrates during playback', 'ja': '再生中に時計が振動で知らせる', 'ko': '재생 중 워치 진동 알림',
    'fr': 'La montre vibre pendant la lecture', 'de': 'Uhr vibriert während der Wiedergabe', 'es': 'El reloj vibra durante la reproducción', 'ru': 'Часы вибрируют при воспроизведении',
    'pt': 'Relógio vibra durante a reprodução', 'th': 'นาฬิกาสั่นขณะเล่น',
  });
  String get watchConnectedHint => _t(const {
    'zh': '可以通过手表遥控播放', 'zh_TW': '可以透過手錶遙控播放', 'en': 'Control playback from your watch', 'ja': '時計から再生をコントロールできます', 'ko': '워치에서 재생을 제어할 수 있습니다',
    'fr': 'Contrôlez la lecture depuis la montre', 'de': 'Steuerung der Wiedergabe von der Uhr', 'es': 'Controle la reproducción desde el reloj', 'ru': 'Управляйте воспроизведением с часов',
    'pt': 'Controle a reprodução do relógio', 'th': 'ควบคุมการเล่นจากนาฬิกา',
  });
  String get watchDisconnectedHint => _t(const {
    'zh': '请确保手表已配对并靠近手机', 'zh_TW': '請確保手錶已配對並靠近手機', 'en': 'Make sure watch is paired and near phone', 'ja': '時計がペアリングされ、スマホの近くにあることを確認してください', 'ko': '워치가 페어링되어 스마트폰 근처에 있는지 확인하세요',
    'fr': 'Assurez-vous que la montre est appairée et proche du téléphone', 'de': 'Stellen Sie sicher, dass die Uhr gekoppelt und in der Nähe ist', 'es': 'Asegúrese de que el reloj esté emparejado y cerca del teléfono', 'ru': 'Убедитесь, что часы сопряжены и находятся рядом с телефоном',
    'pt': 'Certifique-se de que o relógio está emparelhado e próximo ao telefone', 'th': 'ตรวจสอบว่านาฬิกาจับคู่แล้วและอยู่ใกล้โทรศัพท์',
  });
  String get communicationLog => _t(const {
    'zh': '通信日志', 'zh_TW': '通訊日誌', 'en': 'Communication Log', 'ja': '通信ログ', 'ko': '통신 로그',
    'fr': 'Journal de communication', 'de': 'Kommunikationsprotokoll', 'es': 'Registro de comunicación', 'ru': 'Журнал связи',
    'pt': 'Registro de comunicação', 'th': 'บันทึกการสื่อสาร',
  });
  String get rescanWatchFull => _t(const {
    'zh': '重新搜索手表', 'zh_TW': '重新搜尋手錶', 'en': 'Rescan for Watch', 'ja': '時計を再スキャン', 'ko': '워치 다시 검색',
    'fr': 'Rechercher la montre', 'de': 'Uhr erneut suchen', 'es': 'Buscar reloj de nuevo', 'ru': 'Повторный поиск часов',
    'pt': 'Escanear relógio novamente', 'th': 'ค้นหานาฬิกาอีกครั้ง',
  });

  // ============ 定时器页面补充 ============
  String get customDuration => _t(const {
    'zh': '自定义时长', 'zh_TW': '自訂時長', 'en': 'Custom Duration', 'ja': 'カスタム時間', 'ko': '사용자 지정 시간',
    'fr': 'Durée personnalisée', 'de': 'Benutzerdefinierte Dauer', 'es': 'Duración personalizada', 'ru': 'Пользовательская длительность',
    'pt': 'Duração personalizada', 'th': 'ระยะเวลาที่กำหนดเอง',
  });

  // ============ 音量提示 ============
  String get volumeLowTitle => _t(const {
    'zh': '音量偏低', 'zh_TW': '音量偏低', 'en': 'Volume Low', 'ja': '音量が低い', 'ko': '볼륨이 낮음',
    'fr': 'Volume bas', 'de': 'Lautstärke niedrig', 'es': 'Volumen bajo', 'ru': 'Низкая громкость',
    'pt': 'Volume baixo', 'th': 'ระดับเสียงต่ำ',
  });
    String get volumeLowHint => _t(const {
    'zh': '当前音量可能无法有效驱赶，建议调高音量或连接外接扬声器',
    'zh_TW': '當前音量可能無法有效驅趕，建議調高音量或連接外接喇叭',
    'en': 'Current volume may not be effective. Try turning it up or using an external speaker.',
    'ja': '現在の音量では効果が不十分な可能性があります。音量を上げるか外部スピーカーをご使用ください。',
    'ko': '현재 볼륨으로는 효과가 부족할 수 있습니다. 볼륨을 높이거나 외부 스피커를 사용하세요.',
    'fr': 'Le volume actuel peut être insuffisant. Augmentez-le ou utilisez un haut-parleur externe.',
    'de': 'Aktuelle Lautstärke könnte unwirksam sein. Erhöhen Sie sie oder nutzen Sie einen externen Lautsprecher.',
    'es': 'El volumen actual puede ser insuficiente. Súbelo o use un altavoz externo.',
    'ru': 'Текущая громкость может быть недостаточной. Увеличьте её или используйте внешнюю колонку.',
    'pt': 'O volume atual pode ser insuficiente. Aumente-o ou use um alto-falante externo.',
    'th': 'ระดับเสียงอาจไม่เพียงพอ ลองเพิ่มเสียงหรือใช้ลำโพงภายนอก',
  });
  String get volumeRampingUp => _t(const {
    'zh': '正在逐步提升音量…', 'zh_TW': '正在逐步提升音量…', 'en': 'Gradually increasing volume…', 'ja': '音量を徐々に上げています…',
    'ko': '볼륨을 점진적으로 높이는 중…', 'fr': 'Augmentation progressive du volume…',
    'de': 'Lautstärke wird schrittweise erhöht…', 'es': 'Aumentando volumen gradualmente…',
    'ru': 'Постепенное увеличение громкости…', 'pt': 'Aumentando volume gradualmente…',
    'th': 'กำลังเพิ่มระดับเสียงทีละน้อย…',
  });
  String get turnUpVolume => _t(const {
    'zh': '调高音量', 'zh_TW': '調高音量', 'en': 'Turn Up', 'ja': '音量を上げる', 'ko': '볼륨 올리기',
    'fr': 'Augmenter', 'de': 'Erhöhen', 'es': 'Subir', 'ru': 'Увеличить',
    'pt': 'Aumentar', 'th': 'เพิ่มเสียง',
  });
  String get playing => _t(const {
    'zh': '播放中', 'zh_TW': '播放中', 'en': 'Playing', 'ja': '再生中', 'ko': '재생 중',
    'fr': 'En lecture', 'de': 'Wird abgespielt', 'es': 'Reproduciendo', 'ru': 'Воспроизведение',
    'pt': 'Reproduzindo', 'th': 'กำลังเล่น',
  });
  String get dismiss => _t(const {
    'zh': '知道了', 'zh_TW': '知道了', 'en': 'Got it', 'ja': '了解', 'ko': '알겠습니다',
    'fr': 'Compris', 'de': 'Verstanden', 'es': 'Entendido', 'ru': 'Понятно',
    'pt': 'Entendi', 'th': 'เข้าใจแล้ว',
  });
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) {
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return S.supportedLanguageCodes.contains('zh_TW');
    }
    return S.supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<S> old) => false;
}
