import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import FirebaseCore
import AuthenticationServices
import CryptoKit

class AuthManager: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var errorMessage: String?
    private var appleSignInDelegate: AppleSignInDelegate?

    init() {
        self.firebaseUser = Auth.auth().currentUser
        print("[AuthManager] Initialized. Current user: \(String(describing: self.firebaseUser?.uid))")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                print("[AuthManager] Auth state changed. New user: \(String(describing: user?.uid))")
                self?.firebaseUser = user
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        print("[AuthManager] signUp called for email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                print("[AuthManager] signUp error: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else if let firebaseUser = result?.user {
                print("[AuthManager] signUp success. UID: \(firebaseUser.uid)")
                    self.firebaseUser = firebaseUser
                    // Create Firestore user profile
                    let user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: nil,
                        authProvider: nil,
                        pinHash: nil,
                        createdAt: nil,
                        updatedAt: nil,
                        pinFailedAttempts: nil,
                        pinLockoutUntil: nil
                    )
                    FirestoreManager.shared.createUser(user) { error in
                        if let error = error {
                        print("[AuthManager] Firestore user creation error: \(error)")
                            completion(false, error.localizedDescription)
                        } else {
                        print("[AuthManager] Firestore user created for UID: \(user.id)")
                            FirestoreManager.shared.fetchUser(userId: user.id) { confirmedUser in
                            print("[AuthManager] Firestore fetch after create. UID: \(user.id), Found: \(confirmedUser != nil)")
                                if confirmedUser != nil {
                                    completion(true, nil)
                                } else {
                                    completion(false, "User profile not readable after creation.")
                                }
                            }
                        }
                    }
                }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        print("[AuthManager] signIn called for email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                print("[AuthManager] signIn error: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else if let firebaseUser = result?.user {
                print("[AuthManager] signIn success. UID: \(firebaseUser.uid)")
                    self.firebaseUser = firebaseUser
                    // Fetch Firestore user profile, only create if missing
                    FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { user in
                    print("[AuthManager] Firestore fetch after signIn. UID: \(firebaseUser.uid), Found: \(user != nil)")
                        if user == nil {
                            let newUser = User(
                                id: firebaseUser.uid,
                                email: firebaseUser.email ?? "",
                                displayName: nil,
                                authProvider: nil,
                                pinHash: nil,
                                createdAt: nil,
                                updatedAt: nil,
                                pinFailedAttempts: nil,
                                pinLockoutUntil: nil
                            )
                            FirestoreManager.shared.createUser(newUser) { error in
                                if let error = error {
                                    print("Firestore user creation error: \(error)")
                                    completion(false, error.localizedDescription)
                                } else {
                                    // Confirm user is now readable
                                    FirestoreManager.shared.fetchUser(userId: newUser.id) { confirmedUser in
                                        if confirmedUser != nil {
                                            completion(true, nil)
                                        } else {
                                            completion(false, "User profile not readable after creation.")
                                        }
                                    }
                                }
                            }
                        } else {
                            completion(true, nil)
                        }
                    }
                }
        }
    }

    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        print("[AuthManager] signInWithGoogle called")
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false, "Missing Google client ID")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("[AuthManager] signInWithGoogle error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(false, "Google authentication failed")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                    print("[AuthManager] signInWithGoogle error: \(error.localizedDescription)")
                        completion(false, error.localizedDescription)
                    } else if let firebaseUser = authResult?.user {
                    print("[AuthManager] signInWithGoogle success. UID: \(firebaseUser.uid)")
                        self.firebaseUser = firebaseUser
                        // Fetch Firestore user profile, only create if missing
                        FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { user in
                        print("[AuthManager] Firestore fetch after Google signIn. UID: \(firebaseUser.uid), Found: \(user != nil)")
                            if user == nil {
                                let newUser = User(
                                    id: firebaseUser.uid,
                                    email: firebaseUser.email ?? "",
                                    displayName: nil,
                                    authProvider: nil,
                                    pinHash: nil,
                                    createdAt: nil,
                                    updatedAt: nil,
                                    pinFailedAttempts: nil,
                                    pinLockoutUntil: nil
                                )
                                FirestoreManager.shared.createUser(newUser) { error in
                                    if let error = error {
                                        print("Firestore user creation error: \(error)")
                                        completion(false, error.localizedDescription)
                                        return
                                    }
                                    // Confirm user is now readable
                                    FirestoreManager.shared.fetchUser(userId: newUser.id) { confirmedUser in
                                        if confirmedUser != nil {
                                            completion(true, nil)
                                        } else {
                                            completion(false, "User profile not readable after creation.")
                                        }
                                    }
                                }
                            } else {
                                completion(true, nil)
                            }
                        }
                    }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.firebaseUser = nil
            // Reset onboarding state to ensure UI shows onboarding
            OnboardingStateManager.shared.userId = ""
            OnboardingStateManager.shared.didLogin = false
            OnboardingStateManager.shared.hasActiveSubscription = false
        } catch {
            print("[AuthManager] Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Change Email
    func changeEmail(newEmail: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "No user signed in")
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            user.updateEmail(to: newEmail) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "No user signed in")
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Reauthenticate (for sensitive actions)
    func reauthenticate(password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "No user signed in")
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    // MARK: - Link with Google
    func linkWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false, "Missing Google client ID")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(false, "Google authentication failed")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().currentUser?.link(with: credential) { _, error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Unlink Google
    func unlinkGoogle(completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().currentUser?.unlink(fromProvider: "google.com") { _, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    /// Deletes the current Firebase Auth user
    func deleteCurrentUser(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No user signed in")
            return
        }
        user.delete { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                self.firebaseUser = nil
                completion(true, nil)
            }
        }
    }

    // Helper for Apple Sign In nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random) % charset.count])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        private let completion: (ASAuthorizationAppleIDCredential?, Error?) -> Void
        private var currentNonce: String?

        init(nonce: String, completion: @escaping (ASAuthorizationAppleIDCredential?, Error?) -> Void) {
            self.currentNonce = nonce
            self.completion = completion
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                completion(appleIDCredential, nil)
            } else {
                completion(nil, NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid AppleID credential"]))
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            completion(nil, error)
        }
    }

    func signInWithApple(completion: @escaping (Bool, String?) -> Void) {
        print("[AuthManager] signInWithApple called")
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let delegate = AppleSignInDelegate(nonce: nonce) { credential, error in
            defer { self.appleSignInDelegate = nil }
            if let error = error {
                print("[AuthManager] AppleSignInDelegate error: \(error)")
                completion(false, error.localizedDescription)
                return
            }
            guard let credential = credential,
                  let appleIDToken = credential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("[AuthManager] Unable to fetch identity token")
                completion(false, "Unable to fetch identity token")
                return
            }
            let oAuthCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: oAuthCredential) { authResult, error in
                if let error = error {
                    print("[AuthManager] Firebase signIn error: \(error)")
                    completion(false, error.localizedDescription)
                } else if let firebaseUser = authResult?.user {
                    self.firebaseUser = firebaseUser
                    print("[AuthManager] Firebase user signed in: \(firebaseUser.uid)")
                    // Fetch or create Firestore user profile as in Google sign-in
                    FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { user in
                        print("[AuthManager] fetchUser returned: \(String(describing: user))")
                        if user == nil {
                            let newUser = User(
                                id: firebaseUser.uid,
                                email: firebaseUser.email ?? "",
                                displayName: nil,
                                authProvider: "apple.com",
                                pinHash: nil,
                                createdAt: nil,
                                updatedAt: nil,
                                pinFailedAttempts: nil,
                                pinLockoutUntil: nil
                            )
                            FirestoreManager.shared.createUser(newUser) { error in
                                if let error = error {
                                    print("[AuthManager] Firestore user creation error: \(error)")
                                    completion(false, error.localizedDescription)
                                } else {
                                    print("[AuthManager] Firestore user created, fetching to confirm...")
                                    FirestoreManager.shared.fetchUser(userId: newUser.id) { confirmedUser in
                                        print("[AuthManager] fetchUser after create: \(String(describing: confirmedUser))")
                                        completion(confirmedUser != nil, confirmedUser == nil ? "User profile not readable after creation." : nil)
                                    }
                                }
                            }
                        } else {
                            print("[AuthManager] Firestore user already exists")
                            completion(true, nil)
                        }
                    }
                }
            }
        }
        self.appleSignInDelegate = delegate
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
}
