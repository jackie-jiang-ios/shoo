import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/storage/preferences.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/web_view_page.dart';
import 'features/splash/splash_page.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// 主题模式 Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// 语言 Provider
final localeProvider = StateProvider<Locale?>((ref) => null);

/// 根据 prefs.language 值解析 Locale
/// 'system' -> null (跟随系统)
/// 其他 -> 对应的 Locale
Locale? resolveLocale(String languageCode) {
  if (languageCode == 'system') return null;
  // zh_TW 特殊处理：需要同时匹配 languageCode 和 countryCode
  if (languageCode == 'zh_TW') {
    try {
      return S.supportedLocales.firstWhere(
        (locale) => locale.languageCode == 'zh' && locale.countryCode == 'TW',
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
  ],
);

/// 应用根组件
class ShooApp extends ConsumerWidget {
  const ShooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Shoo',
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
      routerConfig: _router,
    );
  }
}
