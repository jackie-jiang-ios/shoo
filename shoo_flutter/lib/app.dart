import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';
import 'features/splash/splash_page.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// 主题模式 Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// 语言 Provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('zh', 'CN'));

/// 路由配置
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/', name: 'home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsPage()),
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
      title: '防兽神器',
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

