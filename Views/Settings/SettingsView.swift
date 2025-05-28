import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage: String = Locale.current.languageCode ?? "en"
    @State private var showChangeEmail = false
    @State private var showChangePassword = false
    @State private var showChangePIN = false
    @State private var showForgotPIN = false
    @State private var showSubscription = false
    @State private var showRestorePurchases = false
    @State private var showLogoutAlert = false

    let languages = ["en": "English", "nl": "Nederlands"]

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#BCC4C3"),
            bannerHeight: 100,
            content: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        PageTitle("Settings")
                            .padding(.top, 24)
                        GroupBox(label: Text("Account").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("Change Email") { showChangeEmail = true }
                                Button("Change Password") { showChangePassword = true }
                                Button("Log Out") { showLogoutAlert = true }
                            }
                        }
                        GroupBox(label: Text("Security").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("Change PIN") { showChangePIN = true }
                                Button("Forgot PIN?") { showForgotPIN = true }
                            }
                        }
                        GroupBox(label: Text("Language").bold()) {
                            Picker("Language", selection: $selectedLanguage) {
                                ForEach(languages.keys.sorted(), id: \.self) { code in
                                    Text(languages[code] ?? code).tag(code)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        GroupBox(label: Text("Subscription").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("Manage Subscription") { showSubscription = true }
                                Button("Restore Purchases") { showRestorePurchases = true }
                            }
                        }
                        GroupBox(label: Text("App Info").bold()) {
                            HStack {
                                Text("App Version")
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .font(.custom("Inter-Medium", size: 20))
                .alert(isPresented: $showLogoutAlert) {
                    Alert(title: Text("Log Out"), message: Text("Are you sure you want to log out?"), primaryButton: .destructive(Text("Log Out")), secondaryButton: .cancel())
                }
            }
        )
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif 