import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import FirebaseCore

class AuthManager: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var errorMessage: String?

    init() {
        self.firebaseUser = Auth.auth().currentUser
    }

    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            // DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else if let firebaseUser = result?.user {
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
                            print("Firestore user creation error: \(error)")
                        }
                        completion(true, nil)
                    }
                }
            // })
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            // DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else if let firebaseUser = result?.user {
                    self.firebaseUser = firebaseUser
                    // Fetch Firestore user profile, only create if missing
                    FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { user in
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
                                }
                                completion(true, nil)
                            }
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            // })
        }
    }

    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
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
            Auth.auth().signIn(with: credential) { authResult, error in
                // DispatchQueue.main.async(execute: {
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else if let firebaseUser = authResult?.user {
                        self.firebaseUser = firebaseUser
                        // Fetch Firestore user profile, only create if missing
                        FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { user in
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
                                    }
                                    completion(true, nil)
                                }
                            } else {
                                completion(true, nil)
                            }
                        }
                    }
                // })
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.firebaseUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
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
}
