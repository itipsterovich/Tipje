import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Bind to Store.balance
            BalanceChip(balance: 0)
            // TODO: Add TabBar for Family Rules / Chores
            // TODO: List RuleKidCard or ChoreKidCard
            // TODO: Show EmptyMascot if none
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif 