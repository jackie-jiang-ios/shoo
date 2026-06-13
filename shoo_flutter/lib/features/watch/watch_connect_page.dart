import 'package:flutter/material.dart';
import '../../core/platform/watch_channel.dart';
import '../../l10n/app_localizations.dart';
import '../../models/watch_command.dart';
import '../../theme/colors.dart';

/// 手表连接页面
class WatchConnectPage extends StatefulWidget {
  const WatchConnectPage({super.key});

  @override
  State<WatchConnectPage> createState() => _WatchConnectPageState();
}

class _WatchConnectPageState extends State<WatchConnectPage> {
  bool _isConnected = false;
  bool _isChecking = false;
  final List<PhoneCommand> _watchLogs = [];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _listenToWatchEvents();
  }

  Future<void> _checkConnection() async {
    setState(() => _isChecking = true);
    final connected = await WatchChannel.isWatchConnected();
    setState(() {
      _isConnected = connected;
      _isChecking = false;
    });
  }

  void _listenToWatchEvents() {
    WatchChannel.watchEventStream.listen(
      (command) {
        if (mounted) {
          setState(() {
            _watchLogs.insert(0, command);
            if (_watchLogs.length > 20) _watchLogs.removeLast();
          });
        }
      },
      onError: (error) {
        // 手表未连接或其他错误
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.watchConnect),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConnection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 连接状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 状态图标
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? AppColors.successOf(context).withValues(alpha: 0.1)
                            : AppColors.textHintOf(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _isChecking
                          ? const CircularProgressIndicator()
                          : Icon(
                              _isConnected ? Icons.watch : Icons.watch_outlined,
                              size: 32,
                              color: _isConnected
                                  ? AppColors.successOf(context)
                                  : AppColors.textHintOf(context),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected ? s.watchConnected : s.watchDisconnected,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isConnected
                                ? s.watchConnectedHint
                                : s.watchDisconnectedHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 连接状态指示灯
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isConnected ? AppColors.successOf(context) : AppColors.textHintOf(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 功能说明
            Text(
              s.watchRemoteFeature,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _FeatureItem(
              icon: Icons.play_circle_outline,
              title: s.remotePlay,
              description: s.remotePlayDesc,
              enabled: _isConnected,
            ),
            _FeatureItem(
              icon: Icons.emergency,
              title: s.emergencyBtn,
              description: s.emergencyBtnDesc,
              enabled: _isConnected,
            ),
            _FeatureItem(
              icon: Icons.vibration,
              title: s.hapticFeedback,
              description: s.hapticFeedbackDesc,
              enabled: _isConnected,
            ),

            const SizedBox(height: 24),

            // 通信日志
            if (_watchLogs.isNotEmpty) ...[
              Text(
                s.communicationLog,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _watchLogs.length,
                  itemBuilder: (context, index) {
                    final cmd = _watchLogs[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.arrow_back, size: 16),
                      title: Text(cmd.type, style: const TextStyle(fontSize: 12)),
                      subtitle: Text(
                        cmd.toJson().toString(),
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ],

            const Spacer(),

            // 配对按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkConnection,
                icon: const Icon(Icons.bluetooth),
                label: Text(s.rescanWatchFull),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 功能项
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.of(context) : AppColors.textHintOf(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? null : AppColors.textHintOf(context),
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryOf(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
