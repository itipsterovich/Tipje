import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    @AppStorage("didLogin") private var didLogin: Bool = false
    @State private var isSignUp: Bool = true
    @StateObject private var authManager = AuthManager()
    @State private var localErrorMessage: String? = nil
    var onLogin: ((String) -> Void)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var adaptiveFormWidth: CGFloat? {
        if horizontalSizeClass == .compact {
            return nil // Use .infinity for iPhone
        } else {
            return min(UIScreen.main.bounds.width * 0.6, 500)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#91A9B9")
                .ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0.0), .white.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                Image("il_admin")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
            }

            Group {
                if horizontalSizeClass == .compact {
                    ScrollView {
                        loginFormContent
                    }
                    .padding(.bottom, 40)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    loginFormContent
                        .padding(.bottom, 120)
                }
            }
        }
    }

    private var loginFormContent: some View {
        Group {
            if horizontalSizeClass == .compact {
                // --- iPhone layout start ---
                ZStack {
                    VStack(spacing: 0) {
                        VStack(spacing: 24) {
                            Text("Get Started")
                                .font(.custom("Inter-Regular_SemiBold", size: 32))
                                .foregroundColor(Color(hex: "#494646"))
                                .multilineTextAlignment(.center)
                            Text("Enjoy 7 days of Tipje with no commitment—see how peaceful parenting can feel.")
                                .font(.custom("Inter-Regular", size: 20))
                                .foregroundColor(Color(hex: "#494646").opacity(0.5))
                                .multilineTextAlignment(.center)
                            ButtonText(title: String(localized: "login_google"), variant: .secondary, action: {
                                print("[LoginView] Google login button tapped")
                                localErrorMessage = nil
                                guard let rootVC = UIApplication.shared
                                    .connectedScenes
                                    .compactMap({ $0 as? UIWindowScene })
                                    .flatMap({ $0.windows })
                                    .first(where: { $0.isKeyWindow })?
                                    .rootViewController
                                else {
                                    print("[LoginView] Unable to access root view controller.")
                                    localErrorMessage = "Unable to access root view controller."
                                    return
                                }
                                print("[LoginView] Starting Google signInWithGoogle...")
                                authManager.signInWithGoogle(
                                    presentingViewController: rootVC
                                ) { success, errorString in
                                    print("[LoginView] Google signInWithGoogle completion: success=\(success), error=\(String(describing: errorString))")
                                    if success {
                                        didLogin = true
                                        if let uid = Auth.auth().currentUser?.uid {
                                            print("[LoginView] Google login successful, uid=\(uid)")
                                            onLogin?(uid)
                                        } else {
                                            print("[LoginView] Google login success but no uid found!")
                                        }
                                    } else {
                                        print("[LoginView] Google login failed: \(String(describing: errorString))")
                                        localErrorMessage = errorString
                                    }
                                }
                            }, fontSize: 24)
                            .overlay(
                                HStack {
                                    Image("GoogleLogo")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .padding(.leading, 12)
                                    Spacer()
                                }
                            )
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(hex: "#D4D7E3"))
                                Text("login_or")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(Color(hex: "#8897AD"))
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(hex: "#D4D7E3"))
                            }
                            if isSignUp {
                                CustomInputField(placeholder: String(localized: "login_email"), text: $email)
                                CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                                CustomInputField(placeholder: String(localized: "login_repeat_password"), text: $repeatPassword, isSecure: true)
                                if let error = localErrorMessage ?? authManager.errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Button {
                                    print("[LoginView] Email sign up button tapped")
                                    guard password == repeatPassword else {
                                        print("[LoginView] Passwords do not match")
                                        localErrorMessage = String(localized: "login_passwords_no_match")
                                        return
                                    }
                                    localErrorMessage = nil
                                    print("[LoginView] Starting email signUp...")
                                    authManager.signUp(email: email, password: password) { success, err in
                                        print("[LoginView] Email signUp completion: success=\(success), error=\(String(describing: err))")
                                        if success {
                                            didLogin = true
                                            if let uid = Auth.auth().currentUser?.uid {
                                                print("[LoginView] Email sign up successful, uid=\(uid)")
                                                onLogin?(uid)
                                            } else {
                                                print("[LoginView] Email sign up success but no uid found!")
                                            }
                                        } else {
                                            print("[LoginView] Email sign up failed: \(String(describing: err))")
                                            localErrorMessage = err
                                        }
                                    }
                                } label: {
                                    Text("login_signup")
                                        .font(.custom("Inter-Medium", size: 24))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                        .background(Color(hex: "#799B44"))
                                        .cornerRadius(28)
                                }
                                .buttonStyle(PlainButtonStyle())
                                HStack(spacing: 4) {
                                    Text("login_have_account")
                                        .foregroundColor(Color(hex: "#8897AD"))
                                    Button {
                                        isSignUp = false
                                    } label: {
                                        Text("login_signin")
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                    }
                                }
                                .font(.custom("Inter-Regular", size: 18))
                            } else {
                                CustomInputField(placeholder: String(localized: "login_email"), text: $email)
                                CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                                if let error = localErrorMessage ?? authManager.errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Button {
                                    print("[LoginView] Email sign in button tapped")
                                    localErrorMessage = nil
                                    authManager.signIn(email: email, password: password) { success, err in
                                        print("[LoginView] Email sign in completion: success=\(success), error=\(String(describing: err))")
                                        if success {
                                            didLogin = true
                                            if let uid = Auth.auth().currentUser?.uid {
                                                print("[LoginView] Email sign in successful, uid=\(uid)")
                                                onLogin?(uid)
                                            } else {
                                                print("[LoginView] Email sign in success but no uid found!")
                                            }
                                        } else {
                                            print("[LoginView] Email sign in failed: \(String(describing: err))")
                                            localErrorMessage = err
                                        }
                                    }
                                } label: {
                                    Text("login_signin")
                                        .font(.custom("Inter-Medium", size: 24))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                        .background(Color(hex: "#799B44"))
                                        .cornerRadius(28)
                                }
                                .buttonStyle(PlainButtonStyle())
                                HStack(spacing: 4) {
                                    Text("login_no_account")
                                        .foregroundColor(Color(hex: "#8897AD"))
                                    Button {
                                        isSignUp = true
                                    } label: {
                                        Text("login_signup")
                                            .foregroundColor(Color(hex: "#799B44"))
                                            .underline()
                                    }
                                }
                                .font(.custom("Inter-Regular", size: 18))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                    .background(Color.white)
                    .cornerRadius(32)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                }
            } else {
                // --- iPad layout start ---
                VStack {
                    Image("Tipje_logo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .padding(.top, 100)
                        .foregroundColor(.white)
                    Spacer()
                    VStack(spacing: 14) {
                        Text("Get Started")
                            .font(.custom("Inter-Regular_SemiBold", size: 34))
                            .foregroundColor(Color(hex: "#494646"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Text("Enjoy 7 days of Tipje with no commitment—see how peaceful parenting can feel.")
                            .font(.custom("Inter-Regular", size: 20))
                            .foregroundColor(Color(hex: "#494646").opacity(0.5))
                            .multilineTextAlignment(.center)
                        ButtonText(title: String(localized: "login_google"), variant: .secondary, action: {
                            print("[LoginView] Google login button tapped")
                            localErrorMessage = nil
                            guard let rootVC = UIApplication.shared
                                .connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .flatMap({ $0.windows })
                                .first(where: { $0.isKeyWindow })?
                                .rootViewController
                            else {
                                print("[LoginView] Unable to access root view controller.")
                                localErrorMessage = "Unable to access root view controller."
                                return
                            }
                            print("[LoginView] Starting Google signInWithGoogle...")
                            authManager.signInWithGoogle(
                                presentingViewController: rootVC
                            ) { success, errorString in
                                print("[LoginView] Google signInWithGoogle completion: success=\(success), error=\(String(describing: errorString))")
                                if success {
                                    didLogin = true
                                    if let uid = Auth.auth().currentUser?.uid {
                                        print("[LoginView] Google login successful, uid=\(uid)")
                                        onLogin?(uid)
                                    } else {
                                        print("[LoginView] Google login success but no uid found!")
                                    }
                                } else {
                                    print("[LoginView] Google login failed: \(String(describing: errorString))")
                                    localErrorMessage = errorString
                                }
                            }
                        }, fontSize: 24)
                        .overlay(
                            HStack {
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(.leading, 12)
                                Spacer()
                            }
                        )
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(hex: "#D4D7E3"))
                            Text("login_or")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(Color(hex: "#8897AD"))
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(hex: "#D4D7E3"))
                        }
                        if isSignUp {
                            CustomInputField(placeholder: String(localized: "login_email"), text: $email)
                            CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                            CustomInputField(placeholder: String(localized: "login_repeat_password"), text: $repeatPassword, isSecure: true)
                            if let error = localErrorMessage ?? authManager.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            Button {
                                print("[LoginView] Email sign up button tapped")
                                guard password == repeatPassword else {
                                    print("[LoginView] Passwords do not match")
                                    localErrorMessage = String(localized: "login_passwords_no_match")
                                    return
                                }
                                localErrorMessage = nil
                                print("[LoginView] Starting email signUp...")
                                authManager.signUp(email: email, password: password) { success, err in
                                    print("[LoginView] Email signUp completion: success=\(success), error=\(String(describing: err))")
                                    if success {
                                        didLogin = true
                                        if let uid = Auth.auth().currentUser?.uid {
                                            print("[LoginView] Email sign up successful, uid=\(uid)")
                                            onLogin?(uid)
                                        } else {
                                            print("[LoginView] Email sign up success but no uid found!")
                                        }
                                    } else {
                                        print("[LoginView] Email sign up failed: \(String(describing: err))")
                                        localErrorMessage = err
                                    }
                                }
                            } label: {
                                Text("login_signup")
                                    .font(.custom("Inter-Medium", size: 24))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(Color(hex: "#799B44"))
                                    .cornerRadius(28)
                            }
                            .buttonStyle(PlainButtonStyle())
                            HStack(spacing: 4) {
                                Text("login_have_account")
                                    .foregroundColor(Color(hex: "#8897AD"))
                                Button {
                                    isSignUp = false
                                } label: {
                                    Text("login_signin")
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .underline()
                                }
                            }
                            .font(.custom("Inter-Regular", size: 18))
                        } else {
                            CustomInputField(placeholder: String(localized: "login_email"), text: $email)
                            CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                            if let error = localErrorMessage ?? authManager.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            Button {
                                print("[LoginView] Email sign in button tapped")
                                localErrorMessage = nil
                                authManager.signIn(email: email, password: password) { success, err in
                                    print("[LoginView] Email sign in completion: success=\(success), error=\(String(describing: err))")
                                    if success {
                                        didLogin = true
                                        if let uid = Auth.auth().currentUser?.uid {
                                            print("[LoginView] Email sign in successful, uid=\(uid)")
                                            onLogin?(uid)
                                        } else {
                                            print("[LoginView] Email sign in success but no uid found!")
                                        }
                                    } else {
                                        print("[LoginView] Email sign in failed: \(String(describing: err))")
                                        localErrorMessage = err
                                    }
                                }
                            } label: {
                                Text("login_signin")
                                    .font(.custom("Inter-Medium", size: 24))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(Color(hex: "#799B44"))
                                    .cornerRadius(28)
                            }
                            .buttonStyle(PlainButtonStyle())
                            HStack(spacing: 4) {
                                Text("login_no_account")
                                    .foregroundColor(Color(hex: "#8897AD"))
                                Button {
                                    isSignUp = true
                                } label: {
                                    Text("login_signup")
                                        .foregroundColor(Color(hex: "#799B44"))
                                        .underline()
                                }
                            }
                            .font(.custom("Inter-Regular", size: 18))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .cornerRadius(32)
                    .frame(maxWidth: .infinity)
                    .frame(width: adaptiveFormWidth)
                    Spacer()
                }
                // --- iPad layout end ---
            }
        }
    }
}

