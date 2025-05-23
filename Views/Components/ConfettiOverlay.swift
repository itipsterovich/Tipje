import SwiftUI

struct ConfettiOverlay: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image("mascot_happy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            Text("Enjoy your reward!")
                .font(.custom("Inter-Medium", size: 28))
                .foregroundColor(Color(hex: "#799B44"))
            Button("Close") { isPresented = false }
                .font(.custom("Inter-Medium", size: 20))
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .background(Color(hex: "#EAF3EA"))
                .foregroundColor(Color(hex: "#799B44"))
                .cornerRadius(20)
        }
        .frame(width: 320, height: 480)
        .background(Color.white)
        .cornerRadius(32)
        .shadow(radius: 20)
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