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

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct MainTabBar: View {
    @Binding var selectedTab: MainTab
    var kids: [Kid] = []
    var selectedKid: Kid? = nil
    var onProfileSwitch: (() -> Void)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            MainTabBariPhone(selectedTab: $selectedTab, kids: kids, selectedKid: selectedKid, onProfileSwitch: onProfileSwitch)
        } else {
            MainTabBariPad(selectedTab: $selectedTab, kids: kids, selectedKid: selectedKid, onProfileSwitch: onProfileSwitch)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct MainTabBariPhone: View {
    @Binding var selectedTab: MainTab
    var kids: [Kid] = []
    var selectedKid: Kid? = nil
    var onProfileSwitch: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 20) {
            ForEach(MainTab.allCases) { tab in
                ButtonRegular(iconName: tab.iconName, variant: selectedTab == tab ? .green : .light) {
                    selectedTab = tab
                }
            }
            if kids.count == 2, let selectedKid = selectedKid {
                let isFirst = kids.first?.id == selectedKid.id
                let imageName = isFirst ? "Template1" : "Template2"
                Button(action: { onProfileSwitch?() }) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("profileSwitchButton")
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
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] MainTabBariPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct MainTabBariPad: View {
    @Binding var selectedTab: MainTab
    var kids: [Kid] = []
    var selectedKid: Kid? = nil
    var onProfileSwitch: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 32) {
            ForEach(MainTab.allCases) { tab in
                ButtonRegular(iconName: tab.iconName, variant: selectedTab == tab ? .green : .light) {
                    selectedTab = tab
                }
            }
            if kids.count == 2, let selectedKid = selectedKid {
                let isFirst = kids.first?.id == selectedKid.id
                let imageName = isFirst ? "Template1" : "Template2"
                Button(action: { onProfileSwitch?() }) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("profileSwitchButton")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .background(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, 48)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] MainTabBariPad size: \(geo.size)")
                    }
            }
        )
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