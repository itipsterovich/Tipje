import SwiftUI

struct PinLockView: View {
    @State private var pin: [String] = []
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    let pinLength = 4
    var userId: String
    var onUnlock: () -> Void
    var body: some View {
        ZStack {
            Color(hex: "#91A9B9").ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            Image("il_clouds")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .zIndex(0)
            VStack(spacing: 0) {
                Spacer().frame(height: 140)
                HStack(spacing: 16) {
                    ForEach(0..<pinLength, id: \.self) { i in
                        Circle()
                            .stroke(errorMessage == nil ? Color.white : Color.red, lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(pin.count > i ? (errorMessage == nil ? Color.white : Color.red) : Color.clear)
                                    .frame(width: 80, height: 80)
                            )
                    }
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 12)
                }
                Spacer().frame(height: 40)
                VStack(spacing: 16) {
                    ForEach([["1","2","3"],["4","5","6"],["7","8","9"]], id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach(row, id: \.self) { num in
                                PinPadButton(label: num) {
                                    appendDigit(num)
                                }
                            }
                        }
                    }
                    HStack(spacing: 24) {
                        Spacer().frame(width: 64)
                        PinPadButton(label: "0") {
                            appendDigit("0")
                        }
                        PinPadButton(label: "⌫") {
                            deleteDigit()
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .zIndex(1)
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Regular_Medium", size: 24))
    }

    private func appendDigit(_ digit: String) {
        guard pin.count < pinLength else { return }
        pin.append(digit)
        errorMessage = nil
        if pin.count == pinLength {
            isLoading = true
            let pinCode = pin.joined()
            FirestoreManager.shared.verifyUserPin(userId: userId, pinCode: pinCode) { success in
                isLoading = false
                if success {
                    onUnlock()
                } else {
                    errorMessage = "Incorrect PIN. Please try again."
                    pin.removeAll()
                }
            }
        }
    }

    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
        errorMessage = nil
    }
}

struct PinPadButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text(label)
                    .font(.custom("Inter-Regular_SemiBold", size: 28))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct PinLockView_Previews: PreviewProvider {
    static var previews: some View {
        PinLockView(userId: "", onUnlock: {})
    }
}
#endif 