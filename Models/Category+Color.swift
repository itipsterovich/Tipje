import SwiftUI

extension Category {
    var defaultColor: Color {
        switch self {
        case .security: return Color(hex: "#EAF3EA")
        case .respect: return Color(hex: "#FAEDDB")
        case .fun: return Color(hex: "#E4F0F8")
        }
    }
    var selectedColor: Color {
        switch self {
        case .security: return Color(hex: "#7FAD98")
        case .respect: return Color(hex: "#D78C28")
        case .fun: return Color(hex: "#7F9BAD")
        }
    }
    var defaultTextColor: Color {
        switch self {
        case .security: return Color(hex: "#7FAD98")
        case .respect: return Color(hex: "#D78C28")
        case .fun: return Color(hex: "#7F9BAD")
        }
    }
    var selectedTextColor: Color {
        return .white
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static var titlePrimary: Color { Color(hex: "#282927") }
} 