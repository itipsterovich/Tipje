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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ButtonRegular(iconName: closeIcon, variant: closeVariant) { onClose() }
                    .padding(.top, 24)
                    .padding(.trailing, 0)
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: imageHeight)
                .padding(.top, 0)
            Text(message)
                .font(font)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: maxWidth)
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
