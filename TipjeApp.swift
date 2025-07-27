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
    @StateObject var localizationManager = LocalizationManager.shared
    
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
                            .environmentObject(localizationManager)
                    case .subscription:
                        SubscriptionView(onPlanSelected: { plan in
                            onboardingState.hasActiveSubscription = true
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                            .environmentObject(store)
                            .environmentObject(authManager)
                            .environmentObject(onboardingState)
                            .environmentObject(localizationManager)
                    case .kidsProfile:
                        KidsProfileView(userId: onboardingState.userId, onNext: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                        .environmentObject(localizationManager)
                    case .pinSetup:
                        PinSetupView(userId: onboardingState.userId, onPinSet: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                        .environmentObject(localizationManager)
                    case .cardsSetup:
                        AdminView(onComplete: {
                            onboardingState.refreshState(for: onboardingState.userId)
                        })
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                        .environmentObject(localizationManager)
                    case .main:
                        MainView()
                            .environmentObject(store)
                            .environmentObject(authManager)
                            .environmentObject(onboardingState)
                            .environmentObject(localizationManager)
                    }
                }
            }
            .preferredColorScheme(.light)
            .onAppear {
                // App is ready after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAppReady = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Refresh subscription status when app becomes active (catches promo code redemptions)
                if onboardingState.didLogin {
                    Task {
                        await onboardingState.refreshSubscriptionStatus()
                    }
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
