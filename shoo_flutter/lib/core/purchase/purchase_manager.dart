import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 内购管理器 (Flutter 侧)
///
/// 通过 Platform Channel 调用 iOS 原生 StoreKit 2 代码。
/// 原生实现参考 FlipPrinter 项目的 PurchaseManager.swift。
class PurchaseManager {
  PurchaseManager._();
  static final PurchaseManager instance = PurchaseManager._();

  static const MethodChannel _channel = MethodChannel('com.shoo.app/purchase');

  bool _isPro = false;
  bool get isPro => _isPro;

  String _proPrice = '';
  String get proPrice => _proPrice;

  /// 测试/截图用：强制设置 Pro 状态
  @visibleForTesting
  void debugSetPro(bool value) {
    _isPro = value;
    onProStatusChanged?.call(value);
  }

  String? _lastError;
  String? get lastError => _lastError;

  bool _isPurchasing = false;
  bool get isPurchasing => _isPurchasing;

  /// 状态变化回调
  void Function(bool)? onProStatusChanged;

  /// 初始化（在 main() 中调用）
  Future<void> init() async {
    debugPrint('>>> INIT_PURCHASE_START');
    try {
      _isPro = await _invoke<bool>('isProActive') ?? false;
      _proPrice = await _invoke<String>('getProPrice') ?? '';
      debugPrint('>>> INIT_PURCHASE_DONE: isPro=$_isPro, price=$_proPrice');
    } on PlatformException catch (e) {
      debugPrint('>>> INIT_PURCHASE_FAILED: \${e.code} - \${e.message}');
      _isPro = false;
    }
  }

  /// 加载产品信息（获取最新价格）
  Future<void> loadProducts() async {
    try {
      final result = await _invoke<Map>('loadProducts');
      if (result != null) {
        _proPrice = result['price'] as String? ?? _proPrice;
      }
    } on PlatformException catch (e) {
      print('[PurchaseManager] Load products failed: \${e.code} - \${e.message}');
    }
  }

  /// 购买 Pro
  Future<bool> purchasePro() async {
    if (_isPurchasing) return false;
    _isPurchasing = true;
    try {
      final result = await _invoke<Map>('purchasePro');
      if (result != null) {
        final success = result['success'] as bool? ?? false;
        final isPro = result['isPro'] as bool? ?? false;
        if (isPro != _isPro) {
          _isPro = isPro;
          onProStatusChanged?.call(_isPro);
        }
        return success;
      }
      return false;
    } on PlatformException catch (e) {
      print('[PurchaseManager] Purchase failed: \${e.code} - \${e.message}');
      _lastError = e.message;
      return false;
    } finally {
      _isPurchasing = false;
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    try {
      final result = await _invoke<Map>('restorePurchases');
      if (result != null) {
        final isPro = result['isPro'] as bool? ?? false;
        if (isPro != _isPro) {
          _isPro = isPro;
          onProStatusChanged?.call(_isPro);
        }
        return isPro;
      }
      return false;
    } on PlatformException catch (e) {
      print('[PurchaseManager] Restore failed: \${e.code} - \${e.message}');
      _lastError = e.message;
      return false;
    }
  }

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      print('[PurchaseManager] Channel error: \${e.code} - \${e.message}');
      rethrow;
    }
  }
}
