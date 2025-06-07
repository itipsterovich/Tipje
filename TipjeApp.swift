import SwiftUI
import SwiftData
import FirebaseCore

@main
struct TipjeApp: App {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("didLogin") var didLogin: Bool = false
    let store = Store()
    
    init() {
        FirebaseApp.configure()
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font: \(name)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !didCompleteOnboarding {
                OnboardingView().environmentObject(store)
            } else if !didLogin {
                LoginView().environmentObject(store)
            } else {
                MainView().environmentObject(store)
            }
        }
    }
}
