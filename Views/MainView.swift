import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var selectedTab: MainTab = .home
    @StateObject private var store = Store()
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView().environmentObject(store)
                case .shop:
                    ShopView().environmentObject(store)
                case .admin:
                    AdminView().environmentObject(store)
                case .settings:
                    SettingsView().environmentObject(store)
                case .debug:
                    DebugView().environmentObject(store)
                }
            }
            
            Spacer(minLength: 0)
            MainTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 16)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            if shouldShowAdminAfterOnboarding {
                selectedTab = .admin
                shouldShowAdminAfterOnboarding = false
            }
            if let uid = Auth.auth().currentUser?.uid, store.userId.isEmpty {
                store.setUser(userId: uid)
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif 
