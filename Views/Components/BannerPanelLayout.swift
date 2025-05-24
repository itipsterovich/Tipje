import SwiftUI

struct BannerPanelLayout<BannerContent: View, Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> BannerContent
    let content: () -> Content

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
        ZStack(alignment: .top) {
            bannerColor
                .frame(height: bannerHeight)
                .edgesIgnoringSafeArea(.top)
                .overlay(bannerContent(), alignment: .top)
            VStack(spacing: 0) {
                Spacer().frame(height: bannerHeight - 24)
                // Content panel
                ZStack(alignment: .topTrailing) {
                    RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        .fill(Color.white)
                        .frame(maxWidth: .infinity)
                        .offset(y: -24)
                    content()
                        .offset(y: -24)
                }
                .padding(.horizontal, 0)
            }
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