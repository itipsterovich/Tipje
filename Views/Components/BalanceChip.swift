import SwiftUI

struct BalanceChip: View {
    var balance: Int
    var body: some View {
        HStack(spacing: 4) {
            Image("icon_peanuts")
            Text("\(max(0, balance))")
        }
        .font(.custom("Inter-Regular_Medium", size: 24))
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#if DEBUG
struct BalanceChip_Previews: PreviewProvider {
    static var previews: some View {
        BalanceChip(balance: 12)
            .previewLayout(.sizeThatFits)
    }
}
#endif 