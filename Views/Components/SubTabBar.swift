import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct SubTabBar<T: Hashable>: View {
    let tabs: [T]
    @Binding var selectedTab: T
    var title: (T) -> String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            SubTabBariPhone(tabs: tabs, selectedTab: $selectedTab, title: title)
        } else {
            SubTabBariPad(tabs: tabs, selectedTab: $selectedTab, title: title)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct SubTabBariPhone<T: Hashable>: View {
    let tabs: [T]
    @Binding var selectedTab: T
    var title: (T) -> String
    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \ .self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(title(tab))
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(selectedTab == tab ? .white : Color(hex: "#799B44"))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedTab == tab ? Color(hex: "#799B44") : .white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "EAF3EA"))
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] SubTabBariPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct SubTabBariPad<T: Hashable>: View {
    let tabs: [T]
    @Binding var selectedTab: T
    var title: (T) -> String
    var body: some View {
        HStack(spacing: 20) {
            ForEach(tabs, id: \ .self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(title(tab))
                        .font(.custom("Inter-Regular_Medium", size: 28))
                        .foregroundColor(selectedTab == tab ? .white : Color(hex: "#799B44"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(selectedTab == tab ? Color(hex: "#799B44") : .white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "#EAF3EA"))
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] SubTabBariPad size: \(geo.size)")
                    }
            }
        )
    }
}

#if DEBUG
enum SubTabExample: String, CaseIterable { case rules = "Family rules", chores = "Chores" }
struct SubTabBar_Previews: PreviewProvider {
    @State static var selectedTab: SubTabExample = .rules
    static var previews: some View {
        SubTabBar(tabs: SubTabExample.allCases, selectedTab: $selectedTab, title: { $0.rawValue })
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
#endif 