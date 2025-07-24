import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isSubscribed: Bool = false

    let productIDs = ["com.Tipje.month", "com.Tipje.year"]

    init() {
        Task { await loadProducts() }
        Task { await refreshSubscriptionStatus() }
        listenForTransactionUpdates()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            error = nil
            print("[StoreKitManager] Products loaded: \(products.map { $0.id })")
        } catch {
            self.error = error.localizedDescription
            print("[StoreKitManager] Failed to load products: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    func purchase(product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("[StoreKitManager] Purchase verified for product: \(product.id)")
                    // CRITICAL: Finish the transaction to mark it as complete
                    await transaction.finish()
                    print("[StoreKitManager] Transaction finished for product: \(product.id)")
                    // Add a small delay to ensure transaction is processed
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    await refreshSubscriptionStatus()
                    return true
                case .unverified(_, let error):
                    print("[StoreKitManager] Purchase unverified for product: \(product.id), error: \(error)")
                    return false
                }
            case .userCancelled:
                print("[StoreKitManager] Purchase cancelled by user for product: \(product.id)")
                return false
            case .pending:
                print("[StoreKitManager] Purchase pending for product: \(product.id)")
                return false
            @unknown default:
                print("[StoreKitManager] Purchase unknown result for product: \(product.id)")
                return false
            }
        } catch {
            self.error = error.localizedDescription
            print("[StoreKitManager] Purchase error for product \(product.id): \(error.localizedDescription)")
            return false
        }
    }

    /// Checks if the user has an active subscription (monthly or yearly)
    func hasActiveSubscription() async -> Bool {
        if #available(iOS 15.0, *) {
            print("[StoreKitManager] Checking for active entitlements...")
            
            // First check current entitlements
            for await result in StoreKit.Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if productIDs.contains(transaction.productID) {
                        print("[StoreKitManager] Found transaction for product: \(transaction.productID)")
                        print("[StoreKitManager] Purchase date: \(transaction.purchaseDate)")
                        print("[StoreKitManager] Expiration date: \(transaction.expirationDate?.description ?? "none")")
                        print("[StoreKitManager] Revocation date: \(transaction.revocationDate?.description ?? "no")")
                        print("[StoreKitManager] Current date: \(Date())")
                        
                        let isRevoked = transaction.revocationDate != nil
                        let isExpired = transaction.expirationDate != nil && transaction.expirationDate! <= Date()
                        
                        print("[StoreKitManager] Is revoked: \(isRevoked)")
                        print("[StoreKitManager] Is expired: \(isExpired)")
                        
                        if !isRevoked && !isExpired {
                            print("[StoreKitManager] ✅ Active entitlement found in currentEntitlements for product: \(transaction.productID)")
                            return true
                        } else {
                            if isRevoked {
                                print("[StoreKitManager] ❌ Transaction revoked for product: \(transaction.productID)")
                            }
                            if isExpired {
                                print("[StoreKitManager] ❌ Transaction expired for product: \(transaction.productID)")
                            }
                        }
                    }
                } else {
                    print("[StoreKitManager] ⚠️ Unverified transaction found")
                }
            }
            
            print("[StoreKitManager] No transactions found in currentEntitlements")
            print("[StoreKitManager] Checking all transactions...")
            
            // Also check all transactions (including pending ones)
            for await result in StoreKit.Transaction.all {
                if case .verified(let transaction) = result {
                    if productIDs.contains(transaction.productID) {
                        print("[StoreKitManager] Found transaction in all transactions for product: \(transaction.productID)")
                        print("[StoreKitManager] Purchase date: \(transaction.purchaseDate)")
                        print("[StoreKitManager] Expiration date: \(transaction.expirationDate?.description ?? "none")")
                        print("[StoreKitManager] Revocation date: \(transaction.revocationDate?.description ?? "no")")
                        print("[StoreKitManager] Current date: \(Date())")
                        
                        let isRevoked = transaction.revocationDate != nil
                        let isExpired = transaction.expirationDate != nil && transaction.expirationDate! <= Date()
                        
                        print("[StoreKitManager] Is revoked: \(isRevoked)")
                        print("[StoreKitManager] Is expired: \(isExpired)")
                        
                        if !isRevoked && !isExpired {
                            print("[StoreKitManager] ✅ Active entitlement found in all transactions for product: \(transaction.productID)")
                            return true
                        } else {
                            if isRevoked {
                                print("[StoreKitManager] ❌ Transaction revoked for product: \(transaction.productID)")
                            }
                            if isExpired {
                                print("[StoreKitManager] ❌ Transaction expired for product: \(transaction.productID)")
                            }
                        }
                    }
                } else {
                    print("[StoreKitManager] ⚠️ Unverified transaction found in all transactions")
                }
            }
            print("[StoreKitManager] No active entitlements found.")
        }
        return false
    }

    /// Refreshes the published subscription status
    func refreshSubscriptionStatus() async {
        let active = await hasActiveSubscription()
        await MainActor.run { 
            self.isSubscribed = active
            print("[StoreKitManager] Subscription status updated: \(active)")
        }
    }

    /// Listens for StoreKit 2 transaction updates and refreshes subscription status
    func listenForTransactionUpdates() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            if #available(iOS 15.0, *) {
                print("[StoreKitManager] Starting transaction listener...")
                for await result in StoreKit.Transaction.updates {
                    print("[StoreKitManager] Transaction update received")
                    if case .verified(let transaction) = result {
                        print("[StoreKitManager] ✅ Verified transaction update for product: \(transaction.productID)")
                        // CRITICAL: Finish the transaction
                        await transaction.finish()
                        print("[StoreKitManager] Transaction finished in listener")
                        await self.refreshSubscriptionStatus()
                    } else {
                        print("[StoreKitManager] ⚠️ Unverified transaction update")
                    }
                }
            }
        }
    }
} 