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
                case .verified(_):
                    print("[StoreKitManager] Purchase verified for product: \(product.id)")
                    await refreshSubscriptionStatus()
                    return true
                default:
                    print("[StoreKitManager] Purchase not verified for product: \(product.id)")
                    return false
                }
            default:
                print("[StoreKitManager] Purchase not successful for product: \(product.id)")
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
            for await result in StoreKit.Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if productIDs.contains(transaction.productID) {
                        if transaction.revocationDate == nil,
                           transaction.expirationDate == nil || (transaction.expirationDate! > Date()) {
                            print("[StoreKitManager] Active entitlement found for product: \(transaction.productID)")
                            return true
                        }
                    }
                } else {
                    print("[StoreKitManager] Transaction not verified: \(result)")
                }
            }
            print("[StoreKitManager] No active entitlements found.")
        }
        return false
    }

    /// Refreshes the published subscription status
    func refreshSubscriptionStatus() async {
        let active = await hasActiveSubscription()
        await MainActor.run { self.isSubscribed = active }
    }

    /// Listens for StoreKit 2 transaction updates and refreshes subscription status
    func listenForTransactionUpdates() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            if #available(iOS 15.0, *) {
                for await _ in StoreKit.Transaction.updates {
                    await self.refreshSubscriptionStatus()
                }
            }
        }
    }
} 