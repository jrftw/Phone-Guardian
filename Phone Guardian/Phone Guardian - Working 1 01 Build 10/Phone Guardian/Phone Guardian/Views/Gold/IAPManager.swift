import Foundation
import StoreKit

@MainActor
class IAPManager: ObservableObject {
    static let shared = IAPManager()

    @Published var hasGoldSubscription = false
    @Published var hasVirusScanner = false

    private let goldProductID = "com.phoneguardian.gold"
    private let virusScannerProductID = "com.phoneguardian.virusscanner"

    func purchaseGold() async {
        await purchaseProduct(productID: goldProductID)
    }

    func purchaseVirusScanner() async {
        await purchaseProduct(productID: virusScannerProductID)
    }

    private func purchaseProduct(productID: String) async {
        do {
            // Retrieve the product
            let products = try await Product.products(for: Set([productID]))
            guard let product = products.first else {
                print("Product not found")
                return
            }

            // Perform the purchase
            let result = try await product.purchase()

            // Handle the purchase result
            switch result {
            case .success(let verification):
                if case .verified(_) = verification {
                    handlePurchase(for: productID)
                }
            case .pending:
                print("Purchase pending")
            case .userCancelled:
                print("Purchase cancelled")
            @unknown default:
                print("Unhandled purchase result")
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }

    func restorePurchases() async {
        // Iterate over the asynchronous sequence of transactions
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                handlePurchase(for: transaction.productID)
            case .unverified:
                print("Unverified transaction found")
            }
        }
    }

    private func handlePurchase(for productID: String) {
        switch productID {
        case goldProductID:
            hasGoldSubscription = true
        case virusScannerProductID:
            hasVirusScanner = true
        default:
            break
        }
    }
}
