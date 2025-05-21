import SwiftUI

struct PinLockView: View {
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Add numeric keypad (0-9)
            // TODO: Add four dots for PIN entry
            // TODO: Add "Forgot?" link
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
    }
}

#if DEBUG
struct PinLockView_Previews: PreviewProvider {
    static var previews: some View {
        PinLockView()
    }
}
#endif 