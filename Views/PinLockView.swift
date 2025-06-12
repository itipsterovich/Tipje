import SwiftUI

struct PinLockView: View {
    @State private var pin: [String] = ["", "", "", ""]
    @FocusState private var focusedIndex: Int?
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
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Enter PIN")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 16)
                    Text("Enter your 4-digit PIN to unlock Admin")
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 500)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 40)
                    PinInputFields(pin: $pin, focusedIndex: _focusedIndex, showNumbers: false)
                        .frame(maxWidth: .infinity)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 12)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .zIndex(1)
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Regular_Medium", size: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { focusedIndex = 0 }
        .onChange(of: pin) { _ in
            if pin.allSatisfy({ $0.count == 1 }) {
                verifyPin()
            }
        }
    }

    private func verifyPin() {
        guard pin.allSatisfy({ $0.count == 1 }) else { return }
        let pinCode = pin.joined()
        isLoading = true
        errorMessage = nil
        FirestoreManager.shared.verifyUserPin(userId: userId, pinCode: pinCode) { success in
            isLoading = false
            if success {
                onUnlock()
            } else {
                errorMessage = "Incorrect PIN. Please try again."
                pin = ["", "", "", ""]
                focusedIndex = 0
            }
        }
    }
}

struct PinInputFields: View {
    @Binding var pin: [String]
    @FocusState var focusedIndex: Int?
    var error: Bool = false
    var showNumbers: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<4) { i in
                Group {
                    if showNumbers {
                        TextField("", text: $pin[i])
                            .keyboardType(.numberPad)
                    } else {
                        SecureField("", text: $pin[i])
                            .keyboardType(.numberPad)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(width: 80, height: 80)
                .background(Color.white)
                .cornerRadius(16)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .focused($focusedIndex, equals: i)
                .onChange(of: pin[i]) { newValue in
                    if newValue.count > 1 {
                        pin[i] = String(newValue.prefix(1))
                    }
                    if !newValue.isEmpty && i < 3 {
                        focusedIndex = i + 1
                    }
                    if newValue.isEmpty && i > 0 {
                        focusedIndex = i - 1
                    }
                }
            }
        }
    }
}

#if DEBUG
struct PinLockView_Previews: PreviewProvider {
    static var previews: some View {
        PinLockView(userId: "", onUnlock: {})
    }
}
#endif 