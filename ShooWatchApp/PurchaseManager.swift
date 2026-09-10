import StoreKit
import SwiftUI

/// Watch 端内购产品 ID
/// 必须与 iPhone 端保持一致，才能共享购买状态
enum ShooProductID: String, CaseIterable {
    case proLifetime = "com.yangshiqin.shoo.pro"
}

/// 截图模式检测 - 用于 App Store 截图时强制显示 Pro 版本
enum ScreenshotMode {
    static var isEnabled: Bool {
        if ProcessInfo.processInfo.arguments.contains("-ScreenshotMode") {
            return true
        }
        if ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "1" {
            return true
        }
        if UserDefaults.standard.bool(forKey: "ScreenshotMode") {
            return true
        }
        return false
    }
}

/// 检测是否在模拟器中运行
enum SimulatorDetector {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

/// 内购状态管理器 (SwiftUI ObservableObject)
@MainActor
final class PurchaseStatus: ObservableObject {
    static let shared = PurchaseStatus()

    @Published private(set) var isProActive: Bool = false
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var proPrice: String = ""
    @Published private(set) var lastError: String?

    private let productID = ShooProductID.proLifetime.rawValue
    private var transactionListener: Task<Void, Never>?

    private init() {
        // 截图模式下直接显示 Pro
        if ScreenshotMode.isEnabled {
            self.isProActive = true
            self.isLoading = false
            return
        }

        // 在非模拟器环境下初始化 StoreKit
        if !SimulatorDetector.isSimulator {
            self.transactionListener = listenForTransactions()
            Task {
                await updatePurchasedStatus()
                await loadProduct()
            }
        } else {
            // 模拟器环境下直接设为非 Pro，不初始化 StoreKit
            self.isProActive = false
            self.isLoading = false
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// 从 App Store 加载产品信息
    private func loadProduct() async {
        guard !SimulatorDetector.isSimulator else { return }
        do {
            let products = try await StoreKit.Product.products(for: [productID])
            if let product = products.first {
                self.proPrice = product.displayPrice
            }
        } catch {
            print("[PurchaseStatus] Failed to load product: \(error)")
        }
    }

    /// 更新购买状态（检查是否有有效的 Pro 购买）
    func updatePurchasedStatus() async {
        guard !SimulatorDetector.isSimulator else {
            self.isProActive = false
            self.isLoading = false
            return
        }

        // 截图模式下强制返回 Pro
        if ScreenshotMode.isEnabled {
            self.isProActive = true
            self.isLoading = false
            return
        }

        var hasPro = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                hasPro = true
                break
            }
        }
        self.isProActive = hasPro
        self.isLoading = false
    }

    /// 购买 Pro 版本
    func purchasePro() async {
        guard !self.isPurchasing else { return }

        // 模拟器环境下提示不可用
        if SimulatorDetector.isSimulator {
            self.lastError = "simulator_not_supported"
            return
        }

        self.isPurchasing = true
        self.lastError = nil
        defer { self.isPurchasing = false }

        do {
            let products = try await StoreKit.Product.products(for: [productID])
            guard let product = products.first else {
                self.lastError = "product_not_found"
                return
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedStatus()
                case .unverified(_, let error):
                    self.lastError = "unverified"
                    print("[PurchaseStatus] Purchase unverified: \(error)")
                }
            case .userCancelled:
                print("[PurchaseStatus] User cancelled purchase")
            case .pending:
                self.lastError = "pending"
                print("[PurchaseStatus] Purchase pending")
            @unknown default:
                self.lastError = "unknown"
            }
        } catch {
            self.lastError = error.localizedDescription
            print("[PurchaseStatus] Purchase error: \(error)")
        }
    }

    /// 恢复购买
    func restorePurchases() async {
        guard !SimulatorDetector.isSimulator else {
            self.lastError = "simulator_not_supported"
            return
        }

        self.lastError = nil
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch {
            self.lastError = "restore_failed"
            print("[PurchaseStatus] Restore failed: \(error)")
        }
    }

    /// 监听交易更新
    func listenForTransactions() -> Task<Void, Never> {
        return Task { @MainActor in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self.updatePurchasedStatus()
                if transaction.productID == self.productID {
                    await transaction.finish()
                }
            }
        }
    }
}
