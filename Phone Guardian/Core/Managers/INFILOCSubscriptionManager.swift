import Foundation
import StoreKit
import os.log

class INFILOCSubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var currentSubscription: INFILOCSubscription?
    @Published var availableProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let logger = Logger(subsystem: "com.phoneguardian.infiloc", category: "Subscription")
    
    // INFILOC Product IDs
    private let productIDs = [
        "infiloc_weekly",    // $1.99/week
        "infiloc_monthly",   // $3.99/month
        "infiloc_yearly"     // $44.99/year
    ]
    
    init() {
        loadSubscriptionStatus()
        Task {
            await loadProducts()
        }
    }
    
    // MARK: - Product Loading
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: productIDs)
            self.availableProducts = products.sorted { $0.price < $1.price }
            logger.info("Loaded \(products.count) INFILOC products")
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            errorMessage = "Failed to load subscription options"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    @MainActor
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                switch verification {
                case .verified(let transaction):
                    await handleSuccessfulPurchase(transaction)
                    return true
                case .unverified:
                    logger.error("Transaction verification failed")
                    errorMessage = "Purchase verification failed"
                    return false
                }
            case .userCancelled:
                logger.info("User cancelled purchase")
                return false
            case .pending:
                logger.info("Purchase is pending")
                errorMessage = "Purchase is pending approval"
                return false
            @unknown default:
                logger.error("Unknown purchase result")
                errorMessage = "Unknown purchase error"
                return false
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: Transaction) async {
        // Update subscription status
        await updateSubscriptionStatus()
        
        // Finish the transaction
        await transaction.finish()
        
        logger.info("INFILOC subscription purchased successfully: \(transaction.productID)")
    }
    
    // MARK: - Subscription Status
    @MainActor
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIDs.contains(transaction.productID) {
                    isSubscribed = true
                    currentSubscription = INFILOCSubscription(from: transaction)
                    logger.info("Active INFILOC subscription found: \(transaction.productID)")
                    return
                }
            case .unverified:
                logger.warning("Unverified transaction found")
            }
        }
        
        isSubscribed = false
        currentSubscription = nil
        logger.info("No active INFILOC subscription found")
    }
    
    private func loadSubscriptionStatus() {
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            
            if isSubscribed {
                logger.info("INFILOC subscription restored successfully")
                return true
            } else {
                logger.info("No INFILOC subscription found to restore")
                errorMessage = "No active subscription found"
                return false
            }
        } catch {
            logger.error("Failed to restore purchases: \(error.localizedDescription)")
            errorMessage = "Failed to restore purchases"
            return false
        }
    }
    
    // MARK: - Subscription Management
    func openSubscriptionManagement() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - INFILOC Subscription Model
struct INFILOCSubscription: Identifiable {
    let id = UUID()
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isActive: Bool
    
    var subscriptionType: String {
        switch productID {
        case "infiloc_weekly": return "Weekly"
        case "infiloc_monthly": return "Monthly"
        case "infiloc_yearly": return "Yearly"
        default: return "Unknown"
        }
    }
    
    var formattedExpiration: String {
        guard let expirationDate = expirationDate else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: expirationDate)
    }
    
    init(from transaction: Transaction) {
        self.productID = transaction.productID
        self.purchaseDate = transaction.purchaseDate
        self.expirationDate = transaction.expirationDate
        self.isActive = transaction.expirationDate == nil || transaction.expirationDate! > Date()
    }
}

// MARK: - Product Extensions
extension Product {
    var formattedPrice: String {
        return displayPrice
    }
    
    var subscriptionPeriod: String {
        switch subscription?.subscriptionPeriod.unit {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        case .none:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
    
    var subscriptionPeriodCount: Int {
        return subscription?.subscriptionPeriod.value ?? 1
    }
    
    var formattedPeriod: String {
        let count = subscriptionPeriodCount
        let period = subscriptionPeriod
        
        if count == 1 {
            return period
        } else {
            return "\(count) \(period)s"
        }
    }
} 