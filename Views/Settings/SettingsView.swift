import SwiftUI
import Combine

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
    @EnvironmentObject var store: TipjeStore
    @EnvironmentObject var onboardingState: OnboardingStateManager
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
    @State private var showDeleteAccountAlert = false
    let languages = [
        "en": NSLocalizedString("English", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
        "nl": NSLocalizedString("Nederlands", tableName: nil, bundle: Bundle.main, value: "", comment: "")
    ]

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
        Group {
            if horizontalSizeClass == .compact {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                SettingsViewiPhone(
                    authManager: authManager,
                    store: store,
                    selectedLanguage: $selectedLanguage,
                    showChangeEmail: $showChangeEmail,
                    showChangePassword: $showChangePassword,
                    showChangePIN: $showChangePIN,
                    showChangePinModal: $showChangePinModal,
                    showSubscription: $showSubscription,
                    showRestorePurchases: $showRestorePurchases,
                    showLogoutAlert: $showLogoutAlert,
                    email: $email,
                    password: $password,
                    newPassword: $newPassword,
                    pin: $pin,
                    subscriptionType: $subscriptionType,
                    cardNumber: $cardNumber,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    isLinkingGoogle: $isLinkingGoogle,
                    isUnlinkingGoogle: $isUnlinkingGoogle,
                    showDeleteKidAlert: $showDeleteKidAlert,
                    kidToDelete: $kidToDelete,
                    isEditingPin: $isEditingPin,
                    newPin: $newPin,
                    pinChangeError: $pinChangeError,
                    pinChangeSuccess: $pinChangeSuccess,
                    showEditKidsModal: $showEditKidsModal,
                    isEditingEmail: $isEditingEmail,
                    isEditingPassword: $isEditingPassword,
                    originalEmail: $originalEmail,
                    originalPassword: $originalPassword,
                    isPasswordVisible: $isPasswordVisible,
                    isEditMode: $isEditMode,
                    emailError: $emailError,
                    showAddEmailModal: $showAddEmailModal,
                    showChangePasswordModal: $showChangePasswordModal,
                    showUnlinkGoogleAlert: $showUnlinkGoogleAlert,
                    showUnlinkEmailAlert: $showUnlinkEmailAlert,
                    addEmail: $addEmail,
                    addPassword: $addPassword,
                    isEditingProfiles: $isEditingProfiles,
                    languages: languages,
                    updateEmailFromAuth: updateEmailFromAuth,
                    validateEmail: validateEmail,
                    hasChanges: hasChanges,
                    canSave: canSave,
                    isGoogleLinked: isGoogleLinked,
                    isEmailLinked: isEmailLinked
                )
                    }
                }
            } else {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                SettingsViewiPad(
                    authManager: authManager,
                    store: store,
                    selectedLanguage: $selectedLanguage,
                    showChangeEmail: $showChangeEmail,
                    showChangePassword: $showChangePassword,
                    showChangePIN: $showChangePIN,
                    showChangePinModal: $showChangePinModal,
                    showSubscription: $showSubscription,
                    showRestorePurchases: $showRestorePurchases,
                    showLogoutAlert: $showLogoutAlert,
                    email: $email,
                    password: $password,
                    newPassword: $newPassword,
                    pin: $pin,
                    subscriptionType: $subscriptionType,
                    cardNumber: $cardNumber,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    isLinkingGoogle: $isLinkingGoogle,
                    isUnlinkingGoogle: $isUnlinkingGoogle,
                    showDeleteKidAlert: $showDeleteKidAlert,
                    kidToDelete: $kidToDelete,
                    isEditingPin: $isEditingPin,
                    newPin: $newPin,
                    pinChangeError: $pinChangeError,
                    pinChangeSuccess: $pinChangeSuccess,
                    showEditKidsModal: $showEditKidsModal,
                    isEditingEmail: $isEditingEmail,
                    isEditingPassword: $isEditingPassword,
                    originalEmail: $originalEmail,
                    originalPassword: $originalPassword,
                    isPasswordVisible: $isPasswordVisible,
                    isEditMode: $isEditMode,
                    emailError: $emailError,
                    showAddEmailModal: $showAddEmailModal,
                    showChangePasswordModal: $showChangePasswordModal,
                    showUnlinkGoogleAlert: $showUnlinkGoogleAlert,
                    showUnlinkEmailAlert: $showUnlinkEmailAlert,
                    addEmail: $addEmail,
                    addPassword: $addPassword,
                    isEditingProfiles: $isEditingProfiles,
                    languages: languages,
                    updateEmailFromAuth: updateEmailFromAuth,
                    validateEmail: validateEmail,
                    hasChanges: hasChanges,
                    canSave: canSave,
                    isGoogleLinked: isGoogleLinked,
                    isEmailLinked: isEmailLinked
                )
                    }
                }
            }
        }
        .sheet(isPresented: $showChangePasswordModal) {
            ChangePasswordModal(
                onChange: { current, new in
                    authManager.changePassword(currentPassword: current, newPassword: new) { success, error in
                        if success {
                            showChangePasswordModal = false
                        } else {
                            // Show error in modal
                        }
                    }
                },
                onCancel: {
                    showChangePasswordModal = false
                }
            )
        }
    }
}

// =======================
// iPhone layout
// =======================
struct SettingsViewiPhone: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var store: TipjeStore
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
    @State private var showDeleteAccountAlert = false
    @State private var activeAlert: SettingsAlertType?
    let languages: [String: String]
    let updateEmailFromAuth: () -> Void
    let validateEmail: (String) -> Bool
    let hasChanges: Bool
    let canSave: Bool
    let isGoogleLinked: Bool
    let isEmailLinked: Bool

    // Extracted Login Methods section
    private var loginMethodsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sign-in method table row
            HStack {
                Text(NSLocalizedString("settings_signin_method", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular_Medium", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isGoogleLinked {
                    HStack(spacing: 8) {
                        Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                        Text("Google")
                            .font(.custom("Inter-Regular", size: 17))
                            .foregroundColor(Color(hex: "#7FAD98"))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else if let provider = authManager.firebaseUser?.providerData.first(where: { $0.providerID == "apple.com" }) {
                    HStack(spacing: 8) {
                        Image(systemName: "applelogo").resizable().frame(width: 24, height: 24)
                        Text("Apple")
                            .font(.custom("Inter-Regular", size: 17))
                            .foregroundColor(Color(hex: "#7FAD98"))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else if isEmailLinked {
                    Text("Email/Password")
                        .font(.custom("Inter-Regular", size: 17))
                        .foregroundColor(Color(hex: "#7FAD98"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Change password button below the table (only for email/password)
            if isEmailLinked {
                ButtonTextiPhone(title: NSLocalizedString("settings_change_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                    print("[Settings] Change Password button tapped, presenting modal")
                    showChangePasswordModal = true
                }, fullWidth: true)
                .font(.custom("Inter-Regular_Medium", size: 17))
            }
            
            // --- Kids Profiles Section ---
            Text(NSLocalizedString("settings_kids_profiles", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                .font(.custom("Inter-Regular_Medium", size: 17))
                .foregroundColor(Color(hex: "#799B44"))
                .padding(.top, 14)
                .padding(.bottom, 14)
            ForEach(Array(store.kids.enumerated()), id: \.element.id) { index, kid in
                HStack {
                    Text(store.kids.count == 2 ? NSLocalizedString("settings_profile_name_index", tableName: nil, bundle: Bundle.main, value: "", comment: "") + " \(index + 1)" : NSLocalizedString("settings_profile_name", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
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
            ButtonTextiPhone(title: NSLocalizedString("settings_edit_profiles", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                print("[Settings] Edit Profiles button tapped")
                showEditKidsModal = true
            }, fullWidth: true)
            .frame(maxWidth: .infinity)
            ButtonTextiPhone(title: NSLocalizedString("settings_delete_account", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                showDeleteAccountAlert = true
            }, fullWidth: true)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .foregroundColor(.red)
            .alert(isPresented: $showDeleteAccountAlert) {
                Alert(
                    title: Text(NSLocalizedString("settings_delete_account", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                    message: Text(NSLocalizedString("settings_delete_account_confirm", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                    primaryButton: .destructive(Text(NSLocalizedString("delete", tableName: nil, bundle: Bundle.main, value: "", comment: ""))) {
                        guard let userId = authManager.firebaseUser?.uid else { return }
                        FirestoreManager.shared.cascadeDeleteUser(userId: userId) { _ in
                            authManager.deleteCurrentUser { _, _ in
                                authManager.signOut()
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // Extracted Plan/Status Table section
    private var planStatusTable: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(NSLocalizedString("settings_plan", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subscriptionType == "Yearly" ? NSLocalizedString("settings_tipje_yearly", tableName: nil, bundle: Bundle.main, value: "", comment: "") : NSLocalizedString("settings_tipje_monthly", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular_SemiBold", size: 17))
                    .foregroundColor(Color(hex: "#7FAD98"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text(NSLocalizedString("settings_status", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(NSLocalizedString("settings_subscribed", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular", size: 17))
                    .foregroundColor(Color(hex: "#7FAD98"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text(NSLocalizedString("settings_next_billing_date", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
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
                ButtonTextiPhone(title: NSLocalizedString("settings_manage_subscription", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }, fullWidth: true)
                VStack(alignment: .center) {
                    ButtonTextiPhone(title: NSLocalizedString("settings_logout", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary, action: {
                        print("[Settings] Logout button action triggered")
                        authManager.signOut()
                    }, fullWidth: true)
                    .font(.custom("Inter-Regular_Medium", size: 17))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.bottom, 24)
    }

    var body: some View {
        let content = ScrollView {
            BannerPanelLayout(
                bannerColor: Color(hex: "#BCC4C3"),
                bannerHeight: 100,
                containerOffsetY: -36,
                content: {
                    VStack(alignment: .leading, spacing: 14) {
                        PageTitle(NSLocalizedString("settings_title_family", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                            .padding(.top, 14)
                            .padding(.bottom, 0)
                        
                        Group {
                            SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Language row
                                    HStack {
                                        let languageText = NSLocalizedString("settings_language", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                                        Text(languageText)
                                            .font(.custom("Inter-Regular_Medium", size: 17))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        LanguageSelector(selectedLanguage: $selectedLanguage, context: .settings)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    
                                    // Sign-in method row
                                    loginMethodsSection
                                }
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
    @ObservedObject var store: TipjeStore
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
    @State private var showDeleteAccountAlert = false
    @State private var activeAlert: SettingsAlertType?
    let languages: [String: String]
    let updateEmailFromAuth: () -> Void
    let validateEmail: (String) -> Bool
    let hasChanges: Bool
    let canSave: Bool
    let isGoogleLinked: Bool
    let isEmailLinked: Bool

    private var loginMethodsSectioniPad: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sign-in method table row
            HStack {
                Text(NSLocalizedString("settings_signin_method", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#799B44"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isGoogleLinked {
                    HStack(spacing: 8) {
                        Image("GoogleLogo").resizable().frame(width: 24, height: 24)
                        Text("Google")
                            .font(.custom("Inter-Regular", size: 24))
                            .foregroundColor(Color(hex: "#7FAD98"))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else if let provider = authManager.firebaseUser?.providerData.first(where: { $0.providerID == "apple.com" }) {
                    HStack(spacing: 8) {
                        Image(systemName: "applelogo").resizable().frame(width: 24, height: 24)
                        Text("Apple")
                            .font(.custom("Inter-Regular", size: 24))
                            .foregroundColor(Color(hex: "#7FAD98"))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else if isEmailLinked {
                    Text("Email/Password")
                        .font(.custom("Inter-Regular", size: 24))
                        .foregroundColor(Color(hex: "#7FAD98"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Change password button below the table (only for email/password)
            if isEmailLinked {
                ButtonText(title: NSLocalizedString("settings_change_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                    print("[Settings] Change Password button tapped, presenting modal")
                    showChangePasswordModal = true
                }, fontSize: 24, fullWidth: true)
                .frame(maxWidth: .infinity)
                .font(.custom("Inter-Regular_Medium", size: 24))
            }
            
            // --- Kids Profiles Section ---
            Text(NSLocalizedString("settings_kids_profiles", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                .font(.custom("Inter-Regular_Medium", size: 24))
                .foregroundColor(Color(hex: "#799B44"))
                .padding(.top, 14)
                .padding(.bottom, 14)
            ForEach(Array(store.kids.enumerated()), id: \.element.id) { index, kid in
                HStack {
                    Text(store.kids.count == 2 ? NSLocalizedString("settings_profile_name_index", tableName: nil, bundle: Bundle.main, value: "", comment: "") + " \(index + 1)" : NSLocalizedString("settings_profile_name", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
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
            ButtonText(title: NSLocalizedString("settings_edit_profiles", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                print("[Settings] Edit Profiles button tapped")
                showEditKidsModal = true
            }, fontSize: 24, fullWidth: true)
            .frame(maxWidth: .infinity, minHeight: 44)
            .font(.custom("Inter-Regular_Medium", size: 24))
            ButtonText(title: NSLocalizedString("settings_delete_account", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                showDeleteAccountAlert = true
            }, fontSize: 24, fullWidth: true)
            .padding(.top, 12)
            .foregroundColor(.red)
            .alert(isPresented: $showDeleteAccountAlert) {
                Alert(
                    title: Text(NSLocalizedString("settings_delete_account", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                    message: Text(NSLocalizedString("settings_delete_account_confirm", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                    primaryButton: .destructive(Text(NSLocalizedString("delete", tableName: nil, bundle: Bundle.main, value: "", comment: ""))) {
                        guard let userId = authManager.firebaseUser?.uid else { return }
                        FirestoreManager.shared.cascadeDeleteUser(userId: userId) { _ in
                            authManager.deleteCurrentUser { _, _ in
                                authManager.signOut()
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#ADA57F"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(alignment: .leading, spacing: 14) {
                    PageTitle(NSLocalizedString("settings_title_family", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                        .padding(.top, 14)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 24)
                    
                    Group {
                        SettingsSection(title: nil, trailingIcon: nil, onTrailingIconTap: nil, content: {
                            VStack(alignment: .leading, spacing: 8) {
                                // Language row
                                HStack {
                                    Text(NSLocalizedString("settings_language", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                        .font(.custom("Inter-Regular_Medium", size: 24))
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    LanguageSelector(selectedLanguage: $selectedLanguage, context: .settings)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                
                                // Sign-in method row
                                loginMethodsSectioniPad
                            }
                        }, customTitle: { AnyView(EmptyView()) })
                    }
                    .background(Color(hex: "#EAF3EA").opacity(0.5))
                    .cornerRadius(24)
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 12)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(NSLocalizedString("settings_plan", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(subscriptionType == "Yearly" ? NSLocalizedString("settings_tipje_yearly", tableName: nil, bundle: Bundle.main, value: "", comment: "") : NSLocalizedString("settings_tipje_monthly", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter-Regular_SemiBold", size: 24))
                                .foregroundColor(Color(hex: "#7FAD98"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 48)
                        HStack {
                            Text(NSLocalizedString("settings_status", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(NSLocalizedString("settings_subscribed", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#7FAD98"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 48)
                        HStack {
                            Text(NSLocalizedString("settings_next_billing_date", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
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
                            ButtonText(title: NSLocalizedString("settings_manage_subscription", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }, fontSize: 24, fullWidth: true)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, 24)
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            ButtonText(title: NSLocalizedString("settings_logout", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary, action: {
                                print("[Settings] Logout button action triggered")
                                authManager.signOut()
                            }, fontSize: 24, fullWidth: true)
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
    var fullWidth: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Button(action: action) {
            Group {
                if fullWidth {
            Text(title)
                .font(.custom("Inter-Regular_Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                .foregroundColor(variant == .primary ? Color.white : Color(hex: "#799B44"))
                        .padding(.horizontal, 0)
                        .frame(maxWidth: .infinity, minHeight: 44)
                } else {
                    Text(title)
                        .font(.custom("Inter-Regular_Medium", size: horizontalSizeClass == .compact ? 17 : 24))
                        .foregroundColor(variant == .primary ? Color.white : Color(hex: "#799B44"))
                .padding(.horizontal, horizontalSizeClass == .compact ? 18 : 24)
                        .frame(minWidth: horizontalSizeClass == .compact ? 0 : 120, minHeight: 44)
                }
            }
                .background(
                    variant == .primary ? Color(hex: "#799B44") : Color(hex: "#EAF3EA")
                )
                .cornerRadius(horizontalSizeClass == .compact ? 12 : 20)
        }
    }
}

struct ChangePasswordModal: View {
    var onChange: (String, String) -> Void
    var onCancel: () -> Void
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ChangePasswordModal_iPad(onChange: onChange, onCancel: onCancel)
        } else {
            ChangePasswordModal_iPhone(onChange: onChange, onCancel: onCancel)
        }
    }
}

struct ChangePasswordModal_iPhone: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    var onChange: (String, String) -> Void
    var onCancel: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image("mascot_empty_chores")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            Text("Change Password")
                .font(.custom("Inter-Regular_SemiBold", size: 24))
                .foregroundColor(Color(hex: "#494646"))
            CustomInputField(placeholder: NSLocalizedString("settings_current_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), text: $currentPassword, isSecure: true)
                .frame(maxWidth: .infinity)
            CustomInputField(placeholder: NSLocalizedString("settings_new_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), text: $newPassword, isSecure: true)
                .frame(maxWidth: .infinity)
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            HStack(spacing: 12) {
                ButtonTextiPhone(title: NSLocalizedString("settings_change", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary) {
                    guard !currentPassword.isEmpty, !newPassword.isEmpty else {
                        errorMessage = NSLocalizedString("settings_fill_all_fields", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        return
                    }
                    isLoading = true
                    errorMessage = nil
                    onChange(currentPassword, newPassword)
                }
                .disabled(isLoading)
                .frame(maxWidth: .infinity)
                ButtonTextiPhone(title: NSLocalizedString("cancel", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary) {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 40)
    }
}

struct ChangePasswordModal_iPad: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    var onChange: (String, String) -> Void
    var onCancel: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image("mascot_empty_chores")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            Text("Change Password")
                .font(.custom("Inter-Regular_Medium", size: 32))
                .foregroundColor(Color(hex: "#494646"))
            CustomInputField(placeholder: NSLocalizedString("settings_current_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), text: $currentPassword, isSecure: true)
                .frame(maxWidth: .infinity)
            CustomInputField(placeholder: NSLocalizedString("settings_new_password", tableName: nil, bundle: Bundle.main, value: "", comment: ""), text: $newPassword, isSecure: true)
                .frame(maxWidth: .infinity)
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            HStack(spacing: 12) {
                ButtonText(title: NSLocalizedString("settings_change", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .primary, action: {
                    guard !currentPassword.isEmpty, !newPassword.isEmpty else {
                        errorMessage = NSLocalizedString("settings_fill_all_fields", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        return
                    }
                    isLoading = true
                    errorMessage = nil
                    onChange(currentPassword, newPassword)
                })
                .disabled(isLoading)
                .frame(maxWidth: .infinity)
                ButtonText(title: NSLocalizedString("cancel", tableName: nil, bundle: Bundle.main, value: "", comment: ""), variant: .secondary, action: onCancel)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 40)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif 
