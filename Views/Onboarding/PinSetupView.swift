import SwiftUI

struct PinSetupView: View {
    @AppStorage("skipPinAfterSetup") var skipPinAfterSetup: Bool = false
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
                Spacer().frame(height: 400)
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
                PinInputFields(pin: $pin, focusedIndex: _focusedIndex, showNumbers: true)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("pinInputFields")
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
                            skipPinAfterSetup = true
                            onPinSet()
                        }
                    }
                }
                .accessibilityIdentifier("pinSetupNextButton")
                .disabled(!isNextActive || isLoading)
                .opacity(isNextActive && !isLoading ? 1 : 0.5)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .zIndex(1)
            .padding()
        }
        .onAppear { focusedIndex = 0 }
        .onChange(of: pin) { _ in checkPin() }
    }

    func checkPin() {
        isNextActive = pin.allSatisfy { $0.count == 1 }
    }
} 
