import SwiftUI

struct ConfettiOverlay: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 24) {
                Image("mascot_yam")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: min(UIScreen.main.bounds.height * 0.45, 500) * 1.75)
                    .padding(.top, -100)
                Text("Well deserved! Have fun enjoying your treat")
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .foregroundColor(Color(hex: "#8E9293"))
                Button("OK") { isPresented = false }
                    .font(.custom("Inter-Regular_Medium", size: 24))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color(hex: "EAF3EA"))
                    .foregroundColor(Color(hex: "799B44"))
                    .cornerRadius(28)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(radius: 20)
            .frame(maxWidth: 400)
        }
    }
}

#if DEBUG
struct ConfettiOverlay_Previews: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        ConfettiOverlay(isPresented: $isPresented)
    }
}
#endif 