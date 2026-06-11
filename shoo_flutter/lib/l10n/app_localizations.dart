import 'package:flutter/widgets.dart';

/// 应用国际化支持 - 完整中英双语
class S {
  final Locale locale;

  S(this.locale);

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  bool get isZh => locale.languageCode == 'zh';

  String _t(String zh, String en) => isZh ? zh : en;

  // ============ 通用 ============
  String get appName => _t('防兽神器', 'Shoo');
  String get appSubtitle => _t('用声音守护你的安全', 'Sound-powered safety');
  String get confirm => _t('确认', 'Confirm');
  String get cancel => _t('取消', 'Cancel');
  String get close => _t('关闭', 'Close');
  String get done => _t('完成', 'Done');
  String get play => _t('播放', 'Play');
  String get stop => _t('停止', 'Stop');
  String get pause => _t('暂停', 'Pause');
  String get loading => _t('加载中...', 'Loading...');
  String get retry => _t('重试', 'Retry');

  // ============ 首页 ============
  String get smartRecommend => _t('智能推荐', 'Smart Tips');
  String get smartRecommendHint => _t('当前时段建议：防蛇/野猪', 'Suggested now: Snake/Boar');
  String get counterSound => _t('克制声音', 'Counter Sound');
  String get detail => _t('详情', 'Details');
  String get recommendedSounds => _t('推荐声音', 'Recommended Sounds');
  String get nowPlaying => _t('正在播放', 'Now Playing');
  String get noSoundPlaying => _t('点击动物开始驱赶', 'Tap an animal to start');
  String get startScaring => _t('开始驱赶', 'Start Scaring');
  String get stopScaring => _t('停止驱赶', 'Stop Scaring');

  // ============ 分类 ============
  String get allCategories => _t('全部', 'All');
  String get beastCategory => _t('猛兽威胁', 'Beasts');
  String get reptileCategory => _t('爬行类', 'Reptiles');
  String get primateCategory => _t('灵长类', 'Primates');
  String get rodentCategory => _t('啮齿类', 'Rodents');
  String get insectCategory => _t('昆虫类', 'Insects');
  String get birdCategory => _t('鸟类', 'Birds');

  // ============ 动物名称 ============
  String get wildDog => _t('野狗', 'Wild Dog');
  String get snake => _t('毒蛇', 'Venomous Snake');
  String get wildBoar => _t('野猪', 'Wild Boar');
  String get bear => _t('熊', 'Bear');
  String get monkey => _t('猴子', 'Monkey');
  String get mouse => _t('老鼠', 'Mouse');
  String get wolf => _t('狼', 'Wolf');
  String get spider => _t('毒蜘蛛', 'Venomous Spider');
  String get wasp => _t('马蜂', 'Wasp');
  String get rabbit => _t('野兔', 'Wild Rabbit');
  String get crow => _t('乌鸦', 'Crow');
  String get fox => _t('狐狸', 'Fox');

  // ============ 播放器 ============
  String get volume => _t('音量', 'Volume');
  String get playMode => _t('播放模式', 'Play Mode');
  String get continuous => _t('持续播放', 'Continuous');
  String get intervalPlay => _t('间隔播放', 'Interval');
  String get pulsePlay => _t('脉冲播放', 'Pulse');
  String get intervalTime => _t('间隔时间', 'Interval Time');
  String get pulseDuration => _t('脉冲持续', 'Pulse Duration');
  String get pulseGap => _t('脉冲间隔', 'Pulse Gap');

  // ============ 混合器 ============
  String get soundMix => _t('声音混合', 'Sound Mix');
  String get addSound => _t('添加声音', 'Add Sound');
  String get startMix => _t('开始混合', 'Start Mix');
  String get stopMix => _t('停止混合', 'Stop Mix');

  // ============ 定时器 ============
  String get timer => _t('定时播放', 'Timer');
  String get setTimer => _t('设置定时', 'Set Timer');
  String get selectDuration => _t('选择时长', 'Duration');
  String get minutes => _t('分钟', 'min');
  String get hours => _t('小时', 'hr');
  String get startTimer => _t('开始定时', 'Start');
  String get cancelTimer => _t('取消定时', 'Cancel');
  String get timerFinished => _t('定时结束，已停止播放', 'Timer done, stopped');
  String get noAutoStop => _t('不自动停止', 'No auto stop');

  // ============ 手表 ============
  String get watchConnect => _t('手表连接', 'Watch');
  String get watchConnected => _t('手表已连接', 'Watch Connected');
  String get watchDisconnected => _t('未检测到手表', 'No Watch');
  String get remotePlay => _t('遥控播放', 'Remote Play');
  String get emergencyBtn => _t('紧急按钮', 'Emergency');
  String get hapticFeedback => _t('触觉反馈', 'Haptic');
  String get rescanWatch => _t('重新搜索', 'Rescan');

  // ============ 设置 ============
  String get settings => _t('设置', 'Settings');
  String get appearance => _t('外观', 'Appearance');
  String get themeMode => _t('主题模式', 'Theme');
  String get followSystem => _t('跟随系统', 'System');
  String get lightMode => _t('浅色', 'Light');
  String get darkMode => _t('深色', 'Dark');
  String get language => _t('语言', 'Language');
  String get defaultVolume => _t('默认音量', 'Default Volume');
  String get keepScreenOn => _t('保持屏幕常亮', 'Keep Screen On');
  String get autoStop => _t('自动停止', 'Auto Stop');
  String get about => _t('关于', 'About');
  String get version => _t('版本', 'Version');
  String get rateUs => _t('给我们评分', 'Rate Us');
  String get feedback => _t('意见反馈', 'Feedback');

  // ============ 声音库 ============
  String get soundLibrary => _t('声音库', 'Sounds');
  String get ultrasonic => _t('超声波', 'Ultrasonic');
  String get animalDeterrent => _t('动物威慑', 'Animal');
  String get firecracker => _t('炮仗', 'Firecracker');
  String get alarm => _t('警报', 'Alarm');
  String get metalImpact => _t('金属撞击', 'Metal');
  String get targetAnimal => _t('驱赶目标', 'Target');
  String get frequencyRange => _t('频率范围', 'Frequency');

  // ============ 底部导航 ============
  String get navHome => _t('首页', 'Home');
  String get navSounds => _t('声音', 'Sounds');
  String get navMix => _t('混合', 'Mix');
  String get navTimer => _t('定时', 'Timer');
  String get navWatch => _t('手表', 'Watch');
  String get navSettings => _t('设置', 'Settings');
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<S> old) => false;
}
