import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/animal.dart';

/// 全局偏好存储实例（在 main() 中初始化）
late final Preferences prefs;

/// 本地偏好存储
///
/// 使用 SharedPreferences 存储简单偏好设置，
/// Hive 存储收藏声音和混合预设等结构化数据。
class Preferences {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyDefaultVolume = 'default_volume';
  static const String _keyDefaultPlayMode = 'default_play_mode';
  static const String _keyIntervalSeconds = 'interval_seconds';
  static const String _keyPulseDuration = 'pulse_duration';
  static const String _keyPulseGap = 'pulse_gap';
  static const String _keyAutoStopMinutes = 'auto_stop_minutes';
  static const String _keyKeepScreenOn = 'keep_screen_on';
  static const String _keyFavorites = 'favorites';
  static const String _keyMixPresets = 'mix_presets';
  static const String _keyVolumeMode = 'volume_mode';
  static const String _keyAnimalCustomVolumes = 'animal_custom_volumes';
  static const String _keyIconTheme = 'icon_theme';
  static const String _keyAnimalIconThemes = 'animal_icon_themes';
  static const String _keyAnimalSoundSelections = 'animal_sound_selections';

  late SharedPreferences _prefs;
  late Box _favoritesBox;
  late Box _presetsBox;

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _favoritesBox = await Hive.openBox('favorites');
    _presetsBox = await Hive.openBox('mix_presets');
  }

  // ============ 主题 ============

  /// 获取主题模式 (light / dark / system)
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  set themeMode(String value) => _prefs.setString(_keyThemeMode, value);

  // ============ 语言 ============

  /// 获取语言 (zh / en / system)
  String get language => _prefs.getString(_keyLanguage) ?? 'system';
  set language(String value) => _prefs.setString(_keyLanguage, value);

  // ============ 默认播放设置 ============

  /// 默认音量
  double get defaultVolume => _prefs.getDouble(_keyDefaultVolume) ?? 0.8;
  set defaultVolume(double value) => _prefs.setDouble(_keyDefaultVolume, value);

  /// 默认播放模式
  String get defaultPlayMode => _prefs.getString(_keyDefaultPlayMode) ?? 'continuous';
  set defaultPlayMode(String value) => _prefs.setString(_keyDefaultPlayMode, value);

  /// 间隔播放间隔秒数
  double get intervalSeconds => _prefs.getDouble(_keyIntervalSeconds) ?? 3.0;
  set intervalSeconds(double value) => _prefs.setDouble(_keyIntervalSeconds, value);

  /// 脉冲持续时间
  double get pulseDuration => _prefs.getDouble(_keyPulseDuration) ?? 0.5;
  set pulseDuration(double value) => _prefs.setDouble(_keyPulseDuration, value);

  /// 脉冲间隔时间
  double get pulseGap => _prefs.getDouble(_keyPulseGap) ?? 1.0;
  set pulseGap(double value) => _prefs.setDouble(_keyPulseGap, value);

  /// 自动停止分钟数 (0 = 不自动停止)
  int get autoStopMinutes => _prefs.getInt(_keyAutoStopMinutes) ?? 0;
  set autoStopMinutes(int value) => _prefs.setInt(_keyAutoStopMinutes, value);

  // ============ 音量模式 ============

  /// 音量模式（通用/独立）
  String get volumeMode => _prefs.getString(_keyVolumeMode) ?? 'global';
  set volumeMode(String value) => _prefs.setString(_keyVolumeMode, value);

  /// 获取指定动物的自定义音量
  /// 如果没有设置过，返回动物的推荐音量
  double getAnimalVolume(String animalId) {
    final volumes = _getAnimalCustomVolumes();
    return volumes[animalId] ?? _getRecommendedVolume(animalId);
  }

  /// 设置指定动物的自定义音量
  Future<void> setAnimalVolume(String animalId, double volume) async {
    final volumes = _getAnimalCustomVolumes();
    volumes[animalId] = volume;
    await _prefs.setString(_keyAnimalCustomVolumes, jsonEncode(volumes));
  }

  /// 获取所有动物的自定义音量映射
  Map<String, double> _getAnimalCustomVolumes() {
    final str = _prefs.getString(_keyAnimalCustomVolumes);
    if (str == null) return {};
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  /// 获取动物推荐音量（从数据库）
  double _getRecommendedVolume(String animalId) {
    final animal = AnimalDatabase.findById(animalId);
    return animal?.recommendedVolume ?? 0.8;
  }

  /// 重置指定动物音量为推荐值
  Future<void> resetAnimalVolume(String animalId) async {
    final volumes = _getAnimalCustomVolumes();
    volumes.remove(animalId);
    await _prefs.setString(_keyAnimalCustomVolumes, jsonEncode(volumes));
  }

  /// 重置所有动物音量为推荐值
  Future<void> resetAllAnimalVolumes() async {
    await _prefs.remove(_keyAnimalCustomVolumes);
  }

  // ============ 图标主题 ============

  /// 获取全局图标主题 (v1 / v2 / v3)
  String get iconTheme => _prefs.getString(_keyIconTheme) ?? 'v3';
  set iconTheme(String value) => _prefs.setString(_keyIconTheme, value);

  // ============ 动物图标主题偏好 ============

  /// 获取指定动物的图标主题 (v1 / v2 / v3)
  /// 如果没有设置过，返回全局图标主题
  String getAnimalIconTheme(String animalId) {
    final themes = _getAnimalIconThemes();
    return themes[animalId] ?? iconTheme;
  }

  /// 设置指定动物的图标主题
  Future<void> setAnimalIconTheme(String animalId, String themeId) async {
    final themes = _getAnimalIconThemes();
    themes[animalId] = themeId;
    await _prefs.setString(_keyAnimalIconThemes, jsonEncode(themes));
  }

  /// 获取所有动物的图标主题映射
  Map<String, String> _getAnimalIconThemes() {
    final str = _prefs.getString(_keyAnimalIconThemes);
    if (str == null) return {};
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  // ============ 动物声音选择偏好 ============

  /// 声音选择数据结构: { animalId: { "selectedSoundIndex": int, "soundPlayModes": { "soundGroup": "single"|"sequence" }, "soundSelectedIndices": { "soundGroup": int } } }
  /// 获取指定动物的声音选择偏好
  Map<String, dynamic> getAnimalSoundSelection(String animalId) {
    final all = _getAnimalSoundSelections();
    return all[animalId] ?? {};
  }

  /// 设置指定动物的声音选择偏好
  Future<void> setAnimalSoundSelection(String animalId, Map<String, dynamic> selection) async {
    final all = _getAnimalSoundSelections();
    all[animalId] = selection;
    await _prefs.setString(_keyAnimalSoundSelections, jsonEncode(all));
  }

  /// 获取指定动物的选中声音索引
  int getAnimalSelectedSoundIndex(String animalId) {
    final selection = getAnimalSoundSelection(animalId);
    return selection['selectedSoundIndex'] as int? ?? 0;
  }

  /// 设置指定动物的选中声音索引
  Future<void> setAnimalSelectedSoundIndex(String animalId, int index) async {
    final selection = getAnimalSoundSelection(animalId);
    selection['selectedSoundIndex'] = index;
    await setAnimalSoundSelection(animalId, selection);
  }

  /// 获取指定动物指定声音组的播放模式
  String getAnimalSoundPlayMode(String animalId, String soundGroup) {
    final selection = getAnimalSoundSelection(animalId);
    final modes = selection['soundPlayModes'] as Map<String, dynamic>? ?? {};
    return modes[soundGroup]?.toString() ?? 'single';
  }

  /// 设置指定动物指定声音组的播放模式
  Future<void> setAnimalSoundPlayMode(String animalId, String soundGroup, String mode) async {
    final selection = getAnimalSoundSelection(animalId);
    final modes = (selection['soundPlayModes'] as Map<String, dynamic>?) ?? {};
    modes[soundGroup] = mode;
    selection['soundPlayModes'] = modes;
    await setAnimalSoundSelection(animalId, selection);
  }

  /// 获取指定动物指定声音组的选中声音索引
  int getAnimalSoundSelectedIndex(String animalId, String soundGroup) {
    final selection = getAnimalSoundSelection(animalId);
    final indices = selection['soundSelectedIndices'] as Map<String, dynamic>? ?? {};
    return indices[soundGroup] as int? ?? 0;
  }

  /// 设置指定动物指定声音组的选中声音索引
  Future<void> setAnimalSoundSelectedIndex(String animalId, String soundGroup, int index) async {
    final selection = getAnimalSoundSelection(animalId);
    final indices = (selection['soundSelectedIndices'] as Map<String, dynamic>?) ?? {};
    indices[soundGroup] = index;
    selection['soundSelectedIndices'] = indices;
    await setAnimalSoundSelection(animalId, selection);
  }

  /// 获取所有动物的声音选择偏好
  Map<String, dynamic> _getAnimalSoundSelections() {
    final str = _prefs.getString(_keyAnimalSoundSelections);
    if (str == null) return {};
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ============ 屏幕常亮 ============

  /// 是否保持屏幕常亮
  bool get keepScreenOn => _prefs.getBool(_keyKeepScreenOn) ?? true;
  set keepScreenOn(bool value) => _prefs.setBool(_keyKeepScreenOn, value);

  // ============ 收藏 ============

  /// 获取收藏声音 ID 列表
  List<String> get favoriteSoundIds =>
      _favoritesBox.get(_keyFavorites, defaultValue: <String>[])?.cast<String>() ?? [];

  /// 添加收藏
  Future<void> addFavorite(String soundId) async {
    final favorites = favoriteSoundIds;
    if (!favorites.contains(soundId)) {
      favorites.add(soundId);
      await _favoritesBox.put(_keyFavorites, favorites);
    }
  }

  /// 移除收藏
  Future<void> removeFavorite(String soundId) async {
    final favorites = favoriteSoundIds;
    favorites.remove(soundId);
    await _favoritesBox.put(_keyFavorites, favorites);
  }

  /// 是否已收藏
  bool isFavorite(String soundId) => favoriteSoundIds.contains(soundId);

  /// 切换收藏状态
  Future<void> toggleFavorite(String soundId) async {
    if (isFavorite(soundId)) {
      await removeFavorite(soundId);
    } else {
      await addFavorite(soundId);
    }
  }

  // ============ 混合预设 ============

  /// 获取所有预设
  Map<String, dynamic> get mixPresets =>
      _presetsBox.get(_keyMixPresets, defaultValue: <String, dynamic>{}) ?? {};

  /// 保存预设
  Future<void> saveMixPreset(String name, Map<String, dynamic> preset) async {
    final presets = mixPresets;
    presets[name] = preset;
    await _presetsBox.put(_keyMixPresets, presets);
  }

  /// 删除预设
  Future<void> deleteMixPreset(String name) async {
    final presets = mixPresets;
    presets.remove(name);
    await _presetsBox.put(_keyMixPresets, presets);
  }
}
