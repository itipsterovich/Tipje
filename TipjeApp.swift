import SwiftUI
// import SwiftData // Removed to avoid Store ambiguity
import FirebaseCore
import FirebaseAuth

@main
struct TipjeApp: App {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @StateObject var authManager = AuthManager()
    @StateObject var onboardingState = OnboardingStateManager.shared
    let store = TipjeStore()
    @State private var isAppReady: Bool = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !isAppReady {
                    TipjeLoadingView()
                } else {
                    switch onboardingState.currentStep {
                    case .intro:
                        OnboardingView(isStage1: true)
                            .environmentObject(store)
                            .environmentObject(authManager)
                            .environmentObject(onboardingState)
                    case .subscription:
                        SubscriptionView(onPlanSelected: { plan in
                            onboardingState.hasActiveSubscription = true
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                            .environmentObject(store)
                            .environmentObject(authManager)
                            .environmentObject(onboardingState)
                    case .kidsProfile:
                        KidsProfileView(userId: onboardingState.userId, onNext: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                    case .pinSetup:
                        PinSetupView(userId: onboardingState.userId, onPinSet: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                    case .cardsSetup:
                        AdminView(onComplete: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                    case .main:
                        MainView()
                            .environmentObject(store)
                            .environmentObject(authManager)
                    }
                }
            }
            .onAppear {
                Task {
                    // Simulate async setup (replace with your real checks)
                    if let user = Auth.auth().currentUser {
                        await onboardingState.refreshState(for: user.uid)
                    } else {
                        onboardingState.userId = ""
                        onboardingState.didLogin = false
                        onboardingState.hasActiveSubscription = false
                        // Optionally reset other onboarding flags if needed
                    }
                    // Add a small delay to show the loading view (remove in production)
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    isAppReady = true
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
