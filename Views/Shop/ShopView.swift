import SwiftUI

struct ShopView: View {
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Bind to Store.balance
            BalanceChip(balance: 0)
            // TODO: Add SegmentedControl for Rewards / Basket
            // TODO: List RewardKidCard or BasketCard
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
    }
}

#if DEBUG
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
#endif 