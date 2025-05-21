import SwiftUI
import SwiftData

@main
struct TipjeApp: App {
    @StateObject private var store = Store()
    // TODO: Add PurchaseManager and onboarding state
    var body: some Scene {
        WindowGroup {
            // TODO: Show OnboardingView or PinLockView as needed
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }
                ShopView()
                    .tabItem { Label("Shop", systemImage: "cart") }
                AdminView()
                    .tabItem { Label("Admin", systemImage: "person") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            .environmentObject(store)
            // TODO: Inject PurchaseManager
        }
        .modelContainer(for: Task.self)
    }
} 
