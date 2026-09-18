import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/screenshot/screenshot_helper.dart';
import 'core/storage/preferences.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/language_select_page.dart';
import 'features/settings/web_view_page.dart';
import 'features/paywall/paywall_page.dart';
import 'features/splash/splash_page.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// 主题模式 Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// 语言 Provider
final localeProvider = StateProvider<Locale?>((ref) => null);

/// GoRouter Provider - 让 test 能直接控制导航
final goRouterProvider = StateProvider<GoRouter?>((ref) => null);

/// 根据 prefs.language 值解析 Locale
/// 'system' -> null (跟随系统)
/// 其他 -> 对应的 Locale
Locale? resolveLocale(String languageCode) {
  if (languageCode == 'system') return null;
  // 带国家码的特殊处理
  if (languageCode.contains('_')) {
    final parts = languageCode.split('_');
    final lc = parts[0];
    final cc = parts[1];
    try {
      return S.supportedLocales.firstWhere(
        (locale) => locale.languageCode == lc && locale.countryCode == cc,
      );
    } catch (_) {
      return null;
    }
  }
  // 在 supportedLocales 中查找匹配的语言代码
  try {
    return S.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
    );
  } catch (_) {
    return null; // 未找到则跟随系统
  }
}

/// 根据 prefs.themeMode 值解析 ThemeMode
ThemeMode resolveThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

/// 从 Preferences 初始化 Provider 状态（在 main() 中调用）
void initProvidersFromPrefs(ProviderContainer container) {
  container.read(themeModeProvider.notifier).state = resolveThemeMode(prefs.themeMode);
  container.read(localeProvider.notifier).state = resolveLocale(prefs.language);
}

/// 路由配置
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/', name: 'home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsPage()),
    GoRoute(
      path: '/language-select',
      name: 'language-select',
      builder: (context, state) => const LanguageSelectPage(),
    ),
    GoRoute(
      path: '/webview',
      name: 'webview',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return WebViewPage(
          url: extra['url'] ?? '',
          title: extra['title'] ?? '',
        );
      },
    ),
    GoRoute(path: '/paywall', name: 'paywall', builder: (context, state) => const PaywallPage()),
  ],
);

/// 截图模式下需要显示的页面（通过 UserDefaults 从原生代码传递）
String? _screenshotPage;

/// 检查是否在截图模式下
bool get _isScreenshotMode {
  return _screenshotPage != null;
}

/// 从原生代码获取截图配置
Future<void> _initScreenshotMode() async {
  const channel = MethodChannel('com.shoo.app/platform');
  try {
    final page = await channel.invokeMethod<String>('getScreenshotPage');
    if (page != null && page.isNotEmpty) {
      _screenshotPage = page;
    }
  } catch (_) {
    // 不在截图模式或通道不可用
  }
}

/// 应用根组件
class ShooApp extends ConsumerStatefulWidget {
  const ShooApp({super.key});

  @override
  ConsumerState<ShooApp> createState() => _ShooAppState();
}

class _ShooAppState extends ConsumerState<ShooApp> {
  late GoRouter _dynamicRouter;

  @override
  void initState() {
    super.initState();
    _dynamicRouter = _router;
    // 暴露 GoRouter 给 test 使用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goRouterProvider.notifier).state = _dynamicRouter;
    });
    // 初始化截图模式并设置页面
    _initScreenshotMode().then((_) {
      if (_isScreenshotMode && mounted) {
        // 根据截图页面导航
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToScreenshotPage();
        });
      }
    });
  }

  void _navigateToScreenshotPage() {
    switch (_screenshotPage) {
      case 'settings':
        _dynamicRouter.go('/settings');
        break;
      case 'paywall':
        _dynamicRouter.go('/paywall');
        break;
      case 'home':
      default:
        _dynamicRouter.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return RepaintBoundary(
      key: ScreenshotHelper.repaintBoundaryKey,
      child: MaterialApp.router(
        key: ValueKey("app_locale_$locale"),
        onGenerateTitle: (context) => S.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: S.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        routerConfig: _dynamicRouter,
      ),
    );
  }
}
