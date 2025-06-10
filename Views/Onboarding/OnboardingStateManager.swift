import Foundation
import Combine

enum OnboardingStep {
    case slides, login, kidsProfile, pinSetup, done
}

class OnboardingStateManager: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var needsOnboarding: Bool = false
    @Published var onboardingStep: OnboardingStep = .slides
    @Published var userId: String = ""
    
    func checkOnboardingState(userId: String) {
        self.isLoading = true
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            if user?.adminOnboardingComplete == true {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                    self.needsOnboarding = false
                    self.isLoading = false
                }
            } else {
                FirestoreManager.shared.fetchKids(userId: userId) { kids in
                    let hasKids = !kids.isEmpty
                    let hasPin = user?.pinHash != nil
                    DispatchQueue.main.async {
                        if !hasKids {
                            self.onboardingStep = .kidsProfile
                        } else if !hasPin {
                            self.onboardingStep = .pinSetup
                        } else {
                            self.onboardingStep = .done
                        }
                        self.needsOnboarding = true
                        self.isLoading = false
                    }
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