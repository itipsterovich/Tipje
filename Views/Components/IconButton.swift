import SwiftUI

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var accessibilityLabel: String? = nil
    var size: CGFloat = 32
    var defaultColor: Color = Color(hex: "#BCCDA1")
    var pressedColor: Color = Color(hex: "#799B44")
    @State private var isPressed = false
    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .frame(width: size - 8, height: size - 8)
                .padding(4)
                .background(isPressed ? Color(hex: "#EAF3EA") : Color.clear)
                .clipShape(Circle())
                .opacity(isPressed ? 0.7 : 1.0)
                .foregroundColor(isPressed ? pressedColor : defaultColor)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: size, height: size)
        .accessibilityLabel(accessibilityLabel ?? icon)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }.onEnded { _ in isPressed = false })
    }
} 
