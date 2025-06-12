import SwiftUI

struct TipjeEmptyState: View {
    let imageName: String
    var title: String? = nil
    var subtitle: String? = nil
    var imageHeight: CGFloat = 500
    var topPadding: CGFloat = -40
    var centered: Bool = true
    var body: some View {
        GeometryReader { geometry in
            // If in landscape (width > height), use a smaller mascot image for both iPad and iPhone
            let isLandscape = geometry.size.width > geometry.size.height
            let adjustedHeight = isLandscape ? 220.0 : imageHeight
            let adjustedTop = isLandscape ? -20.0 : topPadding
            Group {
                if centered {
                    VStack(spacing: 0) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: adjustedHeight)
                            .padding(.top, adjustedTop)
                        if let title = title {
                            Text(title)
                                .font(.custom("Inter-Medium", size: 24))
                                .foregroundColor(Color(hex: "#8E9293"))
                                .multilineTextAlignment(.center)
                        }
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#8E9293").opacity(isLandscape ? 0.7 : 0.9))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 24) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: adjustedHeight)
                            .padding(.top, adjustedTop)
                        if let title = title {
                            Text(title)
                                .font(.custom("Inter-Medium", size: 24))
                                .foregroundColor(Color(hex: "#8E9293"))
                                .multilineTextAlignment(.center)
                        }
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.custom("Inter-Regular", size: 24))
                                .foregroundColor(Color(hex: "#8E9293").opacity(isLandscape ? 0.7 : 0.9))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 32)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#if DEBUG
struct TipjeEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        TipjeEmptyState(
            imageName: "mascot_ticket",
            subtitle: "Check back soon to start earning peanuts! 🥜"
        )
    }
}
#endif 
