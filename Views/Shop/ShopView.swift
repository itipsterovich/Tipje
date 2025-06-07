import SwiftUI

enum ShopTab: String, CaseIterable {
    case rewards = "Rewards"
    case basket = "Basket"
}

enum ShopModal: Identifiable {
    case notEnoughPeanuts
    case addedToBasket
    case confettiOverlay
    var id: Int {
        switch self {
        case .notEnoughPeanuts: return 1
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
                    PageTitle("Reward shop")
                        .padding(.top, 24)
                    SubTabBar(
                        tabs: ShopTab.allCases,
                        selectedTab: $selectedTab,
                        title: { $0.rawValue }
                    )
                    if selectedTab == .rewards {
                        if availableRewards.isEmpty {
                            EmptyShopState(image: "mascot_shoping", text: "No rewards available")
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
                                                activeModal = .notEnoughPeanuts
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else if selectedTab == .basket {
                        if basketEntries.isEmpty {
                            EmptyShopState(image: "mascot_empty", text: "No rewards in basket")
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(basketEntries) { entry in
                                        // You may want to resolve reward details from rewardRef if needed
                                        BasketCard(purchase: entry, onConfirm: {
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
                ZStack {
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        ZStack {
                            VStack(spacing: 24) {
                                Spacer().frame(height: 8)
                                Image("mascot_no")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: min(UIScreen.main.bounds.height * 0.32, 340) * 1.4)
                                    .padding(.top, 0)
                                Text("You don't have enough peanuts. Earn them by completing tasks!")
                                    .font(.custom("Inter-Regular_Medium", size: 22))
                                    .foregroundColor(Color(hex: "8E9293"))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 8)
                            }
                            .padding(16)
                            .frame(maxWidth: 340)
                        }
                        Spacer()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            ButtonRegular(iconName: "icon_close", variant: .light) { activeModal = nil }
                                .padding(.top, 24)
                                .padding(.trailing, 24)
                                .shadow(color: .clear, radius: 0)
                        }
                        Spacer()
                    }
                }
            case .addedToBasket:
                ZStack {
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        ZStack {
                            VStack(spacing: 24) {
                                Spacer().frame(height: 8)
                                Image("mascot_atb")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: min(UIScreen.main.bounds.height * 0.32, 340) * 1.4)
                                    .padding(.top, 0)
                                Text("You've just added a new reward to your basket.")
                                    .font(.custom("Inter-Regular_Medium", size: 22))
                                    .foregroundColor(Color(hex: "8E9293"))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 8)
                            }
                            .padding(16)
                            .frame(maxWidth: 340)
                        }
                        Spacer()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            ButtonRegular(iconName: "icon_close", variant: .light) { activeModal = nil }
                                .padding(.top, 24)
                                .padding(.trailing, 24)
                                .shadow(color: .clear, radius: 0)
                        }
                        Spacer()
                    }
                }
            case .confettiOverlay:
                ZStack {
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        ZStack {
                            VStack(spacing: 24) {
                                Spacer().frame(height: 8)
                                Image("mascot_yam")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: min(UIScreen.main.bounds.height * 0.32, 340) * 1.4)
                                    .padding(.top, 0)
                                Text("Well deserved! Have fun enjoying your treat")
                                    .font(.custom("Inter-Medium", size: 22))
                                    .foregroundColor(Color(hex: "8E9293"))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 8)
                            }
                            .padding(16)
                            .frame(maxWidth: 340)
                        }
                        Spacer()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            ButtonRegular(iconName: "icon_close", variant: .light) { activeModal = nil }
                                .padding(.top, 24)
                                .padding(.trailing, 24)
                                .shadow(color: .clear, radius: 0)
                        }
                        Spacer()
                    }
                }
            }
        }
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
