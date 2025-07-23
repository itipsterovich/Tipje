import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct BasketCard: View {
    let purchase: RewardPurchase
    var reward: Reward? = nil
    var onConfirm: (() -> Void)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            BasketCardiPhone(purchase: purchase, reward: reward, onConfirm: onConfirm)
        } else {
            BasketCardiPad(purchase: purchase, reward: reward, onConfirm: onConfirm)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct BasketCardiPhone: View {
    let purchase: RewardPurchase
    var reward: Reward? = nil
    var onConfirm: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    @EnvironmentObject var store: TipjeStore
    var body: some View {
        let resolvedReward: Reward? = {
            if let reward = reward { return reward }
            if let cat = (rewardsCatalog + store.customRewards).first(where: { $0.id == purchase.rewardRef.documentID }) {
                return Reward(id: cat.id, title: cat.title, cost: cat.peanuts, isActive: true)
            }
            return nil
        }()
        ZStack(alignment: .topTrailing) {
            if let resolvedReward = resolvedReward {
                RewardKidCard(
                    reward: resolvedReward,
                    canBuy: true,
                    onTap: onConfirm,
                    basketMode: true,
                    quantity: purchase.quantity
                )
            } else {
                // fallback UI if reward not found
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
                    .frame(height: 90)
                    .overlay(
                        Text(NSLocalizedString("basket_reward", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(height: 70)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .onTapGesture {
            withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isTapped = false
            }
            onConfirm?()
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] BasketCardiPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct BasketCardiPad: View {
    let purchase: RewardPurchase
    var reward: Reward? = nil
    var onConfirm: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    @EnvironmentObject var store: TipjeStore
    var body: some View {
        let resolvedReward: Reward? = {
            if let reward = reward { return reward }
            if let cat = (rewardsCatalog + store.customRewards).first(where: { $0.id == purchase.rewardRef.documentID }) {
                return Reward(id: cat.id, title: cat.title, cost: cat.peanuts, isActive: true)
            }
            return nil
        }()
        ZStack(alignment: .topTrailing) {
            if let resolvedReward = resolvedReward {
                RewardKidCard(
                    reward: resolvedReward,
                    canBuy: true,
                    onTap: onConfirm,
                    basketMode: true,
                    quantity: purchase.quantity
                )
            } else {
                // fallback UI if reward not found
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
                    .frame(height: 90)
                    .overlay(
                        Text(NSLocalizedString("basket_reward", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(height: 90)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .onTapGesture {
            withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isTapped = false
            }
            onConfirm?()
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] BasketCardiPad size: \(geo.size)")
                    }
            }
        )
    }
}

#if DEBUG
import FirebaseFirestore
struct BasketCard_Previews: PreviewProvider {
    static var previews: some View {
        let dummyRef = Firestore.firestore().collection("dummy").document("dummy")
        BasketCard(
            purchase: RewardPurchase(id: "1", rewardRef: dummyRef, status: "IN_BASKET", purchasedAt: Date(), givenAt: nil, quantity: 2),
            reward: Reward(id: "reward1", title: "Ice Cream", cost: 10, isActive: true)
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif 