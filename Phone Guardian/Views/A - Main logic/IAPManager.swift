import Foundation
import StoreKit
import os

@MainActor
class IAPManager: ObservableObject {
    static let shared = IAPManager()
    private let logger = Logger(subsystem: "com.phoneguardian.iapmanager", category: "IAPManager")

    @Published var hasGoldSubscription: Bool = false
    @Published var hasToolsSubscription: Bool = false
    @Published var hasRemoveAds: Bool = false // New boolean for remove ads add-on

    var hasGoldAccess: Bool {
        return hasGoldSubscription
    }

    private let goldProductID = "com.phoneguardian.gold"
    private let toolsProductID = "com.phoneguardian.tools"
    private let removeAdsProductID = "com.phoneguardian.removeads" // New product ID

    private var updatesTask: Task<Void, Never>?

    init() {
        startObservingTransactions()
        Task {
            await updatePurchasedProducts()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func checkSubscriptionStatus() async {
        await updatePurchasedProducts()
    }

    func purchaseGold() async {
        await purchaseProduct(productID: goldProductID)
    }

    func purchaseTools() async {
        await purchaseProduct(productID: toolsProductID)
    }

    func purchaseRemoveAds() async {
        await purchaseProduct(productID: removeAdsProductID)
    }

    func restorePurchases() async {
        do {
            logger.info("Attempting to restore purchases...")
            try await AppStore.sync()
            await updatePurchasedProducts()
            logger.info("Restore completed successfully.")
        } catch {
            logger.error("Restore purchases error: \(error.localizedDescription)")
        }
    }

    private func startObservingTransactions() {
        updatesTask = Task {
            for await result in Transaction.updates {
                await handle(transactionResult: result)
            }
        }
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            logger.info("Verified transaction for product ID: \(transaction.productID)")
            await transaction.finish()
            await updatePurchasedProducts()
        case .unverified:
            logger.error("Unverified transaction detected, ignoring.")
        }
    }

    private func updatePurchasedProducts() async {
        logger.info("Updating purchased products...")
        var hasGold = false
        var hasTools = false
        var hasAdsRemoved = false

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                guard transaction.revocationDate == nil else { continue }
                if let expirationDate = transaction.expirationDate, expirationDate < Date() { continue }
                switch transaction.productID {
                case goldProductID:
                    hasGold = true
                case toolsProductID:
                    hasTools = true
                case removeAdsProductID:
                    // remove ads is a non-consumable, once purchased always true
                    hasAdsRemoved = true
                default:
                    break
                }
            case .unverified:
                break
            }
        }

        self.hasGoldSubscription = hasGold
        self.hasToolsSubscription = hasTools
        self.hasRemoveAds = hasAdsRemoved
    }

    private func purchaseProduct(productID: String) async {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedProducts()
                case .unverified:
                    break
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            logger.error("Purchase error: \(error.localizedDescription)")
        }
    }
}
