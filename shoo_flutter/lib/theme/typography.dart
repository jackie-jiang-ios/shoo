import 'package:flutter/material.dart';

/// 应用文字排版系统
class AppTypography {
  AppTypography._();

  /// 大标题
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 标题
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// 小标题
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 正文大
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// 正文
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// 正文小
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// 标签
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  /// 按钮
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// 数字
  static const TextStyle number = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 数字小
  static const TextStyle numberSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
