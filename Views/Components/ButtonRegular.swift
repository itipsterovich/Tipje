import SwiftUI

enum ButtonRegularVariant {
    case green, light, rose
}

struct ButtonRegular: View {
    var iconName: String
    var variant: ButtonRegularVariant = .green
    var action: () -> Void
    
    var fillColor: Color {
        switch variant {
        case .green: return Color(hex: "#799B44")
        case .light: return Color(hex: "#EAF3EA")
        case .rose: return Color(hex: "#C48A8A")
        }
    }
    var iconColor: Color {
        switch variant {
        case .green: return .white
        case .light: return Color(hex: "#799B44")
        case .rose: return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 56, height: 56)
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 