import SwiftUI

struct MainButton: View {
    let title: String
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(.custom("Inter-Medium", size: 24))
                .foregroundColor(Color(hex: "#799B44"))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(hex: "#EAF3EA"))
                        if isPressed {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color(hex: "#799B44").opacity(0.08))
                        }
                    }
                )
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            MainButton(title: "Add New") {}
            MainButton(title: "Save") {}
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 