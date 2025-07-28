import Foundation
import Combine
import FirebaseAuth

/// Centralized onboarding state manager for Tipje app
class OnboardingStateManager: ObservableObject {
    static let shared = OnboardingStateManager()
    /// The current user's ID (empty if not logged in)
    @Published var userId: String = ""
    /// True if the user needs to set up at least one kid profile
    @Published var needsKidsProfile: Bool = true
    /// True if the user needs to set up a PIN
    @Published var needsPinSetup: Bool = true
    /// True if the user needs to add at least one rule, chore, and reward
    @Published var needsCardsSetup: Bool = true
    /// True if all onboarding steps are complete
    @Published var onboardingComplete: Bool = false
    /// True if the user has logged in
    @Published var didLogin: Bool = false
    /// True if the user has an active subscription
    @Published var hasActiveSubscription: Bool = false
    /// The user's trial start date (cached after login)
    @Published var trialStartDate: Date? = nil
    private var storeKitCancellable: Any?

    init() {
        Task { @MainActor in
            self.setupStoreKitSubscriptionObservation()
        }
    }

    @MainActor
    private func setupStoreKitSubscriptionObservation() {
        // Use Combine if available, otherwise fallback to KVO
        #if canImport(Combine)
        // Ensure StoreKitManager.shared is initialized before observing
        let storeKitManager = StoreKitManager.shared
        storeKitCancellable = storeKitManager.$isSubscribed.sink { [weak self] isSubscribed in
            DispatchQueue.main.async {
                self?.hasActiveSubscription = isSubscribed
            }
        }
        #endif
    }

    /// Refreshes subscription status from StoreKit (useful for catching promo code redemptions)
    func refreshSubscriptionStatus() async {
        await StoreKitManager.shared.refreshSubscriptionStatus()
        await MainActor.run {
            self.hasActiveSubscription = StoreKitManager.shared.isSubscribed
            print("[OnboardingStateManager] Subscription status refreshed: \(self.hasActiveSubscription)")
        }
    }

    /// Enum representing the current onboarding step
    enum Step {
        case intro
        case subscription
        case kidsProfile
        case pinSetup
        case cardsSetup
        case main
    }
    /// Returns true if the user is within the 1-month free trial period
    var isInTrialPeriod: Bool {
        guard let start = trialStartDate else { return false }
        let now = Date()
        let days = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
        return days < 30
    }
    /// Returns the current onboarding step based on all flags and trial period
    var currentStep: Step {
        if !didLogin {
            return .intro
        } else if !hasActiveSubscription && !isInTrialPeriod {
            return .subscription
        } else if needsKidsProfile {
            return .kidsProfile
        } else if needsPinSetup {
            return .pinSetup
        } else if needsCardsSetup {
            return .cardsSetup
        } else {
            return .main
        }
    }

    /// Refreshes onboarding state from Firestore for the given userId
    func refreshState(for userId: String) {
        guard !userId.isEmpty else {
            print("[OnboardingStateManager] refreshState called with empty userId. Aborting.")
            return
        }
        self.userId = userId
        self.onboardingComplete = false
        // 1. Check for kids
        FirestoreManager.shared.fetchKids(userId: userId) { kids in
            DispatchQueue.main.async {
                self.needsKidsProfile = kids.isEmpty
                // 2. Check for PIN (fetch user profile)
                FirestoreManager.shared.fetchUser(userId: userId) { user in
                    DispatchQueue.main.async {
                        self.needsPinSetup = (user?.pinHash == nil)
                        self.trialStartDate = user?.trialStartDate
                        // 3. Check for cards (rules, chores, rewards)
                        if let firstKid = kids.first {
                            let kidId = firstKid.id
                            let group = DispatchGroup()
                            var hasRule = false, hasChore = false, hasReward = false
                            group.enter()
                            FirestoreManager.shared.fetchRules(userId: userId, kidId: kidId) { rules in
                                hasRule = rules.contains { $0.isActive }
                                group.leave()
                            }
                            group.enter()
                            FirestoreManager.shared.fetchChores(userId: userId, kidId: kidId) { chores in
                                hasChore = chores.contains { $0.isActive }
                                group.leave()
                            }
                            group.enter()
                            FirestoreManager.shared.fetchRewards(userId: userId, kidId: kidId) { rewards in
                                hasReward = rewards.contains { $0.isActive }
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                self.needsCardsSetup = !(hasRule && hasChore && hasReward)
                                // 4. Set onboardingComplete if all steps are done
                                self.onboardingComplete = !self.needsKidsProfile && !self.needsPinSetup && !self.needsCardsSetup
                            }
                        } else {
                            self.needsCardsSetup = true
                            self.onboardingComplete = false
                        }
                    }
                }
            }
        }
    }

    /// Resets all onboarding state to defaults
    func reset() {
        userId = ""
        needsKidsProfile = true
        needsPinSetup = true
        needsCardsSetup = true
        onboardingComplete = false
        didLogin = false
        hasActiveSubscription = false
    }
} 