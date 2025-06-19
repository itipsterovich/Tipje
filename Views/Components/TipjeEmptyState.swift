import SwiftUI

struct TipjeEmptyState: View {
    let imageName: String
    var title: String? = nil
    var subtitle: String? = nil
    var imageHeight: CGFloat = 250
    var topPadding: CGFloat = -40
    var centered: Bool = true
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        let isIPhone = horizontalSizeClass == .compact
        Group {
            if centered {
                VStack(spacing: 0) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: imageHeight)
                        .padding(.top, topPadding)
                    if let title = title {
                        Text(title)
                            .font(.custom("Inter-Medium", size: isIPhone ? 17 : 24))
                            .foregroundColor(Color(hex: "#8E9293"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Inter-Regular", size: isIPhone ? 17 : 24))
                            .foregroundColor(Color(hex: "#8E9293").opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 24) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: imageHeight)
                        .padding(.top, topPadding)
                    if let title = title {
                        Text(title)
                            .font(.custom("Inter-Medium", size: isIPhone ? 17 : 24))
                            .foregroundColor(Color(hex: "#8E9293"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Inter-Regular", size: isIPhone ? 17 : 24))
                            .foregroundColor(Color(hex: "#8E9293").opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
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
