import SwiftUI

enum SettingsAlertType: Identifiable {
    case logout, deleteAccount, deleteKid, unlinkGoogle, unlinkEmail, custom(String)
    var id: String {
        switch self {
        case .logout: return "logout"
        case .deleteAccount: return "deleteAccount"
        case .deleteKid: return "deleteKid"
        case .unlinkGoogle: return "unlinkGoogle"
        case .unlinkEmail: return "unlinkEmail"
        case .custom(let msg): return msg
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey?
    var trailingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil
    let content: () -> Content
    var customTitle: (() -> AnyView)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
                    .padding(.top, 4)
                    .padding(.bottom, 0)
                if let icon = trailingIcon {
                    IconButton(icon: icon, action: { onTrailingIconTap?() }, defaultColor: Color(hex: "#BCCDA1"), pressedColor: Color(hex: "#799B44"))
                }
            }
            VStack(alignment: .leading, spacing: 0) {
            content()
            }
            .padding(.horizontal, horizontalSizeClass == .compact ? 0 : 12)
            .padding(.vertical, horizontalSizeClass == .compact ? 0 : 12)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 24)
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView: View {
    @StateObject var authManager = AuthManager()
    @EnvironmentObject var store: Store
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
    @State private var activeAlert: SettingsAlertType?
    @State private var showDeleteAccountModal = false
    @State private var showRestartAlert = false
    @StateObject private var languageManager = LanguageManager.shared
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
        NavigationView {
            List {
                Section {
                    DropdownRegular(
                        title: NSLocalizedString("settings_language", comment: "Language setting title"),
                        options: languageManager.supportedLanguages.map { $0.name },
                        selectedOption: languageManager.getCurrentLanguageName(),
                        onOptionSelected: { selectedName in
                            if let language = languageManager.supportedLanguages.first(where: { $0.name == selectedName }) {
                                languageManager.setLanguage(language.code)
                                showRestartAlert = true
                            }
                        }
                    )
                } header: {
                    Text(NSLocalizedString("settings_language", comment: "Language section header"))
                }
                
                Section {
                    SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                        loginMethodsSection
                    })
                }
                
                Section {
                    planStatusTable
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: "Settings screen title"))
            .alert(isPresented: $showRestartAlert) {
                Alert(
                    title: Text(NSLocalizedString("language_change_title", comment: "Language change alert title")),
                    message: Text(NSLocalizedString("language_change_message", comment: "Language change alert message")),
                    primaryButton: .default(Text(NSLocalizedString("restart_now", comment: "Restart now button"))) {
                        exit(0)
                    },
                    secondaryButton: .cancel(Text(NSLocalizedString("restart_later", comment: "Restart later button")))
                )
            }
        }
    }

    // Extracted Login Methods section
    private var loginMethodsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Login Methods")
                .font(.custom("Inter-Regular_Medium", size: 17))
                .foregroundColor(Color(hex: "#799B44"))
                .padding(.top, 0)
                .padding(.bottom, 8)
            if isGoogleLinked {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                        Text("Google")
                            .font(.custom("Inter-Regular", size: 17))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        ButtonTextiPhone(title: "Unlink", variant: .secondary) {
                            showUnlinkGoogleAlert = true
                        }
                        .disabled(!isEmailLinked)
                        .frame(maxWidth: .infinity)
                        .font(.custom("Inter-Regular_Medium", size: 17))
                    }
                }
                .frame(maxWidth: .infinity)
            } else if isEmailLinked {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Text("Email/Password")
                            .font(.custom("Inter-Regular", size: 17))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ButtonTextiPhone(title: "Change Password", variant: .secondary) {
                            showChangePasswordModal = true
                        }
                        .frame(maxWidth: .infinity)
                        .font(.custom("Inter-Regular_Medium", size: 17))
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                        Text("Google")
                            .font(.custom("Inter-Regular", size: 17))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ButtonTextiPhone(title: "Link Account", variant: .secondary) {
                        isLinkingGoogle = true
                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                            authManager.linkWithGoogle(presentingViewController: rootVC) { success, error in
                                isLinkingGoogle = false
                                alertMessage = success ? "Google account linked successfully." : (error ?? "Failed to link Google account.")
                                activeAlert = .custom(alertMessage)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .font(.custom("Inter-Regular_Medium", size: 17))
                    Text("Email/Password")
                        .font(.custom("Inter-Regular", size: 17))
                        .foregroundColor(Color(hex: "#799B44"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ButtonTextiPhone(title: "Add", variant: .secondary) {
                        showAddEmailModal = true
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom("Inter-Regular_Medium", size: 17))
                }
                .frame(maxWidth: .infinity)
            }
            Text("Kids Profiles")
                .font(.custom("Inter-Regular_Medium", size: 17))
                .foregroundColor(Color(hex: "#799B44"))
                .padding(.top, 14)
                .padding(.bottom, 14)
            ForEach(Array(store.kids.enumerated()), id: \.element.id) { index, kid in
                HStack {
                    Text(store.kids.count == 2 ? "Profile Name \(index + 1)" : "Profile Name")
                        .font(.custom("Inter-Regular", size: 17))
                        .foregroundColor(Color(hex: "#799B44"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(kid.name)
                        .font(.custom("Inter-Regular", size: 17))
                        .foregroundColor(Color(hex: "#7FAD98"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
            }
            ButtonTextiPhone(title: "Edit Profiles", variant: .secondary) {
                print("[Settings] Edit Profiles button tapped")
                showEditKidsModal = true
            }
            .frame(maxWidth: .infinity)
            .font(.custom("Inter-Regular_Medium", size: 17))
        }
    }

    // Extracted Plan/Status Table section
    private var planStatusTable: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Plan")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Premium Monthly")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#7FAD98"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text("Status")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Subscribed")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#7FAD98"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text("Next Billing Date")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("June 27, 2024")
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#7FAD98"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 12) {
                ButtonTextiPhone(title: "Manage Subscription", variant: .secondary) {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.custom("Inter-Regular_Medium", size: 17))
                VStack(alignment: .center) {
                    ButtonTextiPhone(title: String(localized: "settings_logout"), variant: .primary) {
                        print("[Settings] Logout button action triggered")
                        authManager.signOut()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom("Inter-Regular_Medium", size: 17))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.bottom, 24)
    }
}

// =======================
// iPhone layout
// =======================
struct SettingsViewiPhone: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var store: Store
    @Binding var selectedLanguage: String
    @Binding var showChangeEmail: Bool
    @Binding var showChangePassword: Bool
    @Binding var showChangePIN: Bool
    @Binding var showChangePinModal: Bool
    @Binding var showSubscription: Bool
    @Binding var showRestorePurchases: Bool
    @Binding var showLogoutAlert: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var newPassword: String
    @Binding var pin: String
    @Binding var subscriptionType: String
    @Binding var cardNumber: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var isLinkingGoogle: Bool
    @Binding var isUnlinkingGoogle: Bool
    @Binding var showDeleteKidAlert: Bool
    @Binding var kidToDelete: Kid?
    @Binding var isEditingPin: Bool
    @Binding var newPin: String
    @Binding var pinChangeError: String?
    @Binding var pinChangeSuccess: Bool
    @Binding var showEditKidsModal: Bool
    @Binding var isEditingEmail: Bool
    @Binding var isEditingPassword: Bool
    @Binding var originalEmail: String
    @Binding var originalPassword: String
    @Binding var isPasswordVisible: Bool
    @Binding var isEditMode: Bool
    @Binding var emailError: String?
    @Binding var showAddEmailModal: Bool
    @Binding var showChangePasswordModal: Bool
    @Binding var showUnlinkGoogleAlert: Bool
    @Binding var showUnlinkEmailAlert: Bool
    @Binding var addEmail: String
    @Binding var addPassword: String
    @Binding var isEditingProfiles: Bool
    @State private var showDeleteAccountModal = false
    @State private var activeAlert: SettingsAlertType?
    let languages: [String: String]
    let updateEmailFromAuth: () -> Void
    let validateEmail: (String) -> Bool
    let hasChanges: Bool
    let canSave: Bool
    let isGoogleLinked: Bool
    let isEmailLinked: Bool

    var body: some View {
        let content = ScrollView {
            BannerPanelLayout(
                bannerColor: Color(hex: "#BCC4C3"),
                bannerHeight: 100,
                containerOffsetY: -36,
                content: {
                    VStack(alignment: .leading, spacing: 14) {
                        PageTitle("Family Settings")
                            .padding(.top, 14)
                            .padding(.bottom, 0)
                        Group {
                            SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                                loginMethodsSection
                            })
                        }
                        .background(Color(hex: "#EAF3EA").opacity(0.5))
                        .cornerRadius(24)
                        planStatusTable
                    }
                    .ignoresSafeArea(.container, edges: .horizontal)
                }
            )
        }
        content
            .fullScreenCover(isPresented: $showEditKidsModal) {
                KidsProfileView(
                    userId: store.userId,
                    onNext: {
                        print("[Settings] KidsProfileView onNext called, dismissing modal and fetching kids")
                        showEditKidsModal = false
                        store.fetchKids()
                    },
                    initialKids: store.kids
                )
                .onAppear {
                    print("[Settings] fullScreenCover for KidsProfileView is presented")
                }
            }
    }
}

// =======================
// iPad layout
// =======================
struct SettingsViewiPad: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var store: Store
    @Binding var selectedLanguage: String
    @Binding var showChangeEmail: Bool
    @Binding var showChangePassword: Bool
    @Binding var showChangePIN: Bool
    @Binding var showChangePinModal: Bool
    @Binding var showSubscription: Bool
    @Binding var showRestorePurchases: Bool
    @Binding var showLogoutAlert: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var newPassword: String
    @Binding var pin: String
    @Binding var subscriptionType: String
    @Binding var cardNumber: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var isLinkingGoogle: Bool
    @Binding var isUnlinkingGoogle: Bool
    @Binding var showDeleteKidAlert: Bool
    @Binding var kidToDelete: Kid?
    @Binding var isEditingPin: Bool
    @Binding var newPin: String
    @Binding var pinChangeError: String?
    @Binding var pinChangeSuccess: Bool
    @Binding var showEditKidsModal: Bool
    @Binding var isEditingEmail: Bool
    @Binding var isEditingPassword: Bool
    @Binding var originalEmail: String
    @Binding var originalPassword: String
    @Binding var isPasswordVisible: Bool
    @Binding var isEditMode: Bool
    @Binding var emailError: String?
    @Binding var showAddEmailModal: Bool
    @Binding var showChangePasswordModal: Bool
    @Binding var showUnlinkGoogleAlert: Bool
    @Binding var showUnlinkEmailAlert: Bool
    @Binding var addEmail: String
    @Binding var addPassword: String
    @Binding var isEditingProfiles: Bool
    @State private var showDeleteAccountModal = false
    @State private var activeAlert: SettingsAlertType?
    let languages: [String: String]
    let updateEmailFromAuth: () -> Void
    let validateEmail: (String) -> Bool
    let hasChanges: Bool
    let canSave: Bool
    let isGoogleLinked: Bool
    let isEmailLinked: Bool

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#BCC4C3"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(alignment: .leading, spacing: 14) {
                    PageTitle("Family Settings")
                        .padding(.top, 14)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 24)
                    Group {
                        SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Login Methods")
                                    .font(.custom("Inter-Regular_Medium", size: 24))
                                    .foregroundColor(Color(hex: "#799B44"))
                                    .padding(.top, 0)
                                    .padding(.bottom, 8)
                                if isGoogleLinked {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack(spacing: 8) {
                                            Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                                            Text("Google")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            ButtonText(title: "Unlink", variant: .secondary) {
                                                showUnlinkGoogleAlert = true
                                            }
                                            .disabled(!isEmailLinked)
                                            .frame(maxWidth: .infinity)
                                            .font(.custom("Inter-Regular_Medium", size: 24))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                } else if isEmailLinked {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack(spacing: 8) {
                                            Text("Email/Password")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            ButtonText(title: "Change Password", variant: .secondary) {
                                                showChangePasswordModal = true
                                            }
                                                    .frame(maxWidth: .infinity)
                                                    .font(.custom("Inter-Regular_Medium", size: 24))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack(spacing: 8) {
                                            Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                                            Text("Google")
                                                .font(.custom("Inter-Regular", size: 24))
                                                .foregroundColor(Color(hex: "#799B44"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        ButtonText(title: "Link Account", variant: .secondary) {
                                            isLinkingGoogle = true
                                            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                                authManager.linkWithGoogle(presentingViewController: rootVC) { success, error in
                                                    isLinkingGoogle = false
                                                    alertMessage = success ? "Google account linked successfully." : (error ?? "Failed to link Google account.")
                                                    activeAlert = .custom(alertMessage)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        Text("Email/Password")
                                            .font(.custom("Inter-Regular", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        ButtonText(title: "Add", variant: .secondary) {
                                            showAddEmailModal = true
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                }
                                Spacer().frame(height: 12)
                                Text("Kids Profiles")
                                    .font(.custom("Inter-Regular_Medium", size: 24))
                                    .foregroundColor(Color(hex: "#799B44"))
                                    .padding(.top, 14)
                                    .padding(.bottom, 14)
                                ForEach(Array(store.kids.enumerated()), id: \.element.id) { index, kid in
                                    HStack {
                                        Text(store.kids.count == 2 ? "Profile Name \(index + 1)" : "Profile Name")
                                            .font(.custom("Inter-Regular", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(kid.name)
                                            .font(.custom("Inter-Regular", size: 24))
                                            .foregroundColor(Color(hex: "#7FAD98"))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                ButtonText(title: "Edit Profiles", variant: .secondary) {
                                    print("[Settings] Edit Profiles button tapped")
                                    showEditKidsModal = true
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .font(.custom("Inter-Regular_Medium", size: 24))
                                Spacer().frame(height: 12)
                                HStack(alignment: .center, spacing: 4) {
                                    Text("settings_language")
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .padding(.top, 14)
                                        .padding(.bottom, 8)
                                }
                                DropdownRegular(
                                    selection: $selectedLanguage,
                                    options: languages.keys.sorted(),
                                    display: { code in languages[code] ?? code }
                                )
                                .frame(maxWidth: .infinity, minHeight: 44)
                            }
                        }, customTitle: { AnyView(EmptyView()) })
                    }
                    .background(Color(hex: "#EAF3EA").opacity(0.5))
                    .cornerRadius(24)
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 12)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Plan")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Premium Monthly")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#7FAD98"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 48)
                        HStack {
                            Text("Status")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Subscribed")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#7FAD98"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 48)
                        HStack {
                            Text("Next Billing Date")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("June 27, 2024")
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#7FAD98"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 48)
                        .padding(.bottom, 24)
                        VStack(alignment: .leading, spacing: 24) {
                            ButtonText(title: "Manage Subscription", variant: .secondary) {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, 24)
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            ButtonText(title: String(localized: "settings_logout"), variant: .primary) {
                                print("[Settings] Logout button action triggered")
                                authManager.signOut()
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, 24)
                            .font(.custom("Inter-Regular_Medium", size: 24))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(.container, edges: .horizontal)
            }
        )
        .fullScreenCover(isPresented: $showEditKidsModal) {
            KidsProfileView(
                userId: store.userId,
                onNext: {
                    print("[Settings] KidsProfileView onNext called, dismissing modal and fetching kids")
                    showEditKidsModal = false
                    store.fetchKids()
                },
                initialKids: store.kids
            )
            .onAppear {
                print("[Settings] fullScreenCover for KidsProfileView is presented")
            }
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

struct DropdownRegulariPhone<T: Hashable>: View {
    @Binding var selection: T
    var options: [T]
    var display: (T) -> String
    @State private var showMenu = false

    var body: some View {
        Button(action: { showMenu = true }) {
            HStack {
                Text(display(selection))
                    .font(.custom("Inter-Regular_Medium", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                Spacer()
                Image("icon_she")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(width: 20, height: 20)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .frame(minHeight: 44)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#799B44"), lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showMenu) {
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        showMenu = false
                    }) {
                        Text(display(option))
                            .font(.custom("Inter-Regular_Medium", size: 17))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    if option != options.last {
                        Divider()
                    }
                }
            }
            .background(Color.white)
            .presentationDetents([.height(CGFloat(options.count) * 56 + 16)])
        }
    }
}

struct ButtonTextiPhone: View {
    let title: String
    let variant: ButtonTextVariant
    let action: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter-Regular_Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                .foregroundColor(variant == .primary ? Color.white : Color(hex: "#799B44"))
                .frame(minWidth: horizontalSizeClass == .compact ? 0 : 120, minHeight: 44)
                .padding(.horizontal, horizontalSizeClass == .compact ? 18 : 24)
                .background(
                    variant == .primary ? Color(hex: "#799B44") : Color(hex: "#EAF3EA")
                )
                .cornerRadius(horizontalSizeClass == .compact ? 12 : 20)
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
