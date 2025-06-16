import Foundation
import Combine
import FirebaseAuth

enum OnboardingStep {
    case slides, login, kidsProfile, pinSetup, adminCards, done
}

class OnboardingStateManager: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var needsOnboarding: Bool = false
    @Published var onboardingStep: OnboardingStep = .slides
    @Published var userId: String = ""
    
    func checkOnboardingState(userId: String) {
        print("[OnboardingStateManager] Checking onboarding state for userId: \(userId)")
        self.isLoading = true
        
        // Ensure we have a valid userId
        guard !userId.isEmpty, Auth.auth().currentUser != nil else {
            print("[OnboardingStateManager] No valid user authentication, cannot check onboarding state")
            DispatchQueue.main.async {
                self.onboardingStep = .slides
                self.needsOnboarding = true
                self.isLoading = false
            }
            return
        }
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            print("[OnboardingStateManager] Firestore user fetched: \(String(describing: user))")
            if let user = user {
                if user.adminOnboardingComplete == true {
                    DispatchQueue.main.async {
                        print("[OnboardingStateManager] Onboarding complete. Setting didCompleteOnboarding = true")
                        UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                        self.needsOnboarding = false
                        self.isLoading = false
                    }
                } else {
                    // User exists but onboarding is incomplete, determine which stage of onboarding
                    FirestoreManager.shared.fetchKids(userId: userId) { kids in
                        let hasKids = !kids.isEmpty
                        let hasPin = user.pinHash != nil
                        DispatchQueue.main.async {
                            print("[OnboardingStateManager] hasKids: \(hasKids), hasPin: \(hasPin)")
                            if !hasKids {
                                print("[OnboardingStateManager] Setting onboardingStep = .kidsProfile")
                                self.onboardingStep = .kidsProfile
                                self.needsOnboarding = true
                                self.isLoading = false
                                return
                            }
                            if !hasPin {
                                print("[OnboardingStateManager] Setting onboardingStep = .pinSetup")
                                self.onboardingStep = .pinSetup
                                self.needsOnboarding = true
                                self.isLoading = false
                                return
                            }
                            // Use the first kid for onboarding card checks
                            guard let activeKidId = kids.first?.id else {
                                print("[OnboardingStateManager] No kid found for card checks, treating as incomplete onboarding.")
                                self.onboardingStep = .kidsProfile
                                self.needsOnboarding = true
                                self.isLoading = false
                                return
                            }
                            // Check for at least one card in each tab for the first kid
                            let group = DispatchGroup()
                            var hasRules = false
                            var hasChores = false
                            var hasRewards = false
                            group.enter()
                            FirestoreManager.shared.fetchRules(userId: userId, kidId: activeKidId) { rules in
                                hasRules = rules.contains(where: { $0.isActive })
                                group.leave()
                            }
                            group.enter()
                            FirestoreManager.shared.fetchChores(userId: userId, kidId: activeKidId) { chores in
                                hasChores = chores.contains(where: { $0.isActive })
                                group.leave()
                            }
                            group.enter()
                            FirestoreManager.shared.fetchRewards(userId: userId, kidId: activeKidId) { rewards in
                                hasRewards = rewards.contains(where: { $0.isActive })
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                print("[OnboardingStateManager] hasRules: \(hasRules), hasChores: \(hasChores), hasRewards: \(hasRewards)")
                                if !hasRules || !hasChores || !hasRewards {
                                    print("[OnboardingStateManager] Setting onboardingStep = .adminCards")
                                    self.onboardingStep = .adminCards
                                    self.needsOnboarding = true
                                    self.isLoading = false
                                    return
                                }
                                print("[OnboardingStateManager] Setting onboardingStep = .done")
                                self.onboardingStep = .done
                                self.needsOnboarding = true
                                self.isLoading = false
                            }
                        }
                    }
                }
            } else {
                // Firestore user is missing!
                print("[OnboardingStateManager] Firestore user missing. Forcing sign out and showing login.")
                try? Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.onboardingStep = .slides
                    self.needsOnboarding = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func completeOnboarding(userId: String) {
        FirestoreManager.shared.setAdminOnboardingComplete(userId: userId) { error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                self.needsOnboarding = false
            }
        }
    }
} 