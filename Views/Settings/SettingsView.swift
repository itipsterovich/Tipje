import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey?
    var trailingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil
    let content: () -> Content
    var customTitle: (() -> AnyView)? = nil
    var body: some View {
        HStack(alignment: .top) {
            if let customTitle = customTitle {
                customTitle()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let title = title {
                Text(title)
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                if let icon = trailingIcon {
                    IconButton(icon: icon, action: { onTrailingIconTap?() }, defaultColor: Color(hex: "#BCCDA1"), pressedColor: Color(hex: "#799B44"))
                }
            }
            content()
        }
        .padding(24)
        .background(Color(hex: "#EAF3EA").opacity(0.5))
        .cornerRadius(24)
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
    @State private var showEditKidsModal = false
    @State private var isEditingEmail = false
    @State private var isEditingPassword = false
    @State private var originalEmail: String = ""
    @State private var originalPassword: String = ""
    @State private var isPasswordVisible = false
    @State private var isEditMode = false
    @State private var emailError: String? = nil
    @State private var showAddEmailModal = false
    @State private var showChangePasswordModal = false
    @State private var showUnlinkGoogleAlert = false
    @State private var showUnlinkEmailAlert = false
    @State private var addEmail = ""
    @State private var addPassword = ""
    @State private var isEditingProfiles = false
    let languages = ["en": "English", "nl": "Nederlands"]

    private func updateEmailFromAuth() {
        if let userEmail = authManager.firebaseUser?.email, userEmail != email {
            email = userEmail
            originalEmail = userEmail
        }
    }

    private func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private var hasChanges: Bool {
        email != originalEmail || password != originalPassword
    }

    private var canSave: Bool {
        hasChanges && validateEmail(email)
    }

    private var isGoogleLinked: Bool {
        authManager.firebaseUser?.providerData.contains(where: { $0.providerID == "google.com" }) ?? false
    }
    private var isEmailLinked: Bool {
        authManager.firebaseUser?.providerData.contains(where: { $0.providerID == "password" }) ?? false
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                let totalWidth = UIScreen.main.bounds.width - 48 // 24pt padding each side
                let colWidth = totalWidth / 3
                BannerPanelLayout(
                    bannerColor: Color(hex: "#BCC4C3"),
                    bannerHeight: 100,
                    content: {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                PageTitle("Family Settings")
                                    .padding(.top, 24)
                                SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Login Methods")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .padding(.bottom, 8)
                                        HStack {
                                            HStack(spacing: 8) {
                                                Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                                                Text("Google")
                                                    .font(.custom("Inter-Regular", size: 24))
                                                    .foregroundColor(Color(hex: "#799B44"))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            if isGoogleLinked {
                                                ButtonText(title: "Unlink", variant: .secondary) {
                                                    showUnlinkGoogleAlert = true
                                                }
                                                .disabled(!isEmailLinked)
                                                .frame(maxWidth: .infinity)
                                            } else {
                                                ButtonText(title: "Link Account", variant: .secondary) {
                                                    isLinkingGoogle = true
                                                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                                        authManager.linkWithGoogle(presentingViewController: rootVC) { success, error in
                                                            isLinkingGoogle = false
                                                            alertMessage = success ? "Google account linked successfully." : (error ?? "Failed to link Google account.")
                                                            showAlert = true
                                                        }
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        HStack {
                                            Text("Email/Password")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if isEmailLinked {
                                                ButtonText(title: "Change Password", variant: .secondary) {
                                                    showChangePasswordModal = true
                                                }
                                                .frame(maxWidth: .infinity)
                                            } else {
                                                ButtonText(title: "Add", variant: .secondary) {
                                                    showAddEmailModal = true
                                                }
                                                .frame(maxWidth: .infinity)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }, customTitle: { AnyView(EmptyView()) })
                                SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Kids Profiles")
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .padding(.bottom, 8)
                                        ForEach(Array(store.kids.enumerated()), id: \ .element.id) { index, kid in
                                            HStack {
                                                Text(store.kids.count == 2 ? "Profile Name \(index + 1)" : "Profile Name")
                                                    .font(.custom("Inter-Regular", size: 24))
                                                    .foregroundColor(Color(hex: "#799B44"))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(kid.name)
                                                    .font(.custom("Inter-Regular", size: 24))
                                                    .foregroundColor(Color(hex: "#7FAD98"))
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        ButtonText(title: "Edit Profiles", variant: .secondary) {
                                            showEditKidsModal = true
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }, customTitle: { AnyView(EmptyView()) })
                                SettingsSection(title: "settings_language", trailingIcon: nil, onTrailingIconTap: nil, content: {
                                    HStack {
                                        Spacer()
                                        DropdownRegular(
                                            selection: $selectedLanguage,
                                            options: languages.keys.sorted(),
                                            display: { code in languages[code] ?? code }
                                        )
                                        .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                                    }
                                }, customTitle: { AnyView(HStack(alignment: .center, spacing: 4) {
                                    Text("settings_language")
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        .foregroundColor(Color(hex: "#799B44"))
                                }) })
                                SettingsSection(title: "settings_subscription", trailingIcon: nil, onTrailingIconTap: nil, content: {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Plan")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("Premium Monthly")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#7FAD98"))
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        HStack {
                                            Text("Status")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("Subscribed")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#7FAD98"))
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        HStack {
                                            Text("Next Billing Date")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("June 27, 2024")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#7FAD98"))
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        ButtonText(title: "Manage Subscription", variant: .secondary) {
                                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }, customTitle: { AnyView(EmptyView()) })
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                            ButtonText(title: String(localized: "settings_logout"), variant: .primary) {
                                showLogoutAlert = true
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                    }
                )
            }
        }
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 0)
        .fullScreenCover(isPresented: $showEditKidsModal) {
            KidsProfileView(
                userId: store.userId,
                onNext: {
                    showEditKidsModal = false
                    store.fetchKids()
                },
                initialKids: store.kids
            )
        }
        .onAppear {
            updateEmailFromAuth()
            originalPassword = password
        }
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
        .alert(isPresented: $showUnlinkGoogleAlert) {
            Alert(title: Text("Unlink Google?"), message: Text("Are you sure you want to unlink your Google account? You must have another login method linked."), primaryButton: .destructive(Text("Unlink"), action: {
                authManager.unlinkGoogle { success, error in
                    alertMessage = success ? "Google account unlinked successfully." : (error ?? "Failed to unlink Google account.")
                    showAlert = true
                }
            }), secondaryButton: .cancel())
        }
        .alert(isPresented: $showUnlinkEmailAlert) {
            Alert(title: Text("Unlink Email/Password?"), message: Text("Are you sure you want to unlink your email/password? You must have another login method linked."), primaryButton: .destructive(Text("Unlink"), action: {
                alertMessage = "Email/Password unlinked (implement logic)"
                showAlert = true
            }), secondaryButton: .cancel())
        }
        .sheet(isPresented: $showAddEmailModal) {
            VStack(spacing: 16) {
                Text("Add Email/Password").font(.title2)
                TextField("Email", text: $addEmail).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $addPassword).textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    showAddEmailModal = false
                    alertMessage = "Email/Password added (implement logic)"
                    showAlert = true
                }
                Button("Cancel") { showAddEmailModal = false }
            }.padding()
        }
        .sheet(isPresented: $showChangePasswordModal) {
            VStack(spacing: 24) {
                Image("change_pas")
                    .resizable()
                    .frame(width: 192, height: 192)
                    .scaledToFit()
                    .padding(.top, 8)
                Text("Change Password")
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#799B44"))
                CustomInputField(
                    placeholder: "New Password",
                    text: $newPassword,
                    isSecure: true
                )
                ButtonText(title: "Change", variant: .primary) {
                    showChangePasswordModal = false
                    alertMessage = "Password changed (implement logic)"
                    showAlert = true
                }
                ButtonText(title: "Cancel", variant: .secondary) {
                    showChangePasswordModal = false
                }
            }
            .padding(40)
        }
    }
}

struct CustomInputField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int? = nil
    var isDisabled: Bool = false
    var showActualPassword: Bool = false
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecure {
                    if showActualPassword {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .focused($isFocused)
                            .disabled(isDisabled)
                    } else {
                        SecureField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .focused($isFocused)
                            .disabled(isDisabled)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                        .disabled(isDisabled)
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
