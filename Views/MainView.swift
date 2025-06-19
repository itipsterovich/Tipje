import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var selectedTab: MainTab = .home
    @StateObject private var store = Store()
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false
    @AppStorage("skipPinAfterSetup") var skipPinAfterSetup: Bool = false
    @State private var isAdminUnlocked: Bool = false
    @State private var showProfileSwitchModal: Bool = false
    @State private var switchedKid: Kid? = nil

    var adminOnboardingKey: String {
        "adminOnboardingComplete_\(store.userId)"
    }
    var adminOnboardingComplete: Bool {
        UserDefaults.standard.bool(forKey: adminOnboardingKey)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView().environmentObject(store)
                case .shop:
                    ShopView().environmentObject(store)
                case .admin:
                    if !adminOnboardingComplete || skipPinAfterSetup {
                        AdminView()
                            .environmentObject(store)
                            .onAppear {
                                print("[DEBUG] MainView: Switching to admin tab. adminOnboardingComplete=\(adminOnboardingComplete), skipPinAfterSetup=\(skipPinAfterSetup), isAdminUnlocked=\(isAdminUnlocked), store.userId=\(store.userId)")
                                print("[DEBUG] MainView: AdminView appeared. skipPinAfterSetup=\(skipPinAfterSetup)")
                                if skipPinAfterSetup {
                                    skipPinAfterSetup = false
                                }
                            }
                    } else if isAdminUnlocked {
                        AdminView().environmentObject(store)
                            .onAppear {
                                print("[DEBUG] MainView: Admin unlocked, showing AdminView.")
                            }
                    } else {
                        PinLockView(userId: store.userId) {
                            isAdminUnlocked = true
                            print("[DEBUG] MainView: Admin unlocked via PIN.")
                        }
                        .onAppear {
                            print("[DEBUG] MainView: Showing PinLockView for admin.")
                        }
                    }
                case .settings:
                    SettingsView().environmentObject(store)
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            print("[DEBUG] MainView geometry: \(geo.size)")
                        }
                }
            )
            .edgesIgnoringSafeArea(.top)
            // Overlay the tab bar at the bottom
            VStack {
                Spacer()
                MainTabBar(selectedTab: $selectedTab,
                           kids: store.kids,
                           selectedKid: store.selectedKid,
                           onProfileSwitch: {
                    if store.kids.count == 2, let current = store.selectedKid {
                        let other = store.kids.first { $0.id != current.id }
                        if let other = other {
                            store.selectKid(other)
                            switchedKid = other
                            showProfileSwitchModal = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showProfileSwitchModal = false
                            }
                        }
                    }
                })
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 14 : 24)
                .padding(.bottom, 16)
            }
            .edgesIgnoringSafeArea(.bottom)
            // Overlay for profile switch modal
            .overlay(
                Group {
                    if showProfileSwitchModal, let kid = switchedKid {
                        VStack(spacing: 16) {
                            let isFirst = store.kids.first?.id == kid.id
                            let imageName = isFirst ? "Template1" : "Template2"
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 8)
                            Text("You've switched to \(kid.name)")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#799B44"))
                                .padding(.top, 8)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(radius: 16)
                        )
                        .frame(maxWidth: 320)
                        .transition(.scale)
                    }
                }
            )
        }
        .onAppear {
            print("[MainView] onAppear. store.userId=\(store.userId), Auth.auth().currentUser?.uid=\(Auth.auth().currentUser?.uid ?? "nil")")
            print("[DEBUG] MainView: onAppear adminOnboardingComplete=\(adminOnboardingComplete), skipPinAfterSetup=\(skipPinAfterSetup), isAdminUnlocked=\(isAdminUnlocked)")
            // MIGRATION: Copy old global key to user-specific key if needed
            let globalKey = "adminOnboardingComplete"
            let userKey = adminOnboardingKey
            let globalValue = UserDefaults.standard.bool(forKey: globalKey)
            if globalValue && !UserDefaults.standard.bool(forKey: userKey) {
                print("[DEBUG] MainView: Migrating adminOnboardingComplete from global to user-specific key for userId=\(store.userId)")
                UserDefaults.standard.set(true, forKey: userKey)
            }
            if shouldShowAdminAfterOnboarding {
                selectedTab = .admin
                shouldShowAdminAfterOnboarding = false
            }
            if let uid = Auth.auth().currentUser?.uid, store.userId.isEmpty {
                print("[MainView] Setting store.userId from Auth: \(uid)")
                store.setUser(userId: uid)
            }
        }
        .onChange(of: selectedTab) { newTab in
            print("[DEBUG] MainView: selectedTab changed to \(newTab)")
            if newTab != .admin {
                isAdminUnlocked = false
                print("[DEBUG] MainView: Left admin tab, isAdminUnlocked reset to false.")
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
