import 'dart:async' show Future;
import 'package:flutter/widgets.dart';
import 'generated/app_localizations.dart';

/// i18n 兼容层 - 委托给 Flutter 从 ARB 生成的 AppLocalizations
/// 对外保持 S.of(context).xxx 接口不变
class S {
  final AppLocalizations _l10n;

  S(this._l10n);

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
    Locale('ar', 'SA'),
    Locale('id', 'ID'),
    Locale('it', 'IT'),
    Locale('ms', 'MY'),
    Locale('nl', 'NL'),
    Locale('pl', 'PL'),
    Locale('tr', 'TR'),
    Locale('vi', 'VN'),
    Locale('hi'),
    Locale('da'),
    Locale('fr', 'CA'),
    Locale('fi'),
    Locale('gu'),
    Locale('ca'),
    Locale('cs'),
    Locale('kn'),
    Locale('hr'),
    Locale('ro'),
    Locale('mr'),
    Locale('ml'),
    Locale('bn'),
    Locale('no'),
    Locale('pa'),
    Locale('sv'),
    Locale('sk'),
    Locale('sl'),
    Locale('te'),
    Locale('ta'),
    Locale('ur'),
    Locale('uk'),
    Locale('es', 'MX'),
    Locale('he'),
    Locale('el'),
    Locale('hu'),
    Locale('en', 'AU'),
    Locale('en', 'CA'),
    Locale('en', 'GB'),
    Locale('or'),
  ];

  static const List<String> supportedLanguageCodes = [
    'zh', 'zh_TW', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'ru', 'pt', 'th',
    'ar', 'id', 'it', 'ms', 'nl', 'pl', 'tr', 'vi',
    'hi', 'da', 'fr_CA', 'fi', 'gu', 'ca', 'cs', 'kn', 'hr', 'ro',
    'mr', 'ml', 'bn', 'no', 'pa', 'sv', 'sk', 'sl', 'te', 'ta',
    'ur', 'uk', 'es_MX', 'he', 'el', 'hu', 'en_AU', 'en_CA', 'en_GB', 'or',
  ];

  /// 语言代码对应的本地语言名称
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
    'ar': 'العربية',
    'id': 'Bahasa Indonesia',
    'it': 'Italiano',
    'ms': 'Bahasa Melayu',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'tr': 'Türkçe',
    'vi': 'Tiếng Việt',
    'hi': 'हिन्दी',
    'da': 'Dansk',
    'fr_CA': 'Français (Canada)',
    'fi': 'Suomi',
    'gu': 'ગુજરાતી',
    'ca': 'Català',
    'cs': 'Čeština',
    'kn': 'ಕನ್ನಡ',
    'hr': 'Hrvatski',
    'ro': 'Română',
    'mr': 'मराठी',
    'ml': 'മലയാളം',
    'bn': 'বাংলা',
    'no': 'Norsk',
    'pa': 'ਪੰਜਾਬੀ',
    'sv': 'Svenska',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'te': 'తెలుగు',
    'ta': 'தமிழ்',
    'ur': 'اردو',
    'uk': 'Українська',
    'es_MX': 'Español (México)',
    'he': 'עברית',
    'el': 'Ελληνικά',
    'hu': 'Magyar',
    'en_AU': 'English (Australia)',
    'en_CA': 'English (Canada)',
    'en_GB': 'English (UK)',
    'or': 'ଓଡ଼ିଆ',
  };

  // ============ 翻译 key 委托（共 167 个）============
  String get appName => _l10n.appName;
  String get appSubtitle => _l10n.appSubtitle;
  String get confirm => _l10n.confirm;
  String get cancel => _l10n.cancel;
  String get close => _l10n.close;
  String get done => _l10n.done;
  String get play => _l10n.play;
  String get stop => _l10n.stop;
  String get pause => _l10n.pause;
  String get loading => _l10n.loading;
  String get retry => _l10n.retry;
  String get smartRecommend => _l10n.smartRecommend;
  String get smartRecommendHint => _l10n.smartRecommendHint;
  String get counterSound => _l10n.counterSound;
  String get detail => _l10n.detail;
  String get recommendedSounds => _l10n.recommendedSounds;
  String get nowPlaying => _l10n.nowPlaying;
  String get noSoundPlaying => _l10n.noSoundPlaying;
  String get startScaring => _l10n.startScaring;
  String get stopScaring => _l10n.stopScaring;
  String get allCategories => _l10n.allCategories;
  String get beastCategory => _l10n.beastCategory;
  String get reptileCategory => _l10n.reptileCategory;
  String get primateCategory => _l10n.primateCategory;
  String get rodentCategory => _l10n.rodentCategory;
  String get insectCategory => _l10n.insectCategory;
  String get birdCategory => _l10n.birdCategory;
  String get wildDog => _l10n.wildDog;
  String get snake => _l10n.snake;
  String get wildBoar => _l10n.wildBoar;
  String get bear => _l10n.bear;
  String get monkey => _l10n.monkey;
  String get mouse => _l10n.mouse;
  String get wolf => _l10n.wolf;
  String get spider => _l10n.spider;
  String get wasp => _l10n.wasp;
  String get rabbit => _l10n.rabbit;
  String get crow => _l10n.crow;
  String get fox => _l10n.fox;
  String get volume => _l10n.volume;
  String get playMode => _l10n.playMode;
  String get continuous => _l10n.continuous;
  String get intervalPlay => _l10n.intervalPlay;
  String get intervalTime => _l10n.intervalTime;
  String get soundMix => _l10n.soundMix;
  String get addSound => _l10n.addSound;
  String get startMix => _l10n.startMix;
  String get stopMix => _l10n.stopMix;
  String get timer => _l10n.timer;
  String get setTimer => _l10n.setTimer;
  String get selectDuration => _l10n.selectDuration;
  String get minutes => _l10n.minutes;
  String get hours => _l10n.hours;
  String get seconds => _l10n.seconds;
  String get noInterval => _l10n.noInterval;
  String get startTimer => _l10n.startTimer;
  String get cancelTimer => _l10n.cancelTimer;
  String get timerFinished => _l10n.timerFinished;
  String get noAutoStop => _l10n.noAutoStop;
  String get settings => _l10n.settings;
  String get appearance => _l10n.appearance;
  String get themeMode => _l10n.themeMode;
  String get followSystem => _l10n.followSystem;
  String get lightMode => _l10n.lightMode;
  String get darkMode => _l10n.darkMode;
  String get language => _l10n.language;
  String get defaultVolume => _l10n.defaultVolume;
  String get keepScreenOn => _l10n.keepScreenOn;
  String get autoStop => _l10n.autoStop;
  String get about => _l10n.about;
  String get version => _l10n.version;
  String get shareApp => _l10n.shareApp;
  String get rateUs => _l10n.rateUs;
  String get feedback => _l10n.feedback;
  String get legal => _l10n.legal;
  String get termsOfService => _l10n.termsOfService;
  String get privacyPolicy => _l10n.privacyPolicy;
  String get playback => _l10n.playback;
  String get soundLibrary => _l10n.soundLibrary;
  String get ultrasonic => _l10n.ultrasonic;
  String get animalDeterrent => _l10n.animalDeterrent;
  String get firecracker => _l10n.firecracker;
  String get alarm => _l10n.alarm;
  String get metalImpact => _l10n.metalImpact;
  String get targetAnimal => _l10n.targetAnimal;
  String get frequencyRange => _l10n.frequencyRange;
  String get navHome => _l10n.navHome;
  String get navSounds => _l10n.navSounds;
  String get navMix => _l10n.navMix;
  String get navTimer => _l10n.navTimer;
  String get navSettings => _l10n.navSettings;
  String get iconStyle => _l10n.iconStyle;
  String get mode => _l10n.mode;
  String get single => _l10n.single;
  String get sequence => _l10n.sequence;
  String get selectSound => _l10n.selectSound;
  String get singleLoop => _l10n.singleLoop;
  String get sequenceLoop => _l10n.sequenceLoop;
  String get nFiles => _l10n.nFiles;
  String get singleFile => _l10n.singleFile;
  String get sequenceLoopDesc => _l10n.sequenceLoopDesc;
  String get loopInterval => _l10n.loopInterval;
  String get closed => _l10n.closed;
  String get tapToPreview => _l10n.tapToPreview;
  String get audioFile => _l10n.audioFile;
  String get generatingWaveform => _l10n.generatingWaveform;
  String get switchAndPlay => _l10n.switchAndPlay;
  String get selected => _l10n.selected;
  String get notSelected => _l10n.notSelected;
  String get waveformPreview => _l10n.waveformPreview;
  String get output => _l10n.output;
  String get freq => _l10n.freq;
  String get intensity => _l10n.intensity;
  String get shape => _l10n.shape;
  String get intensitySoft => _l10n.intensitySoft;
  String get intensityBalanced => _l10n.intensityBalanced;
  String get intensityStrong => _l10n.intensityStrong;
  String get intensityPowerful => _l10n.intensityPowerful;
  String get toneBassLed => _l10n.toneBassLed;
  String get toneMidBalanced => _l10n.toneMidBalanced;
  String get toneTrebleClear => _l10n.toneTrebleClear;
  String get toneUltraHigh => _l10n.toneUltraHigh;
  String get waveformPlayingDesc => _l10n.waveformPlayingDesc;
  String get waveformStaticDesc => _l10n.waveformStaticDesc;
  String get customDuration => _l10n.customDuration;
  String get volumeLowTitle => _l10n.volumeLowTitle;
  String get volumeLowHint => _l10n.volumeLowHint;
  String get volumeRampingUp => _l10n.volumeRampingUp;
  String get turnUpVolume => _l10n.turnUpVolume;
  String get playing => _l10n.playing;
  String get upgradeToPro => _l10n.upgradeToPro;
  String get shooPro => _l10n.shooPro;
  String get unlockAllAnimals => _l10n.unlockAllAnimals;
  String get freeAnimals => _l10n.freeAnimals;
  String get freeAnimalsDesc => _l10n.freeAnimalsDesc;
  String get proAnimals => _l10n.proAnimals;
  String get proAnimalsDesc => _l10n.proAnimalsDesc;
  String get allFeatures => _l10n.allFeatures;
  String get allFeaturesDesc => _l10n.allFeaturesDesc;
  String get futureUpdates => _l10n.futureUpdates;
  String get futureUpdatesDesc => _l10n.futureUpdatesDesc;
  String get oneTimePurchase => _l10n.oneTimePurchase;
  String get defaultPrice => _l10n.defaultPrice;
  String get unlockPro => _l10n.unlockPro;
  String get restorePurchases => _l10n.restorePurchases;
  String get purchaseSecureNote => _l10n.purchaseSecureNote;
  String get purchaseSuccess => _l10n.purchaseSuccess;
  String get restoreSuccess => _l10n.restoreSuccess;
  String get restoreFailed => _l10n.restoreFailed;
  String get pro => _l10n.pro;
  String get dismiss => _l10n.dismiss;
  String get moreProducts => _l10n.moreProducts;
}

/// Delegate：加载 AppLocalizations 并包装为 S
class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    return S(l10n);
  }

  @override
  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_SDelegate old) => false;
}
