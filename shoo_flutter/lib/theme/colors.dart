import 'package:flutter/material.dart';

/// 根据亮度选择颜色
Color _colorByBrightness(BuildContext context, Color light, Color dark) {
  return Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// 应用色彩系统 - 便捷访问方法，自动适配深色模式
class AppColors {
  AppColors._();

  /// 根据 context 亮度自动选择颜色
  static Color of(BuildContext context) => _colorByBrightness(context, const Color(0xFFF97316), const Color(0xFFFB923C));
  static Color backgroundOf(BuildContext context) => _colorByBrightness(context, background, AppColorsDark.background);
  static Color cardBackgroundOf(BuildContext context) => _colorByBrightness(context, cardBackground, AppColorsDark.cardBackground);
  static Color dividerOf(BuildContext context) => _colorByBrightness(context, divider, AppColorsDark.divider);
  static Color textPrimaryOf(BuildContext context) => _colorByBrightness(context, textPrimary, AppColorsDark.textPrimary);
  static Color textSecondaryOf(BuildContext context) => _colorByBrightness(context, textSecondary, AppColorsDark.textSecondary);
  static Color textHintOf(BuildContext context) => _colorByBrightness(context, textHint, AppColorsDark.textHint);
  static Color dangerOf(BuildContext context) => _colorByBrightness(context, danger, AppColorsDark.danger);
  static Color successOf(BuildContext context) => _colorByBrightness(context, success, AppColorsDark.success);

  // ============ 主色调 ============
  /// 主色 - 橘色
  static const Color primary = Color(0xFFF97316);

  /// 主色浅
  static const Color primaryLight = Color(0xFFFB923C);

  /// 主色深
  static const Color primaryDark = Color(0xFFEA580C);

  // ============ 强调色 ============
  /// 强调色 - 金黄
  static const Color accent = Color(0xFFFFB800);

  /// 强调色浅
  static const Color accentLight = Color(0xFFFFD54F);

  /// 强调色深
  static const Color accentDark = Color(0xFFFF8F00);

  // ============ 警告/危险色 ============
  /// 危险色 - 红色
  static const Color danger = Color(0xFFE53935);

  /// 危险色浅
  static const Color dangerLight = Color(0xFFFF5252);

  /// 警告色 - 橙色
  static const Color warning = Color(0xFFFF9800);

  /// 成功色 - 绿色
  static const Color success = Color(0xFF4CAF50);

  // ============ 声音分类色彩 ============
  /// 超声波 - 蓝紫
  static const Color ultrasonic = Color(0xFF7C4DFF);

  /// 动物威慑 - 深橙
  static const Color animal = Color(0xFFFF6D00);

  /// 炮仗 - 红色
  static const Color firecracker = Color(0xFFE53935);

  /// 警报 - 琥珀
  static const Color alarm = Color(0xFFFFAB00);

  /// 金属撞击 - 钢蓝
  static const Color metal = Color(0xFF546E7A);

  /// 根据分类获取颜色
  static Color getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'ultrasonic':
        return ultrasonic;
      case 'animal':
        return animal;
      case 'firecracker':
        return firecracker;
      case 'alarm':
        return alarm;
      case 'metal':
        return metal;
      default:
        return primary;
    }
  }

  // ============ 中性色 ============
  /// 背景色
  static const Color background = Color(0xFFF5F5F5);

  /// 卡片背景
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// 分割线
  static const Color divider = Color(0xFFE0E0E0);

  /// 文字主色
  static const Color textPrimary = Color(0xFF212121);

  /// 文字次色
  static const Color textSecondary = Color(0xFF757575);

  /// 文字提示
  static const Color textHint = Color(0xFFBDBDBD);
}

/// 暗色主题色彩
class AppColorsDark {
  AppColorsDark._();

  static const Color primary = Color(0xFFFB923C);
  static const Color primaryLight = Color(0xFFFDBA74);
  static const Color primaryDark = Color(0xFFF97316);

  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFFF8F00);

  static const Color danger = Color(0xFFFF5252);
  static const Color dangerLight = Color(0xFFFF8A80);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF66BB6A);

  static const Color ultrasonic = Color(0xFFB388FF);
  static const Color animal = Color(0xFFFFAB40);
  static const Color firecracker = Color(0xFFFF5252);
  static const Color alarm = Color(0xFFFFD54F);
  static const Color metal = Color(0xFF90A4AE);

  static Color getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'ultrasonic':
        return ultrasonic;
      case 'animal':
        return animal;
      case 'firecracker':
        return firecracker;
      case 'alarm':
        return alarm;
      case 'metal':
        return metal;
      default:
        return primary;
    }
  }

  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF424242);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF757575);
}
