import SwiftUI

struct DebugView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("didRegister") var didRegister: Bool = false
    @AppStorage("hasActiveSubscription") var hasActiveSubscription: Bool = false
    @EnvironmentObject var store: Store
    @State private var showRestartAlert = false

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
                SettingsSection(title: "Onboarding") {
                    VStack(alignment: .trailing, spacing: 16) {
                        HStack(spacing: 16) {
                            DebugButton(title: "Mark Onboarding Complete") { didCompleteOnboarding = true }
                            DebugButton(title: "Reset Onboarding") { didCompleteOnboarding = false }
                        }
                        Text("Current: \(didCompleteOnboarding ? "Complete" : "Not Complete")")
                            .foregroundColor(.secondary)
                            .font(.custom("Inter-Medium", size: 20))
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
                            .font(.custom("Inter-Medium", size: 20))
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
                            .font(.custom("Inter-Medium", size: 20))
                    }
                }
                SettingsSection(title: "App State Shortcuts") {
                    VStack(alignment: .trailing, spacing: 16) {
                        DebugButton(title: "Go to Home (bypass onboarding)") {
                            didCompleteOnboarding = true
                            didRegister = true
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