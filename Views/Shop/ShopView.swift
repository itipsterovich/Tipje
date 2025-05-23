import SwiftUI

enum ShopTab: String, CaseIterable {
    case rewards = "Rewards"
    case basket = "Basket"
}

struct ShopView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: ShopTab = .rewards // rewards or basket
    @State private var showConfetti = false
    @State private var showNotEnoughPeanuts = false
    @State private var showRewardAnimation = false
    @State private var showAddedToBasket = false
    @State private var showConfettiOverlay = false
    @State private var pendingBasketEntry: BasketEntry? = nil

    private var availableRewards: [Task] {
        store.tasks.filter { $0.kind == .reward && $0.isSelected }
    }
    private var basketEntries: [BasketEntry] {
        store.basket
    }

    var body: some View {
        VStack(spacing: 16) {
            PageTitle("Reward shop")
            BalanceChip(balance: store.balance)
                .padding(.top, 24)
            SubTabBar(
                tabs: ShopTab.allCases,
                selectedTab: $selectedTab,
                title: { $0.rawValue }
            )
            if selectedTab == .rewards {
                if availableRewards.isEmpty {
                    GeometryReader { geometry in
                        let mascotHeight = min(geometry.size.height * 0.45, 500)
                        VStack(spacing: 24) {
                            Image("mascot_peanuts")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: mascotHeight)
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
                            ForEach(availableRewards) { reward in
                                RewardKidCard(task: reward, onTap: {
                                    if store.balance >= reward.peanuts {
                                        withAnimation(.spring()) {
                                            store.purchaseReward(reward)
                                            showConfetti = true
                                            SoundPlayer.shared.playSound(named: "reward.aiff")
                                        }
                                        showAddedToBasket = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            showConfetti = false
                                        }
                                    } else {
                                        showNotEnoughPeanuts = true
                                    }
                                })
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            } else if selectedTab == .basket {
                if basketEntries.isEmpty {
                    GeometryReader { geometry in
                        let mascotHeight = min(geometry.size.height * 0.45, 500)
                        VStack(spacing: 24) {
                            Image("mascot_empty")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: mascotHeight)
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
                            ForEach(basketEntries) { entry in
                                if let reward = store.tasks.first(where: { $0.id == entry.rewardID }) {
                                    RewardKidCard(task: reward, onTap: {
                                        pendingBasketEntry = entry
                                        showConfettiOverlay = true
                                    }, basketMode: true)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            if showConfetti {
                ConfettiOverlay(isPresented: $showConfettiOverlay)
                }
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
        .sheet(isPresented: $showNotEnoughPeanuts) {
            VStack(spacing: 24) {
                Image("mascot_empty_chores")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                Text("You don't have enough peanuts. You can earn them!")
                    .font(.custom("Inter-Medium", size: 24))
                    .foregroundColor(Color(hex: "#8E9293"))
                Button("OK") { showNotEnoughPeanuts = false }
                    .font(.custom("Inter-Medium", size: 20))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(Color(hex: "#EAF3EA"))
                    .foregroundColor(Color(hex: "#799B44"))
                    .cornerRadius(20)
            }
            .padding()
        }
        .sheet(isPresented: $showAddedToBasket) {
            VStack(spacing: 24) {
                Image("mascot_peanuts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                Text("Added to the basket!")
                    .font(.custom("Inter-Medium", size: 24))
                    .foregroundColor(Color(hex: "#8E9293"))
                Button("OK") { showAddedToBasket = false }
                    .font(.custom("Inter-Medium", size: 20))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(Color(hex: "#EAF3EA"))
                    .foregroundColor(Color(hex: "#799B44"))
                    .cornerRadius(20)
            }
            .padding()
        }
        .sheet(isPresented: $showConfettiOverlay, onDismiss: {
            if let entry = pendingBasketEntry {
                store.basket.removeAll { $0.id == entry.id }
                pendingBasketEntry = nil
            }
        }) {
            ConfettiOverlay(isPresented: $showConfettiOverlay)
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
