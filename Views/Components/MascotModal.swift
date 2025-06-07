import SwiftUI

struct MascotModal: View {
    var headline: String
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // TODO: Add mascot image/animation
                Image("mascot_happy")
                    .resizable()
                    .frame(width: 160, height: 120)
                Text(headline)
                    .font(.custom("Inter", size: 24).weight(.medium))
                // TODO: Add Button S to close
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 8)
        }
    }
}

#if DEBUG
struct MascotModal_Previews: PreviewProvider {
    static var previews: some View {
        MascotModal(headline: "Great job!")
            .previewLayout(.sizeThatFits)
    }
}
#endif 
