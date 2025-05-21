import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Add horizontally-paged hero illustrations
            // TODO: Add headline + body copy
            // TODO: Add progress dots
            // TODO: Add Button M (Get started)
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif 