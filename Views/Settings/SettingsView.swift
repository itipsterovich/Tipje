import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.custom("Inter-Medium", size: 24))
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
    @State private var selectedLanguage: String = Locale.current.languageCode ?? "en"
    @State private var showChangeEmail = false
    @State private var showChangePassword = false
    @State private var showChangePIN = false
    @State private var showForgotPIN = false
    @State private var showSubscription = false
    @State private var showRestorePurchases = false
    @State private var showLogoutAlert = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var pin: String = ""
    @State private var subscriptionType: String = "Monthly"
    @State private var cardNumber: String = ""

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
                        // Account Section
                        SettingsSection(title: "Account") {
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
                                    Button(action: { showChangePassword = true }) {
                                        Text("Change Password")
                                            .font(.custom("Inter-Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button(action: { showForgotPIN = true }) {
                                        Text("Forgot Password?")
                                            .font(.custom("Inter-Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.top, 12)
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48, alignment: .leading)
                            }
                        }
                        SettingsSection(title: "Security") {
                            VStack(alignment: .trailing, spacing: 0) {
                                HStack(alignment: .top, spacing: 0) {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 16) {
                                        CustomInputField(placeholder: "PIN (4 digits)", text: $pin, keyboardType: .numberPad, maxLength: 4)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                                }
                                HStack(alignment: .center, spacing: 24) {
                                    Button(action: { showChangePIN = true }) {
                                        Text("Change PIN")
                                            .font(.custom("Inter-Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button(action: { showForgotPIN = true }) {
                                        Text("Forgot PIN?")
                                            .font(.custom("Inter-Medium", size: 24))
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.top, 12)
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48, alignment: .leading)
                            }
                        }
                        SettingsSection(title: "Language") {
                            HStack {
                                Spacer()
                                CustomDropdown(
                                    title: "Language",
                                    selection: $selectedLanguage,
                                    options: languages.keys.sorted(),
                                    display: { code in languages[code] ?? code }
                                )
                                .frame(width: UIScreen.main.bounds.width * 0.6 - 48)
                            }
                        }
                        SettingsSection(title: "Subscription") {
                            VStack(alignment: .trailing, spacing: 16) {
                                HStack {
                                    Spacer()
                                    CustomDropdown(
                                        title: "Subscription",
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
                        SettingsSection(title: "App Info") {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Version")
                                        .font(.custom("Inter-Medium", size: 24))
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
                .font(.custom("Inter-Medium", size: 20))
                .alert(isPresented: $showLogoutAlert) {
                    Alert(title: Text("Log Out"), message: Text("Are you sure you want to log out?"), primaryButton: .destructive(Text("Log Out")), secondaryButton: .cancel())
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
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .onChange(of: text) { newValue in
            if let maxLength = maxLength, newValue.count > maxLength {
                text = String(newValue.prefix(maxLength))
            }
        }
        .font(.custom("Inter-Medium", size: 24))
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(Color.white)
        .foregroundColor(Color(hex: "#799B44"))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#799B44"), lineWidth: 2)
        )
        .cornerRadius(16)
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
                    .font(.custom("Inter-Regular", size: 24))
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
                            .font(.custom("Inter-Regular", size: 24))
                            .foregroundColor(Color(hex: "#799B44"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    Divider()
                }
                Button("Cancel") {
                    showMenu = false
                }
                .font(.custom("Inter-Regular", size: 24))
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