import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case home, shop, admin, settings, debug
    var id: Int { rawValue }
    var iconName: String {
        switch self {
        case .home: return "icon_home"
        case .shop: return "icon_shop"
        case .admin: return "icon_admin"
        case .settings: return "icon_settings"
        case .debug: return "icon_debug"
        }
    }
}

struct MainTabBar: View {
    @Binding var selectedTab: MainTab
    var body: some View {
        HStack(spacing: 20) {
            ForEach(MainTab.allCases) { tab in
                ButtonRegular(iconName: tab.iconName, variant: selectedTab == tab ? .green : .light) {
                    print("MainTabBar: tapped \(tab)")
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .background(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

#if DEBUG
struct MainTabBar_Previews: PreviewProvider {
    @State static var selectedTab: MainTab = .home
    static var previews: some View {
        MainTabBar(selectedTab: $selectedTab)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
#endif 