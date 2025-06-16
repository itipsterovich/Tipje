import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct PageTitle<Content: View>: View {
    let text: String
    let trailing: () -> Content
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(_ text: String, @ViewBuilder trailing: @escaping () -> Content = { EmptyView() }) {
        self.text = text
        self.trailing = trailing
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            PageTitleiPhone(text: text, trailing: trailing)
        } else {
            PageTitleiPad(text: text, trailing: trailing)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct PageTitleiPhone<Content: View>: View {
    let text: String
    let trailing: () -> Content
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.custom("Inter-Regular_SemiBold", size: 20))
                .foregroundColor(Color.titlePrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] PageTitleiPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct PageTitleiPad<Content: View>: View {
    let text: String
    let trailing: () -> Content
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.custom("Inter-Regular_Medium", size: 28))
                .foregroundColor(Color.titlePrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(minHeight: 44)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] PageTitleiPad size: \(geo.size)")
                    }
            }
        )
    }
}

extension PageTitle where Content == EmptyView {
    init(_ text: String) {
        self.text = text
        self.trailing = { EmptyView() }
    }
}

#if DEBUG
struct PageTitle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            PageTitle("Reward shop")
            PageTitle("Add new rule") {
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.custom("Inter-Regular_Medium", size: 28))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 