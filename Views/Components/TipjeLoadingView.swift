import SwiftUI
import ActivityIndicatorView

struct TipjeLoadingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                .frame(width: 120, height: 120)
                .foregroundColor(Color(hex: "#799B44"))
        }
    }
}

#if DEBUG
struct TipjeLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        TipjeLoadingView()
    }
}
#endif 