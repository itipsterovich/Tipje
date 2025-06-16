import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

@main
struct TipjeApp: App {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @StateObject var authManager = AuthManager()
    @StateObject var onboardingState = OnboardingStateManager()
    let store = Store()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.firebaseUser == nil {
                    // Not authenticated: show login/intro
                    OnboardingView(isStage1: true)
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                } else if onboardingState.isLoading {
                    TipjeLoadingView()
                        .onAppear {
                            // User is authenticated, now check onboarding state
                            if let uid = authManager.firebaseUser?.uid {
                                print("[TipjeApp] User is authenticated, uid=\(uid). Setting userId in store and onboardingState.")
                                store.setUser(userId: uid)
                                onboardingState.userId = uid
                                onboardingState.checkOnboardingState(userId: uid)
                            }
                        }
                } else if onboardingState.needsOnboarding && onboardingState.onboardingStep != .done {
                    // Only show onboarding if authenticated and not done!
                    OnboardingView(isStage1: false)
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                } else {
                    // Onboarding complete, show main app
                    MainView()
                        .environmentObject(store)
                        .environmentObject(authManager)
                }
            }
            .onAppear {
                print("[TipjeApp] authManager.firebaseUser=\(String(describing: authManager.firebaseUser)), Auth.auth().currentUser=\(String(describing: Auth.auth().currentUser))")
                // Force token refresh to check if user is still valid
                if let user = Auth.auth().currentUser {
                    user.getIDToken(completion: { token, error in
                        if let error = error {
                            print("[TipjeApp] getIDToken failed, signing out. Error: \(error.localizedDescription)")
                            do {
                                try Auth.auth().signOut()
                                authManager.firebaseUser = nil
                                onboardingState.userId = ""
                                onboardingState.isLoading = false
                                onboardingState.needsOnboarding = true
                                onboardingState.onboardingStep = .slides
                                print("[TipjeApp] Signed out due to invalid user session.")
                            } catch {
                                print("[TipjeApp] Error signing out: \(error.localizedDescription)")
                            }
                        } else {
                            print("[TipjeApp] getIDToken succeeded, user session is valid.")
                        }
                    })
                }
            }
        }
    }
}

// MARK: - Setup View Stubs

struct ProfileSetupView: View {
    let onProfileCreated: () -> Void
    @State private var name: String = ""
    var body: some View {
        VStack(spacing: 24) {
            Text("Create your profile")
                .font(.title)
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Continue") {
                // Save profile info here
                onProfileCreated()
            }
            .disabled(name.isEmpty)
        }
        .padding()
        .interactiveDismissDisabled(true)
    }
}
