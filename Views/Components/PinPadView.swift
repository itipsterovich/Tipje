import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct PinPadView: View {
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: (String) -> Void
    var error: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            PinPadViewiPhone(pin: $pin, maxDigits: maxDigits, onComplete: onComplete, error: error)
        } else {
            PinPadViewiPad(pin: $pin, maxDigits: maxDigits, onComplete: onComplete, error: error)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct PinPadViewiPhone: View {
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: (String) -> Void
    var error: Bool = false
    private let buttonSpacing: CGFloat = 16
    private let digitSpacing: CGFloat = 12
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 120)
            Text("Enter PIN")
                .font(.custom("Inter-Regular_SemiBold", size: 28))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer().frame(height: 12)
            Text("Enter your 4-digit PIN to unlock Admin Control Center.")
                .font(.custom("Inter-Regular_Medium", size: 16))
                .foregroundColor(.secondary)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(maxWidth: 350)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
            // PIN circles
            HStack(spacing: digitSpacing) {
                ForEach(0..<maxDigits, id: \.self) { idx in
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .background(
                            Circle()
                                .fill(idx < pin.count ? (error ? Color.red : Color.accentColor) : Color.clear)
                        )
                }
            }
            Spacer().frame(height: 32)
            // PIN pad
            VStack(spacing: buttonSpacing) {
                ForEach([["1","2","3"],["4","5","6"],["7","8","9"]], id: \.self) { row in
                    HStack(spacing: buttonSpacing) {
                        ForEach(row, id: \.self) { num in
                            PinPadButton(label: num) {
                                appendDigit(num)
                            }
                        }
                    }
                }
                HStack(spacing: buttonSpacing) {
                    Spacer().frame(width: 56)
                    PinPadButton(label: "0") {
                        appendDigit("0")
                    }
                    PinPadButton(label: "⌫", isIcon: true) {
                        deleteDigit()
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(radius: 8)
        )
        .animation(.easeInOut, value: pin)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] PinPadViewiPhone size: \(geo.size)")
                    }
            }
        )
    }
    private func appendDigit(_ digit: String) {
        guard pin.count < maxDigits else { return }
        pin.append(digit)
        if pin.count == maxDigits {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onComplete(pin)
            }
        }
    }
    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }
}

// =======================
// iPad layout
// =======================
struct PinPadViewiPad: View {
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: (String) -> Void
    var error: Bool = false
    private let buttonSpacing: CGFloat = 24
    private let digitSpacing: CGFloat = 20
    var body: some View {
        VStack(spacing: 48) {
            Text("For Parents Only")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 16)
            Text("Enter your 4-digit PIN to unlock Admin Control Center.")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            HStack(spacing: digitSpacing) {
                ForEach(0..<maxDigits, id: \.self) { idx in
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(idx < pin.count ? (error ? Color.red : Color.accentColor) : Color.clear)
                        )
                }
            }
            VStack(spacing: buttonSpacing) {
                ForEach([["1","2","3"],["4","5","6"],["7","8","9"]], id: \.self) { row in
                    HStack(spacing: buttonSpacing) {
                        ForEach(row, id: \.self) { num in
                            PinPadButton(label: num) {
                                appendDigit(num)
                            }
                        }
                    }
                }
                HStack(spacing: buttonSpacing) {
                    Spacer().frame(width: 72)
                    PinPadButton(label: "0") {
                        appendDigit("0")
                    }
                    PinPadButton(label: "⌫", isIcon: true) {
                        deleteDigit()
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground).opacity(0.97))
                .shadow(radius: 12)
        )
        .animation(.easeInOut, value: pin)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] PinPadViewiPad size: \(geo.size)")
                    }
            }
        )
    }
    private func appendDigit(_ digit: String) {
        guard pin.count < maxDigits else { return }
        pin.append(digit)
        if pin.count == maxDigits {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onComplete(pin)
            }
        }
    }
    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }
}

struct PinPadButton: View {
    let label: String
    var isIcon: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                if isIcon {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.accentColor)
                } else {
                    Text(label)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// =======================
// Main PIN entry page switcher
// =======================
struct PinPadPage: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var pin: String = ""
    var maxDigits: Int = 4
    var error: Bool = false
    var onComplete: (String) -> Void = { _ in }
    var body: some View {
        if horizontalSizeClass == .compact {
            PinPadPageiPhone(pin: $pin, maxDigits: maxDigits, error: error, onComplete: onComplete)
        } else {
            PinPadPageiPad(pin: $pin, maxDigits: maxDigits, error: error, onComplete: onComplete)
        }
    }
}

// =======================
// iPhone PIN entry page
// =======================
struct PinPadPageiPhone: View {
    @Binding var pin: String
    var maxDigits: Int = 4
    var error: Bool = false
    var onComplete: (String) -> Void = { _ in }
    var body: some View {
        ZStack {
            // Background color and gradient, matching onboarding
            Color(hex: "#91A9B9").ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                Image("il_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .opacity(0.85)
                    .ignoresSafeArea(edges: .bottom)
            }
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.18)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    Text("Enter PIN")
                        .font(.custom("Inter-Regular_SemiBold", size: 28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 12)
                    Text("Enter your 4-digit PIN to unlock Admin Control Center.")
                        .font(.custom("Inter-Regular_Medium", size: 16))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: 350)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 32)
                    PinPadViewiPhone(pin: $pin, maxDigits: maxDigits, onComplete: onComplete, error: error)
                        .frame(maxWidth: .infinity)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .zIndex(1)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// =======================
// iPad PIN entry page
// =======================
struct PinPadPageiPad: View {
    @Binding var pin: String
    var maxDigits: Int = 4
    var error: Bool = false
    var onComplete: (String) -> Void = { _ in }
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 180)
            Text("For Parents Only")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer().frame(height: 16)
            Text("Enter your 4-digit PIN to unlock Admin Control Center.")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .frame(maxWidth: 500)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            PinPadViewiPad(pin: $pin, maxDigits: maxDigits, onComplete: onComplete, error: error)
                .frame(maxWidth: 420)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#if DEBUG
struct PinPadPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PinPadPage()
                .previewDisplayName("Universal (switcher)")
            PinPadPageiPhone(pin: .constant(""))
                .previewDisplayName("iPhone")
                .previewDevice("iPhone 14 Pro")
            PinPadPageiPad(pin: .constant(""))
                .previewDisplayName("iPad")
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
#endif

// Preview
struct PinPadView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var pin = ""
        var body: some View {
            PinPadView(pin: $pin, maxDigits: 4, onComplete: { _ in })
        }
    }
    static var previews: some View {
        PreviewWrapper()
            .padding()
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea()
    }
} 