import SwiftUI

struct IconRoundButton: View {
    let iconName: String
    var iconColor: Color = Color(hex: "#799B44")
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color(hex: "#EAF3EA"))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct IconRoundButton_Previews: PreviewProvider {
    static var previews: some View {
        IconRoundButton(iconName: "icon_plus") {}
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
#endif 