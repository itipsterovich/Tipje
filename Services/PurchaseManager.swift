import Foundation

class PurchaseManager: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var daysLeftInTrial: Int? = nil
    // TODO: Implement StoreKit 2 logic for 7-day trial and subscriptions
    // TODO: Add purchase, restore, and entitlement check methods
    
    init() {
        // TODO: Load subscription status
    }
} 