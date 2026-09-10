import StoreKit

enum ShooProductID: String, CaseIterable {
    case proLifetime = "com.yangshiqin.shoo.pro_lifetime"
}

/// 截图模式检测 - 用于 App Store 截图时强制显示 Pro 版本
enum ScreenshotMode {
    static var isEnabled: Bool {
        // 检查启动参数
        if ProcessInfo.processInfo.arguments.contains("-ScreenshotMode") {
            return true
        }
        // 检查环境变量
        if ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "1" {
            return true
        }
        // 检查 UserDefaults（通过 simctl defaults write 设置）
        if UserDefaults.standard.bool(forKey: "ScreenshotMode") {
            return true
        }
        return false
    }
}

@MainActor
@available(iOS 15.0, *)
final class PurchaseManager {
    static let shared = PurchaseManager()
    private(set) var isProActive: Bool = false
    private(set) var isLoadingProducts: Bool = false
    private(set) var storeProducts: [StoreKit.Product] = []
    private(set) var purchasingProductID: String?
    private(set) var lastError: String?

    var proProduct: StoreKit.Product? {
        storeProducts.first { $0.id == ShooProductID.proLifetime.rawValue }
    }
    var proPriceText: String {
        proProduct?.displayPrice ?? ""
    }

    private var updateListenerTask: Task<Void, Never>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await updatePurchasedStatus()
            await loadProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let productIDs = ShooProductID.allCases.map(\.rawValue)
            self.storeProducts = try await StoreKit.Product.products(for: productIDs)
        } catch {
            print("[PurchaseManager] Failed to load products: \(error)")
            lastError = "load_failed"
        }
    }

    func purchasePro() async -> Bool {
        guard let product = proProduct else {
            lastError = "not_found"
            return false
        }
        return await purchase(product)
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch {
            print("[PurchaseManager] Restore failed: \(error)")
            lastError = "restore_failed"
        }
    }

    private func purchase(_ product: StoreKit.Product) async -> Bool {
        purchasingProductID = product.id
        lastError = nil
        defer { purchasingProductID = nil }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedStatus()
                    return true
                case .unverified(_, _):
                    lastError = "unverified"
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                lastError = "pending"
                return false
            @unknown default:
                lastError = "unknown"
                return false
            }
        } catch {
            print("[PurchaseManager] Purchase error: \(error)")
            lastError = error.localizedDescription
            return false
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        return Task {
            for await result in Transaction.updates {
                guard let transaction = self.checkVerified(result) else { continue }
                await self.updatePurchasedStatus()
                await transaction.finish()
            }
        }
    }

    func updatePurchasedStatus() async {
        // 截图模式下强制返回 Pro
        if ScreenshotMode.isEnabled {
            self.isProActive = true
            return
        }
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == ShooProductID.proLifetime.rawValue {
                hasPro = true
                break
            }
        }
        self.isProActive = hasPro
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            print("[PurchaseManager] Unverified: \(error)")
            return nil
        }
    }
}
