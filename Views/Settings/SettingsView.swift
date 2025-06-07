import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    let content: () -> Content
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.custom("Inter-Regular_Medium", size: 24))
                .foregroundColor(Color(hex: "#799B44"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            content()
        }
        .padding(24)
        .background(Color(hex: "#EAF3EA"))
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView: View {
    @StateObject var authManager = AuthManager()
    @EnvironmentObject var store: Store
    @State private var selectedLanguage: String = Locale.current.languageCode ?? "en"
    @State private var showChangeEmail = false
    @State private var showChangePassword = false
    @State private var showChangePIN = false
    @State private var showChangePinModal = false
    @State private var showSubscription = false
    @State private var showRestorePurchases = false
    @State private var showLogoutAlert = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var pin: String = ""
    @State private var subscriptionType: String = "Monthly"
    @State private var cardNumber: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLinkingGoogle = false
    @State private var isUnlinkingGoogle = false
    @State private var showDeleteKidAlert = false
    @State private var kidToDelete: Kid? = nil
    @State private var isEditingPin = false
    @State private var newPin = ""
    @State private var pinChangeError: String? = nil
    @State private var pinChangeSuccess = false
    let languages = ["en": "English", "nl": "Nederlands"]

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#BCC4C3"),
            bannerHeight: 100,
            content: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        PageTitle("settings_title")
                            .padding(.top, 24)
                        // Account Section
                        SettingsSection(title: "settings_account") {
                            VStack(alignment: .trailing, spacing: 0) {
                                HStack(alignment: .top, spacing: 0) {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 16) {
                                        CustomInputField(placeholder: "Email", text: $email)
                                        CustomInputField(placeholder: "Password", text: $password, isSecure: true)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                                }
                                HStack(alignment: .center, spacing: 24) {
                                    Button(action: {
                                        // Change Password
                                        if password.isEmpty || newPassword.isEmpty {
                                            alertMessage = String(localized: "Please enter current and new password.")
                                            showAlert = true
                                            return
                                        }
                                        authManager.changePassword(currentPassword: password, newPassword: newPassword) { success, error in
                                            if success {
                                                alertMessage = String(localized: "settings_change_password") + " " + String(localized: "pin_success")
                                            } else {
                                                alertMessage = error ?? String(localized: "pin_fail")
                                            }
                                            showAlert = true
                                        }
                                    }) {
                                        Text("settings_change_password")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button(action: {
                                        // Change Email
                                        if email.isEmpty || password.isEmpty {
                                            alertMessage = String(localized: "Please enter new email and current password.")
                                            showAlert = true
                                            return
                                        }
                                        authManager.changeEmail(newEmail: email, password: password) { success, error in
                                            if success {
                                                alertMessage = String(localized: "settings_change_email") + " " + String(localized: "pin_success")
                                            } else {
                                                alertMessage = error ?? String(localized: "pin_fail")
                                            }
                                            showAlert = true
                                        }
                                    }) {
                                        Text("settings_change_email")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.top, 12)
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48, alignment: .leading)
                                Button(action: { showLogoutAlert = true }) {
                                    Text("settings_logout")
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        .foregroundColor(.red)
                                        .underline()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.top, 12)
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48, alignment: .leading)
                            }
                        }
                        SettingsSection(title: "settings_link_google") {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 16) {
                                    Button(action: {
                                        isLinkingGoogle = true
                                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                            authManager.linkWithGoogle(presentingViewController: rootVC) { success, error in
                                                isLinkingGoogle = false
                                                if success {
                                                    alertMessage = String(localized: "Google account linked successfully.")
                                                } else {
                                                    alertMessage = error ?? String(localized: "Failed to link Google account.")
                                                }
                                                showAlert = true
                                            }
                                        }
                                    }) {
                                        Text("settings_link_google")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button(action: {
                                        isUnlinkingGoogle = true
                                        authManager.unlinkGoogle { success, error in
                                            isUnlinkingGoogle = false
                                            if success {
                                                alertMessage = String(localized: "Google account unlinked successfully.")
                                            } else {
                                                alertMessage = error ?? String(localized: "Failed to unlink Google account.")
                                            }
                                            showAlert = true
                                        }
                                    }) {
                                        Text("settings_unlink_google")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                            }
                        }
                        SettingsSection(title: "settings_kids") {
                            VStack(alignment: .trailing, spacing: 0) {
                                ForEach(store.kids) { kid in
                                    HStack {
                                        Text(kid.name)
                                            .font(.custom("Inter-Regular_Medium", size: 20))
                                            .foregroundColor(Color(hex: "#799B44"))
                                        Spacer()
                                        Button(action: {
                                            kidToDelete = kid
                                            showDeleteKidAlert = true
                                        }) {
                                            Text("settings_delete_kid")
                                                .foregroundColor(.red)
                                                .underline()
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        SettingsSection(title: "settings_language") {
                            HStack {
                                Spacer()
                                CustomDropdown(
                                    title: String(localized: "settings_language"),
                                    selection: $selectedLanguage,
                                    options: languages.keys.sorted(),
                                    display: { code in languages[code] ?? code }
                                )
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                            }
                        }
                        SettingsSection(title: "settings_subscription") {
                            VStack(alignment: .trailing, spacing: 16) {
                                HStack {
                                    Spacer()
                                    CustomDropdown(
                                        title: String(localized: "settings_subscription"),
                                        selection: $subscriptionType,
                                        options: ["Monthly", "Yearly"],
                                        display: { $0 },
                                        isDisabled: true
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                                }
                                HStack {
                                    Spacer()
                                    CustomInputField(placeholder: "Card Number", text: $cardNumber, keyboardType: .numberPad)
                                        .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                                }
                            }
                        }
                        SettingsSection(title: "settings_app_info") {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Version")
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    CustomInputField(placeholder: "App Version", text: .constant(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"), keyboardType: .default)
                                        .disabled(true)
                                        .opacity(0.5)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .font(.custom("Inter-Regular_Medium", size: 20))
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("settings_title"), message: Text(alertMessage), dismissButton: .default(Text("ok")))
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(title: Text("settings_logout"), message: Text(String(localized: "Are you sure you want to log out?")), primaryButton: .destructive(Text("settings_logout"), action: {
                        authManager.signOut()
                    }), secondaryButton: .cancel(Text("cancel")))
                }
                .alert(isPresented: $showDeleteKidAlert) {
                    Alert(
                        title: Text("settings_delete_kid"),
                        message: Text("settings_delete_kid_confirm"),
                        primaryButton: .destructive(Text("settings_delete_kid"), action: {
                            if let kid = kidToDelete {
                                store.deleteKid(kid) { success in
                                    if success {
                                        alertMessage = String(localized: "settings_delete_kid_success")
                                    } else {
                                        alertMessage = String(localized: "settings_delete_kid_fail")
                                    }
                                    showAlert = true
                                }
                            }
                        }),
                        secondaryButton: .cancel(Text("cancel"))
                    )
                }
            }
        )
    }
}

struct CustomInputField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int? = nil
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                }
            }
            .onChange(of: text) { newValue in
                if let maxLength = maxLength, newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                }
            }
            .font(.custom("Inter-Regular_Medium", size: 24))
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(Color(hex: "#F7FBFF"))
            .foregroundColor(Color(hex: "#799B44"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? Color(hex: "#799B44") : Color(hex: "#D4D7E3"), lineWidth: 1.5)
            )
            .cornerRadius(16)
            if isSecure {
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(Color(hex: "#799B44"))
                }
                .padding(.trailing, 20)
            }
        }
    }
}

struct CustomDropdown<T: Hashable>: View {
    var title: String
    @Binding var selection: T
    var options: [T]
    var display: (T) -> String
    var isDisabled: Bool = false
    @State private var showMenu = false

    var body: some View {
        Button(action: { if !isDisabled { showMenu = true } }) {
            HStack {
                Text(display(selection))
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#799B44"))
                Spacer()
                Image("icon_she")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#799B44"), lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .disabled(isDisabled)
        .sheet(isPresented: $showMenu) {
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        showMenu = false
                    }) {
                        Text(display(option))
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    Divider()
                }
                Button("Cancel") {
                    showMenu = false
                }
                .font(.custom("Inter-Regular_Medium", size: 24))
                .foregroundColor(.red)
                .padding()
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif 