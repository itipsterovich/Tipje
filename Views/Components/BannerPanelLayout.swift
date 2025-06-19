import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct BannerPanelLayout<BannerContent: View, Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> BannerContent
    let content: () -> Content
    let containerOffsetY: CGFloat
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(
        bannerColor: Color,
        bannerHeight: CGFloat,
        containerOffsetY: CGFloat = -60,
        @ViewBuilder bannerContent: @escaping () -> BannerContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bannerColor = bannerColor
        self.bannerHeight = bannerHeight
        self.bannerContent = bannerContent
        self.content = content
        self.containerOffsetY = containerOffsetY
    }

    var body: some View {
        if horizontalSizeClass == .compact {
            BannerPanelLayoutiPhone(bannerColor: bannerColor, bannerHeight: bannerHeight, bannerContent: bannerContent, content: content, containerOffsetY: containerOffsetY)
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
    let containerOffsetY: CGFloat

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
                    .offset(y: containerOffsetY)
                    .frame(maxWidth: min(outerGeo.size.width, UIScreen.main.bounds.width))
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        ZStack {
            Color.white.ignoresSafeArea()
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
        }
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