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

    var formWidth: CGFloat {
        UIScreen.main.bounds.width * 0.6
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

            VStack {
                Image("Tipje_logo")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.5)
                    .frame(height: 96)
                    .padding(.top, 100)

                Spacer()

                VStack(spacing: 24) {
                    Text("login_title")
                        .font(.custom("Inter-Regular_SemiBold", size: 34))
                        .foregroundColor(Color(hex: "#494646"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)

                    // MARK: —– Google Sign-In Button
                    Button {
                        localErrorMessage = nil
                        guard let rootVC = UIApplication.shared
                            .connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow })?
                            .rootViewController
                        else {
                            localErrorMessage = "Unable to access root view controller."
                            return
                        }
                        authManager.signInWithGoogle(
                            presentingViewController: rootVC
                        ) { success, errorString in
                            if success {
                                didLogin = true
                                if let uid = Auth.auth().currentUser?.uid {
                                    onLogin?(uid)
                                }
                            } else {
                                localErrorMessage = errorString
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image("GoogleLogo")
                                .resizable()
                                .frame(width: 28, height: 28)
                            Text("login_google")
                                .font(.custom("Inter-Regular", size: 20))
                                .foregroundColor(Color(hex: "#494646"))
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(hex: "#EAF3EA"), lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: formWidth)

                    // Divider "OR"
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: "#D4D7E3"))
                        Text("login_or")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color(hex: "#8897AD"))
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: "#D4D7E3"))
                    }
                    .frame(width: formWidth)

                    // MARK: —– Sign-Up / Sign-In Form
                    if isSignUp {
                        CustomInputField(placeholder: String(localized: "login_email"), text: $email)
                            .frame(width: formWidth)
                        CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                            .frame(width: formWidth)
                        CustomInputField(placeholder: String(localized: "login_repeat_password"), text: $repeatPassword, isSecure: true)
                            .frame(width: formWidth)
                        if let error = localErrorMessage ?? authManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        Button {
                            guard password == repeatPassword else {
                                localErrorMessage = String(localized: "login_passwords_no_match")
                                return
                            }
                            localErrorMessage = nil
                            authManager.signUp(email: email, password: password) { success, err in
                                if success {
                                    didLogin = true
                                    if let uid = Auth.auth().currentUser?.uid {
                                        onLogin?(uid)
                                    }
                                } else {
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
                        .frame(width: formWidth)
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
                            .frame(width: formWidth)
                        CustomInputField(placeholder: String(localized: "login_password"), text: $password, isSecure: true)
                            .frame(width: formWidth)
                        if let error = localErrorMessage ?? authManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        Button {
                            localErrorMessage = nil
                            authManager.signIn(email: email, password: password) { success, err in
                                if success {
                                    didLogin = true
                                    if let uid = Auth.auth().currentUser?.uid {
                                        onLogin?(uid)
                                    }
                                } else {
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
                        .frame(width: formWidth)
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
                .padding(24)
                .background(Color.white)
                .cornerRadius(32)
                .shadow(radius: 16, y: 4)
                .frame(width: formWidth)
                Spacer()
            }
            .padding(.bottom, 120)
        }
    }
}
