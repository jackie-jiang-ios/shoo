import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/purchase/purchase_manager.dart';

/// 截图模式页面 - 用于 App Store 截图
/// 当检测到截图模式激活时，显示指定的页面
class ScreenshotModePage extends StatefulWidget {
  final String page;
  const ScreenshotModePage({super.key, this.page = 'home'});

  @override
  State<ScreenshotModePage> createState() => _ScreenshotModePageState();
}

class _ScreenshotModePageState extends State<ScreenshotModePage> {
  static const _channel = MethodChannel('com.shoo.app/purchase');

  @override
  void initState() {
    super.initState();
    // 确保 Pro 状态
    _forceProStatus();
  }

  Future<void> _forceProStatus() async {
    try {
      await _channel.invokeMethod('enableScreenshotMode');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // 直接导航到指定页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (widget.page) {
        case 'settings':
          context.go('/settings');
          break;
        case 'mixer':
          context.go('/');
          break;
        case 'paywall':
          context.go('/paywall');
          break;
        default:
          context.go('/');
      }
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
