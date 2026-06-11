import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/storage/preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _themeMode = prefs.themeMode;
    _language = prefs.language;
    _defaultVolume = prefs.defaultVolume;
    _keepScreenOn = prefs.keepScreenOn;
    _autoStopMinutes = prefs.autoStopMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 外观
          _SectionHeader(title: '外观'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('主题模式'),
                  trailing: DropdownButton<String>(
                    value: _themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                      DropdownMenuItem(value: 'light', child: Text('浅色')),
                      DropdownMenuItem(value: 'dark', child: Text('深色')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _themeMode = value);
                        prefs.themeMode = value;
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _language = value);
                        prefs.language = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 播放设置
          _SectionHeader(title: '播放'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('默认音量'),
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
                  title: const Text('播放时保持屏幕常亮'),
                  subtitle: const Text('防止播放中断'),
                  value: _keepScreenOn,
                  onChanged: (value) {
                    setState(() => _keepScreenOn = value);
                    prefs.keepScreenOn = value;
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('自动停止'),
                  trailing: DropdownButton<int>(
                    value: _autoStopMinutes,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('不自动停止')),
                      DropdownMenuItem(value: 5, child: Text('5 分钟')),
                      DropdownMenuItem(value: 10, child: Text('10 分钟')),
                      DropdownMenuItem(value: 15, child: Text('15 分钟')),
                      DropdownMenuItem(value: 30, child: Text('30 分钟')),
                      DropdownMenuItem(value: 60, child: Text('1 小时')),
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
          _SectionHeader(title: '关于'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('版本'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: const Text('防兽神器'),
                  subtitle: const Text('用声音守护你的安全'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('给我们评分'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 跳转应用商店评分
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text('意见反馈'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 打开反馈页面
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 法律条款
          _SectionHeader(title: '法律条款'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('用户服务协议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://liteapps.cn/shoo/terms'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://liteapps.cn/shoo/privacy'),
                      mode: LaunchMode.externalApplication,
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
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
