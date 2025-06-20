import SwiftUI

// Extension to allow Color(hex: "#RRGGBB") usage
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

// Shared palette for card backgrounds
let cardPalette: [Color] = [
    Color(hex: "#D5A412"),
    Color(hex: "#7FAD98"),
    Color(hex: "#ADA57F"),
    Color(hex: "#D78C28"),
    Color(hex: "#7F9BAD"),
    Color(hex: "#A7AD7F"),
    Color(hex: "#AD807F")
]

/// Returns a palette color for a given index, rotating and ensuring no two adjacent are the same
func colorForIndex(_ index: Int) -> Color {
    cardPalette[index % cardPalette.count]
} 