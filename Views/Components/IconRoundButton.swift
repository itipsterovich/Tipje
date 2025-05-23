import SwiftUI

struct IconRoundButton: View {
    let iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(hex: "#799B44"))
                .frame(width: 24, height: 24)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color(hex: "#EAF3EA"))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
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