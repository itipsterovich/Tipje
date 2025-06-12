import SwiftUI
import ActivityIndicatorView

struct DebugView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("didLogin") var didLogin: Bool = false
    @AppStorage("didRegister") var didRegister: Bool = false
    @AppStorage("hasActiveSubscription") var hasActiveSubscription: Bool = false
    @EnvironmentObject var store: Store
    @State private var showRestartAlert = false
    @State private var testUserId: String? = nil
    @State private var showKidsProfile = false
    @State private var showPinSetup = false
    @State private var isLoadingTestUser = false
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 12) {
                    Image("icon_debug")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("Debug Tools")
                        .font(.custom("Inter-Medium", size: 28))
                }
                SettingsSection(title: "Onboarding & Login") {
                    VStack(alignment: .trailing, spacing: 16) {
                        HStack(spacing: 16) {
                            DebugButton(title: "Mark Onboarding Complete") { didCompleteOnboarding = true }
                            DebugButton(title: "Reset Onboarding & Login") {
                                didCompleteOnboarding = false
                                didLogin = false
                                authManager.signOut()
                            }
                        }
                        Text("Current: \(didCompleteOnboarding ? "Complete" : "Not Complete") | Login: \(didLogin ? "Yes" : "No")")
                            .foregroundColor(.secondary)
                            .font(.custom("Inter-Regular_Medium", size: 20))
                    }
                }
                SettingsSection(title: "Registration") {
                    VStack(alignment: .trailing, spacing: 16) {
                        HStack(spacing: 16) {
                            DebugButton(title: "Mark Registered") { didRegister = true }
                            DebugButton(title: "Reset Registration") { didRegister = false }
                        }
                        Text("Current: \(didRegister ? "Registered" : "Not Registered")")
                            .foregroundColor(.secondary)
                            .font(.custom("Inter-Regular_Medium", size: 20))
                    }
                }
                SettingsSection(title: "Subscription") {
                    VStack(alignment: .trailing, spacing: 16) {
                        HStack(spacing: 16) {
                            DebugButton(title: "Activate Subscription") { hasActiveSubscription = true }
                            DebugButton(title: "Deactivate Subscription") { hasActiveSubscription = false }
                        }
                        Text("Current: \(hasActiveSubscription ? "Active" : "Inactive")")
                            .foregroundColor(.secondary)
                            .font(.custom("Inter-Regular_Medium", size: 20))
                    }
                }
                SettingsSection(title: "App State Shortcuts") {
                    VStack(alignment: .trailing, spacing: 16) {
                        DebugButton(title: "Go to Home (bypass onboarding)") {
                            didCompleteOnboarding = true
                            didRegister = true
                        }
                        DebugButton(title: "Skip Registration: Test Kids Profile & PIN") {
                            isLoadingTestUser = true
                            let newUserId = UUID().uuidString
                            let user = User(
                                id: newUserId,
                                email: "test+\(Int.random(in: 1000...9999))@tipje.app",
                                displayName: "Test User",
                                authProvider: nil,
                                pinHash: nil,
                                createdAt: nil,
                                updatedAt: nil,
                                pinFailedAttempts: nil,
                                pinLockoutUntil: nil
                            )
                            FirestoreManager.shared.createUser(user) { error in
                                // DispatchQueue.main.async(execute: {
                                    isLoadingTestUser = false
                                    if error == nil {
                                        testUserId = newUserId
                                        showKidsProfile = true
                                    }
                                // })
                            }
                        }
                        DebugButton(title: "Clear All UserDefaults") {
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            showRestartAlert = true
                        }
                        Text("Use these tools to simulate onboarding, registration, and subscription states. Useful for testing flows in the simulator.")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                SettingsSection(title: "Firestore Test") {
                    DebugButton(title: "Create Test User in Firestore") {
                        let user = User(
                            id: "testUserId",
                            email: "test@email.com",
                            displayName: "Test User",
                            authProvider: nil,
                            pinHash: nil,
                            createdAt: nil,
                            updatedAt: nil,
                            pinFailedAttempts: nil,
                            pinLockoutUntil: nil
                        )
                        FirestoreManager.shared.createUser(user) { error in
                            if let error = error {
                                print("Error: \(error)")
                            } else {
                                print("User created!")
                            }
                        }
                    }
                }
                SettingsSection(title: "Reset Scores & Tickets") {
                    VStack(alignment: .trailing, spacing: 16) {
                        DebugButton(title: "Reset all scores and tickets (for testing)") {
                            // Archive all active rules, chores, rewards
                            for rule in store.rules where rule.isActive { store.archiveRule(rule) }
                            for chore in store.chores where chore.isActive { store.archiveChore(chore) }
                            for reward in store.rewards where reward.isActive { store.archiveReward(reward) }
                            // Reset balance to zero for selected kid
                            if let kid = store.selectedKid {
                                let delta = -store.balance
                                if delta != 0 {
                                    let txn = Transaction(
                                        id: UUID().uuidString,
                                        type: "RESET_BALANCE",
                                        refId: kid.id,
                                        amount: delta,
                                        timestamp: Date(),
                                        note: "Reset balance from debug screen"
                                    )
                                    FirestoreManager.shared.updateBalanceAndLog(userId: store.userId, kidId: kid.id, delta: delta, txn: txn) { error in
                                        if let error = error {
                                            store.errorMessage = error.localizedDescription
                                        } else {
                                            store.fetchAllDataForSelectedKid()
                                        }
                                    }
                                }
                            }
                            // Reset onboarding modal flag
                            UserDefaults.standard.set(false, forKey: "adminOnboardingComplete")
                        }
                        Text("This will archive all rules, chores, and rewards, and allow you to see the onboarding modal again.")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }
            .padding(24)
        }
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text("Restart Required"),
                message: Text("All app data has been cleared. Please restart the app."),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $showKidsProfile, onDismiss: {
            testUserId = nil
        }) {
            if let userId = testUserId {
                KidsProfileView(userId: userId) {
                    showKidsProfile = false
                    showPinSetup = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPinSetup) {
            if let userId = testUserId {
                PinSetupView(userId: userId) {
                    showPinSetup = false
                }
            }
        }
        .overlay(
            Group {
                if isLoadingTestUser {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        VStack(spacing: 32) {
                            ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                                .frame(width: 140, height: 140)
                                .foregroundColor(Color(hex: "#799B44"))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
}

struct DebugButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter-Medium", size: 24))
                .foregroundColor(Color(hex: "#799B44"))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(hex: "#EAF3EA"))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView().environmentObject(Store())
    }
}
#endif 