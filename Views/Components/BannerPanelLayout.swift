import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct BannerPanelLayout<BannerContent: View, Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> BannerContent
    let content: () -> Content
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(
        bannerColor: Color,
        bannerHeight: CGFloat,
        @ViewBuilder bannerContent: @escaping () -> BannerContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bannerColor = bannerColor
        self.bannerHeight = bannerHeight
        self.bannerContent = bannerContent
        self.content = content
    }

    var body: some View {
        if horizontalSizeClass == .compact {
            BannerPanelLayoutiPhone(bannerColor: bannerColor, bannerHeight: bannerHeight, bannerContent: bannerContent, content: content)
        } else {
            BannerPanelLayoutiPad(bannerColor: bannerColor, bannerHeight: bannerHeight, bannerContent: bannerContent, content: content)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct BannerPanelLayoutiPhone<BannerContent: View, Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> BannerContent
    let content: () -> Content

    var body: some View {
        GeometryReader { outerGeo in
            let safePadding = max(outerGeo.safeAreaInsets.leading, outerGeo.safeAreaInsets.trailing, 14)
            let effectiveBannerHeight: CGFloat = bannerHeight * 0.9
            VStack(spacing: 0) {
                ZStack {
                    bannerColor
                        .frame(height: effectiveBannerHeight)
                        .edgesIgnoringSafeArea(.top)
                    bannerContent()
                        .frame(height: effectiveBannerHeight)
                }
                content()
                    .padding(.horizontal, 8)
                    .background(
                        RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                            .fill(Color.white)
                    )
                    .offset(y: -60)
                    .frame(maxWidth: min(outerGeo.size.width, UIScreen.main.bounds.width))
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            print("[DEBUG] BannerPanelLayoutiPhone size: \(geo.size)")
                        }
                }
            )
        }
    }
}

// =======================
// iPad layout
// =======================
struct BannerPanelLayoutiPad<BannerContent: View, Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> BannerContent
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                bannerColor
                    .frame(height: bannerHeight)
                    .edgesIgnoringSafeArea(.top)
                bannerContent()
                    .frame(height: bannerHeight)
            }
            content()
                .background(
                    RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        .fill(Color.white)
                )
                .offset(y: -24)
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] BannerPanelLayoutiPad size: \(geo.size)")
                    }
            }
        )
    }
}

// Helper for rounding only top corners
struct RoundedCorner: Shape {
    var radius: CGFloat = 24.0
    var corners: UIRectCorner = [.topLeft, .topRight]
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 