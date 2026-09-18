// Generated file. Do not edit.
// ignore_for_file: lines_longer_than_80_chars, avoid_dynamic_calls
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('en', 'AU'),
    Locale('en', 'CA'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('es', 'MX'),
    Locale('fi'),
    Locale('fr'),
    Locale('fr', 'CA'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nl'),
    Locale('no'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Animal Repellent'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sound-powered safety'**
  String get appSubtitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @smartRecommend.
  ///
  /// In en, this message translates to:
  /// **'Smart Tips'**
  String get smartRecommend;

  /// No description provided for @smartRecommendHint.
  ///
  /// In en, this message translates to:
  /// **'Suggested now: Snake/Boar'**
  String get smartRecommendHint;

  /// No description provided for @counterSound.
  ///
  /// In en, this message translates to:
  /// **'Counter Sound'**
  String get counterSound;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detail;

  /// No description provided for @recommendedSounds.
  ///
  /// In en, this message translates to:
  /// **'Recommended Sounds'**
  String get recommendedSounds;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @noSoundPlaying.
  ///
  /// In en, this message translates to:
  /// **'Tap an animal to start'**
  String get noSoundPlaying;

  /// No description provided for @startScaring.
  ///
  /// In en, this message translates to:
  /// **'Start Scaring'**
  String get startScaring;

  /// No description provided for @stopScaring.
  ///
  /// In en, this message translates to:
  /// **'Stop Scaring'**
  String get stopScaring;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @beastCategory.
  ///
  /// In en, this message translates to:
  /// **'Beasts'**
  String get beastCategory;

  /// No description provided for @reptileCategory.
  ///
  /// In en, this message translates to:
  /// **'Reptiles'**
  String get reptileCategory;

  /// No description provided for @primateCategory.
  ///
  /// In en, this message translates to:
  /// **'Primates'**
  String get primateCategory;

  /// No description provided for @rodentCategory.
  ///
  /// In en, this message translates to:
  /// **'Rodents'**
  String get rodentCategory;

  /// No description provided for @insectCategory.
  ///
  /// In en, this message translates to:
  /// **'Insects'**
  String get insectCategory;

  /// No description provided for @birdCategory.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get birdCategory;

  /// No description provided for @wildDog.
  ///
  /// In en, this message translates to:
  /// **'Wild Dog'**
  String get wildDog;

  /// No description provided for @snake.
  ///
  /// In en, this message translates to:
  /// **'Venomous Snake'**
  String get snake;

  /// No description provided for @wildBoar.
  ///
  /// In en, this message translates to:
  /// **'Wild Boar'**
  String get wildBoar;

  /// No description provided for @bear.
  ///
  /// In en, this message translates to:
  /// **'Bear'**
  String get bear;

  /// No description provided for @monkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get monkey;

  /// No description provided for @mouse.
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get mouse;

  /// No description provided for @wolf.
  ///
  /// In en, this message translates to:
  /// **'Wolf'**
  String get wolf;

  /// No description provided for @spider.
  ///
  /// In en, this message translates to:
  /// **'Venomous Spider'**
  String get spider;

  /// No description provided for @wasp.
  ///
  /// In en, this message translates to:
  /// **'Wasp'**
  String get wasp;

  /// No description provided for @rabbit.
  ///
  /// In en, this message translates to:
  /// **'Wild Rabbit'**
  String get rabbit;

  /// No description provided for @crow.
  ///
  /// In en, this message translates to:
  /// **'Crow'**
  String get crow;

  /// No description provided for @fox.
  ///
  /// In en, this message translates to:
  /// **'Fox'**
  String get fox;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @playMode.
  ///
  /// In en, this message translates to:
  /// **'Play Mode'**
  String get playMode;

  /// No description provided for @continuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get continuous;

  /// No description provided for @intervalPlay.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalPlay;

  /// No description provided for @intervalTime.
  ///
  /// In en, this message translates to:
  /// **'Interval Time'**
  String get intervalTime;

  /// No description provided for @soundMix.
  ///
  /// In en, this message translates to:
  /// **'Sound Mix'**
  String get soundMix;

  /// No description provided for @addSound.
  ///
  /// In en, this message translates to:
  /// **'Add Sound'**
  String get addSound;

  /// No description provided for @startMix.
  ///
  /// In en, this message translates to:
  /// **'Start Mix'**
  String get startMix;

  /// No description provided for @stopMix.
  ///
  /// In en, this message translates to:
  /// **'Stop Mix'**
  String get stopMix;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @setTimer.
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get setTimer;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get selectDuration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hours;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get seconds;

  /// No description provided for @noInterval.
  ///
  /// In en, this message translates to:
  /// **'No interval'**
  String get noInterval;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimer;

  /// No description provided for @cancelTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTimer;

  /// No description provided for @timerFinished.
  ///
  /// In en, this message translates to:
  /// **'Timer done, stopped'**
  String get timerFinished;

  /// No description provided for @noAutoStop.
  ///
  /// In en, this message translates to:
  /// **'No auto stop'**
  String get noAutoStop;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @defaultVolume.
  ///
  /// In en, this message translates to:
  /// **'Default Volume'**
  String get defaultVolume;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get keepScreenOn;

  /// No description provided for @autoStop.
  ///
  /// In en, this message translates to:
  /// **'Auto Stop'**
  String get autoStop;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareApp;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @soundLibrary.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get soundLibrary;

  /// No description provided for @ultrasonic.
  ///
  /// In en, this message translates to:
  /// **'Ultrasonic'**
  String get ultrasonic;

  /// No description provided for @animalDeterrent.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get animalDeterrent;

  /// No description provided for @firecracker.
  ///
  /// In en, this message translates to:
  /// **'Firecracker'**
  String get firecracker;

  /// No description provided for @alarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @metalImpact.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get metalImpact;

  /// No description provided for @targetAnimal.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetAnimal;

  /// No description provided for @frequencyRange.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyRange;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get navSounds;

  /// No description provided for @navMix.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get navMix;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @iconStyle.
  ///
  /// In en, this message translates to:
  /// **'Icon Style'**
  String get iconStyle;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @sequence.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get sequence;

  /// No description provided for @selectSound.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectSound;

  /// No description provided for @singleLoop.
  ///
  /// In en, this message translates to:
  /// **'Single loop'**
  String get singleLoop;

  /// No description provided for @sequenceLoop.
  ///
  /// In en, this message translates to:
  /// **'Multi loop'**
  String get sequenceLoop;

  /// No description provided for @nFiles.
  ///
  /// In en, this message translates to:
  /// **' files'**
  String get nFiles;

  /// No description provided for @singleFile.
  ///
  /// In en, this message translates to:
  /// **'Single file'**
  String get singleFile;

  /// No description provided for @sequenceLoopDesc.
  ///
  /// In en, this message translates to:
  /// **'Selected files play in order on loop, then start over.'**
  String get sequenceLoopDesc;

  /// No description provided for @loopInterval.
  ///
  /// In en, this message translates to:
  /// **'Loop Interval'**
  String get loopInterval;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get closed;

  /// No description provided for @tapToPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview sounds'**
  String get tapToPreview;

  /// No description provided for @audioFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get audioFile;

  /// No description provided for @generatingWaveform.
  ///
  /// In en, this message translates to:
  /// **'Generating waveform'**
  String get generatingWaveform;

  /// No description provided for @switchAndPlay.
  ///
  /// In en, this message translates to:
  /// **'Switch and play'**
  String get switchAndPlay;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @waveformPreview.
  ///
  /// In en, this message translates to:
  /// **'Waveform Preview'**
  String get waveformPreview;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @freq.
  ///
  /// In en, this message translates to:
  /// **'Freq'**
  String get freq;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @shape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// No description provided for @intensitySoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get intensitySoft;

  /// No description provided for @intensityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get intensityBalanced;

  /// No description provided for @intensityStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get intensityStrong;

  /// No description provided for @intensityPowerful.
  ///
  /// In en, this message translates to:
  /// **'Powerful'**
  String get intensityPowerful;

  /// No description provided for @toneBassLed.
  ///
  /// In en, this message translates to:
  /// **'Bass-led'**
  String get toneBassLed;

  /// No description provided for @toneMidBalanced.
  ///
  /// In en, this message translates to:
  /// **'Mid-balanced'**
  String get toneMidBalanced;

  /// No description provided for @toneTrebleClear.
  ///
  /// In en, this message translates to:
  /// **'Treble-clear'**
  String get toneTrebleClear;

  /// No description provided for @toneUltraHigh.
  ///
  /// In en, this message translates to:
  /// **'Ultra-high'**
  String get toneUltraHigh;

  /// No description provided for @waveformPlayingDesc.
  ///
  /// In en, this message translates to:
  /// **'Wave motion stays active during playback so the output feels easier to read.'**
  String get waveformPlayingDesc;

  /// No description provided for @waveformStaticDesc.
  ///
  /// In en, this message translates to:
  /// **'The preview stays static when idle and animates during playback.'**
  String get waveformStaticDesc;

  /// No description provided for @customDuration.
  ///
  /// In en, this message translates to:
  /// **'Custom Duration'**
  String get customDuration;

  /// No description provided for @volumeLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume Low'**
  String get volumeLowTitle;

  /// No description provided for @volumeLowHint.
  ///
  /// In en, this message translates to:
  /// **'Current volume may not be effective. Try turning it up or using an external speaker.'**
  String get volumeLowHint;

  /// No description provided for @volumeRampingUp.
  ///
  /// In en, this message translates to:
  /// **'Gradually increasing volume…'**
  String get volumeRampingUp;

  /// No description provided for @turnUpVolume.
  ///
  /// In en, this message translates to:
  /// **'Turn Up'**
  String get turnUpVolume;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @shooPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get shooPro;

  /// No description provided for @unlockAllAnimals.
  ///
  /// In en, this message translates to:
  /// **'Unlock all animal sounds'**
  String get unlockAllAnimals;

  /// No description provided for @freeAnimals.
  ///
  /// In en, this message translates to:
  /// **'Free animals'**
  String get freeAnimals;

  /// No description provided for @freeAnimalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Wild dog'**
  String get freeAnimalsDesc;

  /// No description provided for @proAnimals.
  ///
  /// In en, this message translates to:
  /// **'All animals'**
  String get proAnimals;

  /// No description provided for @proAnimalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Boar, Bear, Wolf, Fox, Monkey, Rabbit, Spider, Wasp and more'**
  String get proAnimalsDesc;

  /// No description provided for @allFeatures.
  ///
  /// In en, this message translates to:
  /// **'All features'**
  String get allFeatures;

  /// No description provided for @allFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'Sound mixing, timer, interval playback'**
  String get allFeaturesDesc;

  /// No description provided for @futureUpdates.
  ///
  /// In en, this message translates to:
  /// **'Future updates'**
  String get futureUpdates;

  /// No description provided for @futureUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'New animals and features included'**
  String get futureUpdatesDesc;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase, yours forever'**
  String get oneTimePurchase;

  /// No description provided for @defaultPrice.
  ///
  /// In en, this message translates to:
  /// **'\\\$0.99'**
  String get defaultPrice;

  /// No description provided for @unlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro'**
  String get unlockPro;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @purchaseSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Secure payment via App Store'**
  String get purchaseSecureNote;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! All animals unlocked'**
  String get purchaseSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful!'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore'**
  String get restoreFailed;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get dismiss;

  /// No description provided for @moreProducts.
  ///
  /// In en, this message translates to:
  /// **'More Products'**
  String get moreProducts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'ca',
        'cs',
        'da',
        'de',
        'el',
        'en',
        'es',
        'fi',
        'fr',
        'gu',
        'he',
        'hi',
        'hr',
        'hu',
        'id',
        'it',
        'ja',
        'kn',
        'ko',
        'ml',
        'mr',
        'ms',
        'nl',
        'no',
        'or',
        'pa',
        'pl',
        'pt',
        'ro',
        'ru',
        'sk',
        'sl',
        'sv',
        'ta',
        'te',
        'th',
        'tr',
        'uk',
        'ur',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'AU':
            return AppLocalizationsEnAu();
          case 'CA':
            return AppLocalizationsEnCa();
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'MX':
            return AppLocalizationsEsMx();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'CA':
            return AppLocalizationsFrCa();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
