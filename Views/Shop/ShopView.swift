import SwiftUI
#if os(iOS)
import UIKit
#endif

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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            ShopViewiPhone()
        } else {
            ShopViewiPad()
        }
    }
}

// =======================
// iPhone layout
// =======================
struct ShopViewiPhone: View {
    @EnvironmentObject var store: TipjeStore
    @State private var selectedTab: ShopTab = .rewards
    @State private var showConfetti = false
    @State private var activeModal: ShopModal? = nil
    @State private var pendingPurchase: RewardPurchase? = nil
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")

    private var availableRewards: [Reward] {
        store.rewards.filter { $0.isActive }
    }
    private var basketEntries: [RewardPurchase] {
        store.rewardPurchases.filter { $0.status == "IN_BASKET" }
    }

    private func rewardCard(for reward: Reward) -> some View {
        let catalogReward = (rewardsCatalog + store.customRewards).first(where: { $0.id == reward.id })
        let title = catalogReward?.title ?? reward.title
        let peanuts = catalogReward?.peanuts ?? reward.cost
        let canBuy = store.balance >= peanuts
        let displayReward = Reward(id: reward.id, title: title, cost: peanuts, isActive: reward.isActive)
        return RewardKidCard(
            reward: displayReward,
            canBuy: canBuy,
            onTap: {
                if canBuy {
                    store.purchaseReward(reward)
                    showConfetti = true
                    SoundPlayer.shared.playSound(named: "reward.aiff")
                    toastMessage = "Yay! Added to your Basket"
                    toastIcon = "cart.fill"
                    toastIconColor = Color(hex: "#799B44")
                    withAnimation { showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }
                } else {
                    activeModal = .notEnoughPeanutsForReward
                }
            }
        )
        .frame(maxWidth: .infinity)
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
                            .font(.custom("Inter-Regular_Bold", size: 64))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Text("peanuts earned")
                                .font(.custom("Inter-Regular_Medium", size: 22))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(.top, -8)
                        Spacer()
                    }
                    .padding(.top, 36)
                }
                .frame(height: 300)
            },
            content: {
                VStack(spacing: 16) {
                    PageTitle("Reward Shop")
                        .padding(.top, 14)
                    SubTabBar(
                        tabs: ShopTab.allCases,
                        selectedTab: $selectedTab,
                        title: { $0.rawValue }
                    )
                    if selectedTab == .rewards {
                        if availableRewards.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_empty",
                                subtitle: "Your reward shop is getting ready!\nAsk your grown-up to add fun things you can earn.",
                                imageHeight: 250
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(availableRewards) { reward in
                                        rewardCard(for: reward)
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    } else if selectedTab == .basket {
                        if basketEntries.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_empty",
                                subtitle: "No rewards in basket yet. Add some rewards to your basket to get started!",
                                imageHeight: 250
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(basketEntries) { entry in
                                        BasketCard(purchase: entry, onConfirm: {
                                            store.decrementOrRemovePurchase(purchase: entry)
                                            pendingPurchase = entry
                                            activeModal = .confettiOverlay
                                        })
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    }
                }
                .font(.custom("Inter-Medium", size: 17))
                .ignoresSafeArea(.container, edges: .horizontal)
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
        .onAppear {
            print("[ShopViewiPhone] Appeared. UserId: \(store.userId), Balance: \(store.balance), Kids: \(store.kids.map { $0.name })")
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .overlay(
            Group {
                if showToast {
                    AppleStyleToast(message: toastMessage, systemImage: toastIcon, iconColor: toastIconColor)
                        .zIndex(1)
                }
            },
            alignment: .center
        )
    }
}

// =======================
// iPad layout
// =======================
struct ShopViewiPad: View {
    @EnvironmentObject var store: TipjeStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: ShopTab = .rewards
    @State private var showConfetti = false
    @State private var activeModal: ShopModal? = nil
    @State private var pendingPurchase: RewardPurchase? = nil
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")

    private var availableRewards: [Reward] {
        store.rewards.filter { $0.isActive }
    }
    private var basketEntries: [RewardPurchase] {
        store.rewardPurchases.filter { $0.status == "IN_BASKET" }
    }

    private func rewardCard(for reward: Reward) -> some View {
        let catalogReward = (rewardsCatalog + store.customRewards).first(where: { $0.id == reward.id })
        let title = catalogReward?.title ?? reward.title
        let peanuts = catalogReward?.peanuts ?? reward.cost
        let canBuy = store.balance >= peanuts
        let displayReward = Reward(id: reward.id, title: title, cost: peanuts, isActive: reward.isActive)
        return RewardKidCard(
            reward: displayReward,
            canBuy: canBuy,
            onTap: {
                if canBuy {
                    store.purchaseReward(reward)
                    showConfetti = true
                    SoundPlayer.shared.playSound(named: "reward.aiff")
                    toastMessage = "Yay! Added to your Basket"
                    toastIcon = "cart.fill"
                    toastIconColor = Color(hex: "#799B44")
                    withAnimation { showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }
                } else {
                    activeModal = .notEnoughPeanutsForReward
                }
            }
        )
        .frame(maxWidth: .infinity)
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
                                subtitle: "Your reward shop is getting ready!\nAsk your grown-up to add fun things you can earn.",
                                imageHeight: 400,
                                topPadding: -200
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(availableRewards) { reward in
                                        rewardCard(for: reward)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else if selectedTab == .basket {
                        if basketEntries.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_empty",
                                subtitle: "No rewards in basket yet. Add some rewards to your basket to get started!",
                                imageHeight: 600,
                                topPadding: 0
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(basketEntries) { entry in
                                        BasketCard(purchase: entry, onConfirm: {
                                            store.decrementOrRemovePurchase(purchase: entry)
                                            pendingPurchase = entry
                                            activeModal = .confettiOverlay
                                        })
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                }
                .font(.custom("Inter-Regular_Medium", size: 24))
                .padding(.horizontal, 24)
                .ignoresSafeArea(.container, edges: .horizontal)
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
        .onAppear {
            print("[ShopViewiPad] Appeared. UserId: \(store.userId), Balance: \(store.balance), Kids: \(store.kids.map { $0.name })")
        }
        .overlay(
            Group {
                if showToast {
                    AppleStyleToast(message: toastMessage, systemImage: toastIcon, iconColor: toastIconColor)
                        .zIndex(1)
                }
            },
            alignment: .center
        )
    }
}

struct EmptyShopState: View {
    let image: String
    let text: String
    var body: some View {
        GeometryReader { geometry in
            let mascotHeight: CGFloat = 500
            VStack(spacing: 24) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: mascotHeight)
                    .padding(.top, -100)
                Text(text)
                    .font(.custom("Inter-Regular_Medium", size: 24))
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
        ShopView().environmentObject(TipjeStore())
    }
}
#endif 
