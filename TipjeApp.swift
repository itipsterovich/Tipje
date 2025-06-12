import SwiftUI
import SwiftData
import FirebaseCore

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
                    OnboardingView()
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                } else if onboardingState.isLoading {
                    ProgressView("Loading...")
                        .onAppear {
                            onboardingState.checkOnboardingState(userId: authManager.firebaseUser?.uid ?? "")
                        }
                } else if onboardingState.needsOnboarding {
                    OnboardingView()
                        .environmentObject(store)
                        .environmentObject(authManager)
                        .environmentObject(onboardingState)
                } else {
                    MainView()
                        .environmentObject(store)
                        .environmentObject(authManager)
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
