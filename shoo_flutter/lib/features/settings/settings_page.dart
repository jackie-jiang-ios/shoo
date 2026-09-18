import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../app.dart';
import '../../core/platform/share_channel.dart';
import '../../core/storage/preferences.dart';
import '../../core/purchase/purchase_manager.dart';
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
  String _version = '';

  @override
  void initState() {
    super.initState();
    _themeMode = prefs.themeMode;
    _language = prefs.language;
    _defaultVolume = prefs.defaultVolume;
    _keepScreenOn = prefs.keepScreenOn;
    _autoStopMinutes = prefs.autoStopMinutes;
    _loopIntervalSeconds = prefs.intervalSeconds;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    }
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() => _themeMode = value);
                      prefs.themeMode = value;
                      ref.read(themeModeProvider.notifier).state = resolveThemeMode(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'system', child: Text(s.followSystem)),
                      PopupMenuItem(value: 'light', child: Text(s.lightMode)),
                      PopupMenuItem(value: 'dark', child: Text(s.darkMode)),
                    ],
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _themeMode == 'system'
                              ? s.followSystem
                              : _themeMode == 'light'
                                  ? s.lightMode
                                  : s.darkMode,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, size: 22),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(s.language),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _language == 'system'
                            ? s.followSystem
                            : S.nativeLanguageNames[_language] ?? _language,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    ],
                  ),
                  onTap: () async {
                    await context.push('/language-select');
                    if (mounted) setState(() => _language = prefs.language);
                  },
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
                  trailing: PopupMenuButton<double>(
                    onSelected: (value) {
                      setState(() => _loopIntervalSeconds = value);
                      prefs.intervalSeconds = value;
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 0, child: Text(s.noInterval)),
                      PopupMenuItem(value: 1.0, child: Text('1 ${s.seconds}')),
                      PopupMenuItem(value: 2.0, child: Text('2 ${s.seconds}')),
                      PopupMenuItem(value: 3.0, child: Text('3 ${s.seconds}')),
                      PopupMenuItem(value: 5.0, child: Text('5 ${s.seconds}')),
                      PopupMenuItem(value: 8.0, child: Text('8 ${s.seconds}')),
                      PopupMenuItem(value: 10.0, child: Text('10 ${s.seconds}')),
                    ],
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _loopIntervalSeconds == 0
                              ? s.noInterval
                              : '${_loopIntervalSeconds.toStringAsFixed(1)} ${s.seconds}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, size: 22),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text(s.autoStop),
                  trailing: PopupMenuButton<int>(
                    onSelected: (value) {
                      setState(() => _autoStopMinutes = value);
                      prefs.autoStopMinutes = value;
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 0, child: Text(s.noAutoStop)),
                      PopupMenuItem(value: 5, child: Text('5 ${s.minutes}')),
                      PopupMenuItem(value: 10, child: Text('10 ${s.minutes}')),
                      PopupMenuItem(value: 15, child: Text('15 ${s.minutes}')),
                      PopupMenuItem(value: 30, child: Text('30 ${s.minutes}')),
                      PopupMenuItem(value: 60, child: Text('1 ${s.hours}')),
                    ],
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _autoStopMinutes == 0
                              ? s.noAutoStop
                              : _autoStopMinutes == 60
                                  ? '1 ${s.hours}'
                                  : '${_autoStopMinutes} ${s.minutes}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, size: 22),
                      ],
                    ),
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
                  trailing: Text(_version),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: Text(s.appName),
                  subtitle: Text(s.appSubtitle),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(s.shareApp),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ShareChannel.shareApp(
                      'https://apps.apple.com/app/id6779087767',
                      'Check out Shoo - Animal Repellent App!',
                    );
                  },
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
                  leading: const Icon(Icons.restore),
                  title: Text(s.restorePurchases),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final success = await PurchaseManager.instance.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? s.restoreSuccess : s.restoreFailed)),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.grid_view),
                  title: Text(s.moreProducts),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(
                      'webview',
                      extra: {
                        'url': 'https://liteapps.cn/#products',
                        'title': s.moreProducts,
                      },
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
