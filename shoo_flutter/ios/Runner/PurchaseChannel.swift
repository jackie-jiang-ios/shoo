//
//  PurchaseChannel.swift
//  Shoo
//
//  Platform Channel for Flutter <-> StoreKit2 communication
//

import Flutter
import StoreKit

@MainActor
@available(iOS 15.0, *)
class PurchaseChannel {
    static func setup(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.shoo.app/purchase",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { call, result in
            Task { @MainActor in
                switch call.method {
                case "isProActive":
                    if #available(iOS 15.0, *) {
                        result(PurchaseManager.shared.isProActive)
                    } else {
                        result(false)
                    }

                case "getProPrice":
                    if #available(iOS 15.0, *) {
                        result(PurchaseManager.shared.proPriceText)
                    } else {
                        result("")
                    }

                case "loadProducts":
                    if #available(iOS 15.0, *) {
                        await PurchaseManager.shared.loadProducts()
                        result([
                            "price": PurchaseManager.shared.proPriceText,
                            "error": PurchaseManager.shared.lastError as Any,
                        ])
                    } else {
                        result(["price": "", "error": "iOS 15.0+"])
                    }

                case "purchasePro":
                    if #available(iOS 15.0, *) {
                        let success = await PurchaseManager.shared.purchasePro()
                        result([
                            "success": success,
                            "isPro": PurchaseManager.shared.isProActive,
                            "error": PurchaseManager.shared.lastError as Any,
                        ])
                    } else {
                        result(["success": false, "isPro": false, "error": "iOS 15.0+"])
                    }

                case "restorePurchases":
                    if #available(iOS 15.0, *) {
                        await PurchaseManager.shared.restorePurchases()
                        result([
                            "success": PurchaseManager.shared.isProActive,
                            "isPro": PurchaseManager.shared.isProActive,
                            "error": PurchaseManager.shared.lastError as Any,
                        ])
                    } else {
                        result(["success": false, "isPro": false, "error": "iOS 15.0+"])
                    }

                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }
}
