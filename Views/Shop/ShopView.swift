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
    @State private var selectedTab: ShopTab = .rewards // rewards or basket
    @State private var showConfetti = false
    @State private var activeModal: ShopModal? = nil
    @State private var pendingBasketEntry: BasketEntry? = nil

    private var availableRewards: [Task] {
        store.tasks.filter { $0.kind == .reward && $0.isSelected }
    }
    private var basketEntries: [BasketEntry] {
        store.basket
    }

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#C2A3A4"),
            bannerHeight: 300,
            bannerContent: {
                ZStack {
                    // Left and right illustrations attached to edges
              
                    // Top center mascot (same as HomeView)
                    Image("il_home")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .offset(y: -40) // Move mascot higher
                    // Large balance display, centered and floating
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(store.balance)")
                            .font(.system(size: 84, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            Text("peanuts earned")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(.top, -8)
                        Spacer()
                    }
                    .padding(.top, 40)
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
                            GeometryReader { geometry in
                                let mascotHeight = min(geometry.size.height * 0.45, 500) * 1.75
                                VStack(spacing: 24) {
                                    Image("mascot_shoping")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: mascotHeight)
                                        .padding(.top, -100)
                                    Text("No rewards available")
                                        .font(.custom("Inter-Medium", size: 24))
                                        .foregroundColor(Color(hex: "#8E9293"))
                                }
                                .padding(.top, 32)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(Array(availableRewards.enumerated()), id: \ .element.id) { index, reward in
                                        let color = colorForIndex(index)
                                        RewardKidCard(task: reward, onTap: {
                                            if store.balance >= reward.peanuts {
                                                withAnimation(.spring()) {
                                                    store.purchaseReward(reward)
                                                    showConfetti = true
                                                    SoundPlayer.shared.playSound(named: "reward.aiff")
                                                }
                                                activeModal = .addedToBasket
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    showConfetti = false
                                                }
                                            } else {
                                                activeModal = .notEnoughPeanuts
                                            }
                                        }, backgroundColor: color)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else if selectedTab == .basket {
                        if basketEntries.isEmpty {
                            GeometryReader { geometry in
                                let mascotHeight = min(geometry.size.height * 0.45, 500) * 1.75
                                VStack(spacing: 24) {
                                    Image("mascot_empty")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: mascotHeight)
                                        .padding(.top, -100)
                                    Text("No rewards in basket")
                                        .font(.custom("Inter-Medium", size: 24))
                                        .foregroundColor(Color(hex: "#8E9293"))
                                }
                                .padding(.top, 32)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(Array(basketEntries.enumerated()), id: \ .element.id) { index, entry in
                                        if let reward = store.tasks.first(where: { $0.id == entry.rewardID }) {
                                            let color = colorForIndex(index)
                                            RewardKidCard(task: reward, onTap: {
                                                pendingBasketEntry = entry
                                                activeModal = .confettiOverlay
                                            }, basketMode: true, backgroundColor: color)
                                        }
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
            if activeModal == .confettiOverlay, let entry = pendingBasketEntry {
                store.basket.removeAll { $0.id == entry.id }
                pendingBasketEntry = nil
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
                                    .font(.custom("Inter-Medium", size: 22))
                                    .foregroundColor(Color(hex: "#8E9293"))
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
                            IconRoundButton(iconName: "icon_close") { activeModal = nil }
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
                                    .font(.custom("Inter-Medium", size: 22))
                                    .foregroundColor(Color(hex: "#8E9293"))
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
                            IconRoundButton(iconName: "icon_close") { activeModal = nil }
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
                                    .foregroundColor(Color(hex: "#8E9293"))
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
                            IconRoundButton(iconName: "icon_close") { activeModal = nil }
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

#if DEBUG
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView().environmentObject(Store())
    }
}
#endif 
