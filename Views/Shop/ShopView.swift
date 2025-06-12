import SwiftUI

enum ShopTab: String, CaseIterable {
    case rewards = "Rewards"
    case basket = "Basket"
}

enum ShopModal: Identifiable {
    case notEnoughPeanuts
    case notEnoughPeanutsForReward
    case addedToBasket
    case confettiOverlay
    var id: Int {
        switch self {
        case .notEnoughPeanuts: return 1
        case .notEnoughPeanutsForReward: return 4
        case .addedToBasket: return 2
        case .confettiOverlay: return 3
        }
    }
}

struct ShopView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: ShopTab = .rewards
    @State private var showConfetti = false
    @State private var activeModal: ShopModal? = nil
    @State private var pendingPurchase: RewardPurchase? = nil

    private var availableRewards: [Reward] {
        store.rewards.filter { $0.isActive }
    }
    private var basketEntries: [RewardPurchase] {
        store.rewardPurchases.filter { $0.status == "IN_BASKET" }
    }

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#C2A3A4"),
            bannerHeight: 300,
            bannerContent: {
                ZStack {
                    Image("il_shop_0")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .offset(y: 0)
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(store.balance)")
                            .font(.custom("Inter-Regular_Bold", size: 84))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            Text("peanuts earned")
                                .font(.custom("Inter-Regular_Medium", size: 24))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(.top, -8)
                        Spacer()
                    }
                    .padding(.top, 80)
                }
                .frame(height: 300)
            },
            content: {
                VStack(spacing: 16) {
                    PageTitle("Reward Shop")
                        .padding(.top, 24)
                    SubTabBar(
                        tabs: ShopTab.allCases,
                        selectedTab: $selectedTab,
                        title: { $0.rawValue }
                    )
                    if selectedTab == .rewards {
                        if availableRewards.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_empty",
                                subtitle: "Your reward shop is getting ready!\nAsk your grown-up to add fun things you can earn."
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(availableRewards) { reward in
                                        let canBuy = store.balance >= reward.cost
                                        RewardKidCard(reward: reward, canBuy: canBuy) {
                                            if canBuy {
                                                store.purchaseReward(reward)
                                                showConfetti = true
                                                SoundPlayer.shared.playSound(named: "reward.aiff")
                                                activeModal = .addedToBasket
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    showConfetti = false
                                                }
                                            } else {
                                                activeModal = .notEnoughPeanutsForReward
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else if selectedTab == .basket {
                        if basketEntries.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_empty",
                                subtitle: "No rewards in basket yet. Add some rewards to your basket to get started!"
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(basketEntries) { entry in
                                        // You may want to resolve reward details from rewardRef if needed
                                        BasketCard(purchase: entry, onConfirm: {
                                            store.decrementOrRemovePurchase(purchase: entry)
                                            pendingPurchase = entry
                                            activeModal = .confettiOverlay
                                        })
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .font(.custom("Inter-Medium", size: 24))
            }
        )
        .sheet(item: $activeModal, onDismiss: {
            if activeModal == .confettiOverlay, let entry = pendingPurchase {
                store.confirmRewardGiven(entry)
                pendingPurchase = nil
            }
            activeModal = nil
        }) { modal in
            switch modal {
            case .notEnoughPeanuts:
                TipjeModal(
                    imageName: "mascot_no",
                    message: "Not enough peanuts yet!\nLet's finish a few more chores first. 🌟",
                    onClose: { activeModal = nil }
                )
            case .notEnoughPeanutsForReward:
                TipjeModal(
                    imageName: "mascot_no",
                    message: "Not enough peanuts yet!\nLet's finish a few more chores first. 🌟",
                    onClose: { activeModal = nil }
                )
            case .addedToBasket:
                TipjeModal(
                    imageName: "mascot_atb",
                    message: "Nice pick! 🎁\nYour reward is in the basket, waiting for you.",
                    onClose: { activeModal = nil }
                )
            case .confettiOverlay:
                TipjeModal(
                    imageName: "mascot_yam",
                    message: "Woohoo! You earned it! 🍦\nEnjoy your treat—you deserve it!",
                    onClose: { activeModal = nil },
                    font: .custom("Inter-Medium", size: 22)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct EmptyShopState: View {
    let image: String
    let text: String
    var body: some View {
        GeometryReader { geometry in
            let mascotHeight = min(geometry.size.height * 0.45, 500) * 1.75
            VStack(spacing: 24) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: mascotHeight)
                    .padding(.top, -100)
                Text(text)
                    .font(.custom("Inter-Medium", size: 24))
                    .foregroundColor(Color(hex: "#8E9293"))
            }
            .padding(.top, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView().environmentObject(Store())
    }
}
#endif 
