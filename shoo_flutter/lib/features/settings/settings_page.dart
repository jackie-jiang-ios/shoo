import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../app.dart';
import '../../core/storage/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late String _themeMode;
  late String _language;
  late double _defaultVolume;
  late bool _keepScreenOn;
  late int _autoStopMinutes;
  late double _loopIntervalSeconds;

  @override
  void initState() {
    super.initState();
    _themeMode = prefs.themeMode;
    _language = prefs.language;
    _defaultVolume = prefs.defaultVolume;
    _keepScreenOn = prefs.keepScreenOn;
    _autoStopMinutes = prefs.autoStopMinutes;
    _loopIntervalSeconds = prefs.intervalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 外观
          _SectionHeader(title: s.appearance),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(s.themeMode),
                  trailing: DropdownButton<String>(
                    value: _themeMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(s.followSystem)),
                      DropdownMenuItem(value: 'light', child: Text(s.lightMode)),
                      DropdownMenuItem(value: 'dark', child: Text(s.darkMode)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _themeMode = value);
                        prefs.themeMode = value;
                        ref.read(themeModeProvider.notifier).state = resolveThemeMode(value);
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(s.language),
                  trailing: DropdownButton<String>(
                    value: _language,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(s.followSystem)),
                      ...S.nativeLanguageNames.entries.map((entry) =>
                        DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _language = value);
                        prefs.language = value;
                        ref.read(localeProvider.notifier).state = resolveLocale(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 播放设置
          _SectionHeader(title: s.playback),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: Text(s.defaultVolume),
                  subtitle: Text('${(_defaultVolume * 100).round()}%'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: _defaultVolume,
                    onChanged: (value) {
                      setState(() => _defaultVolume = value);
                      prefs.defaultVolume = value;
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.screen_lock_portrait),
                  title: Text(s.keepScreenOn),
                  value: _keepScreenOn,
                  onChanged: (value) {
                    setState(() => _keepScreenOn = value);
                    prefs.keepScreenOn = value;
                    if (value) {
                      WakelockPlus.enable();
                    } else {
                      WakelockPlus.disable();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(s.loopInterval),
                  subtitle: _loopIntervalSeconds > 0
                          ? Text('${_loopIntervalSeconds.toStringAsFixed(1)} ${s.seconds}')
                          : Text(s.noInterval),
                  trailing: DropdownButton<double>(
                    value: _loopIntervalSeconds,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(s.noInterval)),
                      DropdownMenuItem(value: 1.0, child: Text('1 ${s.seconds}')),
                      DropdownMenuItem(value: 2.0, child: Text('2 ${s.seconds}')),
                      DropdownMenuItem(value: 3.0, child: Text('3 ${s.seconds}')),
                      DropdownMenuItem(value: 5.0, child: Text('5 ${s.seconds}')),
                      DropdownMenuItem(value: 8.0, child: Text('8 ${s.seconds}')),
                      DropdownMenuItem(value: 10.0, child: Text('10 ${s.seconds}')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _loopIntervalSeconds = value);
                        prefs.intervalSeconds = value;
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text(s.autoStop),
                  trailing: DropdownButton<int>(
                    value: _autoStopMinutes,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(s.noAutoStop)),
                      DropdownMenuItem(value: 5, child: Text('5 ${s.minutes}')),
                      DropdownMenuItem(value: 10, child: Text('10 ${s.minutes}')),
                      DropdownMenuItem(value: 15, child: Text('15 ${s.minutes}')),
                      DropdownMenuItem(value: 30, child: Text('30 ${s.minutes}')),
                      DropdownMenuItem(value: 60, child: Text('1 ${s.hours}')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _autoStopMinutes = value);
                        prefs.autoStopMinutes = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 关于
          _SectionHeader(title: s.about),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(s.version),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: Text(s.appName),
                  subtitle: Text(s.appSubtitle),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(s.rateUs),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 跳转 App Store 评分页面
                    launchUrl(
                      Uri.parse(
                        'https://apps.apple.com/app/id6779087767?action=write-review',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: Text(s.feedback),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 打开反馈页面（邮件反馈）
                    launchUrl(
                      Uri.parse('mailto:13036101641@163.com'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 法律条款
          _SectionHeader(title: s.legal),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(s.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(
                      'webview',
                      extra: {
                        'url': 'https://liteapps.cn/shoo/terms',
                        'title': s.termsOfService,
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(s.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(
                      'webview',
                      extra: {
                        'url': 'https://liteapps.cn/shoo/privacy',
                        'title': s.privacyPolicy,
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// 分节标题
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.of(context),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
