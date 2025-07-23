import SwiftUI

struct PaywallModal: View {
    var body: some View {
        ScrollView {
        VStack(spacing: 24) {
            // TODO: Add illustration
            Text(NSLocalizedString("paywall_unlock_features", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                .font(.custom("Inter", size: 24).weight(.medium))
            // TODO: Add feature bullets
            // TODO: Add price toggle and subscribe/restore buttons
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 8)
        }
    }
}

#if DEBUG
struct PaywallModal_Previews: PreviewProvider {
    static var previews: some View {
        PaywallModal()
            .previewLayout(.sizeThatFits)
    }
}
#endif 