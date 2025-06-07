import SwiftUI

struct ButtonLarge: View {
    var iconName: String = "icon_next"
    var iconColor: Color = Color(hex: "#799B44")
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .frame(width: 72, height: 72, alignment: .center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 