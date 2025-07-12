import SwiftUI

struct TipjeModal: View {
    let imageName: String
    let message: String
    let onClose: () -> Void
    var imageHeight: CGFloat = min(UIScreen.main.bounds.height * 0.9, 450)
    var maxWidth: CGFloat = 600
    var font: Font = .custom("Inter-Regular_Medium", size: 24)
    var textColor: Color = Color(hex: "8E9293")
    var closeIcon: String = "icon_close"
    var closeVariant: ButtonRegularVariant = .light
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone: Use default iOS modal style, no custom background/corner/shadow
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        ButtonRegular(iconName: closeIcon, variant: closeVariant) { onClose() }
                            .padding(.top, 24)
                            .padding(.trailing, horizontalSizeClass == .compact ? 24 : 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    if !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: imageHeight)
                            .padding(.top, 0)
                    }
                    Text(message)
                        .font(font)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(60)
                }
                .padding(.horizontal, 0)
                .frame(maxWidth: maxWidth)
            } else {
                // iPad: Keep custom background, corner radius, and shadow
        ZStack {
            Color.white.ignoresSafeArea()
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ButtonRegular(iconName: closeIcon, variant: closeVariant) { onClose() }
                    .padding(.top, 24)
                    .padding(.trailing, horizontalSizeClass == .compact ? 24 : 40)
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
                        if !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: imageHeight)
                .padding(.top, 0)
                        }
            Text(message)
                .font(font)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                            .padding(60)
        }
                    .padding(.horizontal, 0)
        .frame(maxWidth: maxWidth)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 8)
                }
            }
        }
    }
}

#if DEBUG
struct TipjeModal_Previews: PreviewProvider {
    static var previews: some View {
        TipjeModal(
            imageName: "il_used",
            message: "You've already marked this task as completed for today and spent your peanuts. Make sure it's done.",
            onClose: {}
        )
    }
}
#endif 
