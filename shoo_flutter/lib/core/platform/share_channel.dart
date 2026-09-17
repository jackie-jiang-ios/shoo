import 'package:flutter/services.dart';

/// 系统分享通道
///
/// 通过 MethodChannel 调用原生的 UIActivityViewController 实现苹果系统分享。
class ShareChannel {
  static const MethodChannel _channel = MethodChannel('com.shoo.app/platform');

  /// 弹出系统分享面板
  ///
  /// [text] 分享文本
  /// [url] 可选的分享链接
  static Future<bool> share({required String text, String? url}) async {
    try {
      final result = await _channel.invokeMethod<bool>('shareApp', {
        'text': text,
        'url': url,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Share channel error: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 分享 App Store 链接
  static Future<bool> shareApp(String appStoreUrl, String shareText) {
    return share(text: shareText, url: appStoreUrl);
  }
}
