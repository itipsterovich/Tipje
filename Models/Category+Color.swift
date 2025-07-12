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

    /// Returns the hex string (e.g. "#D5A412") for this Color if possible, or a default if not.
    func toHexString() -> String {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #if canImport(UIKit)
        let native = NativeColor(self)
        native.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif canImport(AppKit)
        if let native = NativeColor(self).usingColorSpace(.sRGB) {
            native.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #endif
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
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

extension String {
    /// Returns the substring up to and including the first emoji, or the full string if no emoji is found.
    func truncatedAfterFirstEmoji() -> String {
        guard let emojiRange = self.rangeOfCharacter(from: .emojis) else { return self }
        return String(self[..<emojiRange.upperBound])
    }
}

extension CharacterSet {
    static let emojis: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "\u{1F600}"..."\u{1F64F}") // Emoticons
        set.insert(charactersIn: "\u{1F300}"..."\u{1F5FF}") // Misc Symbols and Pictographs
        set.insert(charactersIn: "\u{1F680}"..."\u{1F6FF}") // Transport and Map
        set.insert(charactersIn: "\u{2600}"..."\u{26FF}")   // Misc symbols
        set.insert(charactersIn: "\u{2700}"..."\u{27BF}")   // Dingbats
        set.insert(charactersIn: "\u{1F900}"..."\u{1F9FF}") // Supplemental Symbols and Pictographs
        set.insert(charactersIn: "\u{1FA70}"..."\u{1FAFF}") // Symbols and Pictographs Extended-A
        return set
    }()
} 