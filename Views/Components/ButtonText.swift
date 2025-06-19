import SwiftUI

enum ButtonTextVariant {
    case primary, secondary
}

struct ButtonText: View {
    var title: String
    var variant: ButtonTextVariant = .primary
    var action: () -> Void
    var fontSize: CGFloat = 24
    
    var fillColor: Color {
        switch variant {
        case .primary: return Color(hex: "#799B44")
        case .secondary: return Color(hex: "#EAF3EA")
        }
    }
    var textColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return Color(hex: "#799B44")
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter-Regular-Medium", size: fontSize))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(fillColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
