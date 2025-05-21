import SwiftUI

struct ConfettiOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack {
                // TODO: Add Lottie confetti animation
                Text("Enjoy your reward!")
                    .font(.custom("Inter-Medium", size: 24))
                    .foregroundColor(.white)
            }
        }
    }
}

#if DEBUG
struct ConfettiOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiOverlay()
            .previewLayout(.sizeThatFits)
    }
}
#endif 