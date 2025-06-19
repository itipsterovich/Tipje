import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct PinLockView: View {
    @State private var pin: [String] = ["", "", "", ""]
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    let pinLength = 4
    var userId: String
    var onUnlock: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            PinLockViewiPhone(
                pin: $pin,
                errorMessage: $errorMessage,
                isLoading: $isLoading,
                pinLength: pinLength,
                userId: userId,
                onUnlock: onUnlock
            )
        } else {
            PinLockViewiPad(
                pin: $pin,
                errorMessage: $errorMessage,
                isLoading: $isLoading,
                pinLength: pinLength,
                userId: userId,
                onUnlock: onUnlock
            )
        }
    }
}

// =======================
// iPhone layout
// =======================
struct PinLockViewiPhone: View {
    @Binding var pin: [String]
    @Binding var errorMessage: String?
    @Binding var isLoading: Bool
    @FocusState private var focusedIndex: Int?
    let pinLength: Int
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
            VStack(spacing: 0) {
                Spacer()
                Image("il_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 440)
                    .opacity(0.85)
                    .ignoresSafeArea(edges: .bottom)
            }
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    Text("Enter PIN")
                        .font(.custom("Inter-Regular_SemiBold", size: 28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 12)
                    Text("Enter your 4-digit PIN to unlock Admin")
                        .font(.custom("Inter-Regular_Medium", size: 16))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: 350)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 32)
                    PinInputFields(pin: $pin, focusedIndex: _focusedIndex, showNumbers: false)
                        .frame(maxWidth: .infinity)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 12)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .zIndex(1)
        }
        .padding(.horizontal, 0)
        .font(.custom("Inter-Regular_Medium", size: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

// =======================
// iPad layout
// =======================
struct PinLockViewiPad: View {
    @Binding var pin: [String]
    @Binding var errorMessage: String?
    @Binding var isLoading: Bool
    @FocusState private var focusedIndex: Int?
    let pinLength: Int
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
            VStack(spacing: 0) {
                Spacer()
                Image("il_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 700)
                    .opacity(1.0)
                    .ignoresSafeArea(edges: .bottom)
            }
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    Text("Enter PIN")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 12)
                    Text("Enter your 4-digit PIN to unlock Mindful Home Hub")
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: 350)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 32)
                    PinInputFields(pin: $pin, focusedIndex: _focusedIndex, showNumbers: false)
                        .frame(maxWidth: .infinity)
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 12)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .zIndex(1)
        }
        .padding(.horizontal, 0)
        .font(.custom("Inter-Regular_Medium", size: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                            .foregroundColor(Color(hex: "#494646"))
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
                    if newValue.isEmpty {
                        if i > 0 {
                            if pin[i-1] != "" {
                                pin[i-1] = ""
                            }
                            focusedIndex = i - 1
                        }
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
