import SwiftUI

struct PinSetupView: View {
    @State private var pin: [String] = ["", "", "", ""]
    @FocusState private var focusedIndex: Int?
    @State private var isNextActive: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    var userId: String
    var onPinSet: () -> Void

    var body: some View {
        ZStack {
            // Background color and gradient
            Color(hex: "#91A9B9").ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            // Fullscreen illustration
            Image("il_clouds")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .zIndex(0)
            VStack(spacing: 0) {
                Spacer().frame(height: 100)
                Text("pinsetup_title")
                    .font(.custom("Inter-Regular_SemiBold", size: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer().frame(height: 16)
                Text("pinsetup_subtitle")
                    .font(.custom("Inter-Regular_Medium", size: 20))
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 500)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().frame(height: 40)
                HStack(spacing: 16) {
                    ForEach(0..<4) { i in
                        TextField("", text: $pin[i])
                            .keyboardType(.numberPad)
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
                                checkPin()
                            }
                    }
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Spacer()
                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#91A9B9")) {
                    let pinCode = pin.joined()
                    isLoading = true
                    errorMessage = nil
                    FirestoreManager.shared.setUserPin(userId: userId, pinCode: pinCode) { error in
                        isLoading = false
                        if let error = error {
                            errorMessage = String(localized: "pinsetup_save_fail")
                        } else {
                            onPinSet()
                        }
                    }
                }
                .disabled(!isNextActive || isLoading)
                .opacity(isNextActive && !isLoading ? 1 : 0.5)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .zIndex(1)
        }
        .onAppear { focusedIndex = 0 }
    }

    func checkPin() {
        isNextActive = pin.allSatisfy { $0.count == 1 }
    }
} 