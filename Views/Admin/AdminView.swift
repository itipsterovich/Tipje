import SwiftUI

enum AdminTab: String, CaseIterable, Identifiable {
    case rules = "Rules"
    case chores = "Chores"
    case shop = "Shop"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .rules: return "list.bullet"
        case .chores: return "checkmark.circle"
        case .shop: return "cart"
        }
    }
}

struct BannerOnly<Content: View>: View {
    let bannerColor: Color
    let bannerHeight: CGFloat
    let bannerContent: () -> AnyView
    let content: () -> Content

    init<BC: View>(
        bannerColor: Color,
        bannerHeight: CGFloat,
        @ViewBuilder bannerContent: @escaping () -> BC,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bannerColor = bannerColor
        self.bannerHeight = bannerHeight
        self.bannerContent = { AnyView(bannerContent()) }
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            bannerColor
                .frame(height: bannerHeight)
                .edgesIgnoringSafeArea(.top)
            bannerContent()
                .frame(height: bannerHeight)
                .clipped()
            content()
                .padding(.top, bannerHeight)
        }
    }
}

struct AdminView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: AdminTab = .rules
    @State private var showCatalogueModal = false
    let bannerHeight: CGFloat = 300
    let cornerRadius: CGFloat = 24
    
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: bannerHeight,
            bannerContent: {
                ZStack {
                    Image("il_admin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: bannerHeight * 1.1)
                        .offset(x: 14, y: 10)
                }
                .frame(height: bannerHeight)
            },
            content: {
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        PageTitle("Your mindful home") {
                            IconRoundButton(iconName: "icon_plus") {
                                showCatalogueModal = true
                            }
                        }
                        .padding(.top, 14)
                        SubTabBar(
                            tabs: AdminTab.allCases,
                            selectedTab: $selectedTab,
                            title: { $0.rawValue }
                        )
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 24)
                    ScrollView(showsIndicators: true) {
                        VStack(spacing: 14) {
                            if selectedTab == .rules {
                                let filteredRules = store.rules.filter { $0.isActive && rulesCatalog.map { $0.id }.contains($0.id) }
                                if filteredRules.isEmpty {
                                    EmptyAdminState(image: "mascot_empty", text: "You don't have family rules yet")
                                } else {
                                    ForEach(filteredRules) { rule in
                                        let catalogItem = rulesCatalog.first(where: { $0.id == rule.id })
                                        RuleAdultCard(
                                            rule: rule,
                                            selected: true,
                                            baseColor: catalogItem?.color ?? Color(.systemGray5),
                                            onTap: {
                                                // Toggle selection: archive if selected, add if not
                                                if rule.isActive {
                                                    store.archiveRule(rule)
                                                } else {
                                                    store.addRule(rule)
                                                }
                                            }
                                        )
                                    }
                                }
                            } else if selectedTab == .chores {
                                let choresCatalogIds = choresCatalog.map { $0.id }
                                let filteredChores = store.chores.filter { $0.isActive && choresCatalogIds.contains($0.id) }
                                if filteredChores.isEmpty {
                                    EmptyAdminState(image: "mascot_ticket", text: "You don't have chores yet")
                                } else {
                                    ForEach(filteredChores) { chore in
                                        ChoreAdultCard(chore: chore, onArchive: { store.archiveChore(chore) })
                                    }
                                }
                            } else if selectedTab == .shop {
                                let rewardsCatalogIds = rewardsCatalog.map { $0.id }
                                let filteredRewards = store.rewards.filter { $0.isActive && rewardsCatalogIds.contains($0.id) }
                                if filteredRewards.isEmpty {
                                    EmptyAdminState(image: "mascot_shoping", text: "You don't have rewards yet")
                                } else {
                                    ForEach(filteredRewards) { reward in
                                        RewardAdultCard(reward: reward, onArchive: { store.archiveReward(reward) })
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
                .background(
                    RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
                        .fill(Color.white)
                )
            }
        )
        .fullScreenCover(isPresented: $showCatalogueModal) {
            switch selectedTab {
            case .rules:
                CatalogRulesModal(
                    onSave: { selectedIds in
                        print("[DEBUG] AdminView CatalogRulesModal onSave called with: \(selectedIds)")
                        print("[DEBUG] Current store.rules IDs: \(store.rules.map { $0.id })")
                        print("[DEBUG] store.rules: \n" + store.rules.map { "id=\($0.id), isActive=\($0.isActive)" }.joined(separator: ", "))
                        // Archive rules that are active and in the catalog but not selected
                        for rule in store.rules.filter({ $0.isActive && rulesCatalog.map { $0.id }.contains($0.id) }) {
                            if !selectedIds.contains(rule.id) {
                                print("[DEBUG] Archiving rule with id: \(rule.id)")
                                store.archiveRule(rule)
                            }
                        }
                        // Add or reactivate selected rules from the catalog
                        for id in selectedIds {
                            if let rule = store.rules.first(where: { $0.id == id }) {
                                if !rule.isActive {
                                    if let cat = rulesCatalog.first(where: { $0.id == id }) {
                                        var reactivated = rule
                                        reactivated.title = cat.title
                                        reactivated.peanutValue = cat.peanuts
                                        reactivated.isActive = true
                                        store.addRule(reactivated)
                                    }
                                }
                            } else if let cat = rulesCatalog.first(where: { $0.id == id }) {
                                let newRule = Rule(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                                store.addRule(newRule)
                            }
                        }
                        showCatalogueModal = false
                    },
                    initiallySelected: store.rules.filter { $0.isActive && rulesCatalog.map { $0.id }.contains($0.id) }.map { $0.id }
                )
                .environmentObject(store)
            case .chores:
                let choresCatalog: [CatalogChore] = [
                    CatalogChore(id: "chore1", title: "Make your bed", peanuts: 2, color: Color(hex: "#A7AD7F")),
                    CatalogChore(id: "chore2", title: "Feed the pet", peanuts: 2, color: Color(hex: "#AD807F")),
                    CatalogChore(id: "chore3", title: "Take out the trash", peanuts: 2, color: Color(hex: "#D5A412")),
                    CatalogChore(id: "chore4", title: "Water the plants", peanuts: 2, color: Color(hex: "#7FAD98")),
                    CatalogChore(id: "chore5", title: "Set the table", peanuts: 2, color: Color(hex: "#ADA57F"))
                ]
                let choresCatalogIds = choresCatalog.map { $0.id }
                CatalogChoresModal(onSave: { selectedIds in
                    // Archive chores that are active and in the catalog but not selected
                    for chore in store.chores.filter({ $0.isActive && choresCatalog.map { $0.id }.contains($0.id) }) {
                        if !selectedIds.contains(chore.id) {
                            store.archiveChore(chore)
                        }
                    }
                    // Add or reactivate selected chores from the catalog
                    for id in selectedIds {
                        if let chore = store.chores.first(where: { $0.id == id }) {
                            if !chore.isActive {
                                if let cat = choresCatalog.first(where: { $0.id == id }) {
                                    var reactivated = chore
                                    reactivated.title = cat.title
                                    reactivated.peanutValue = cat.peanuts
                                    reactivated.isActive = true
                                    store.addChore(reactivated)
                                }
                            }
                        } else if let cat = choresCatalog.first(where: { $0.id == id }) {
                            let newChore = Chore(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                            store.addChore(newChore)
                        }
                    }
                    showCatalogueModal = false
                })
                .environmentObject(store)
            case .shop:
                let rewardsCatalog: [CatalogReward] = [
                    CatalogReward(id: "reward1", title: "Extra 10 min screen time", peanuts: 10, color: Color(hex: "#D78C28")),
                    CatalogReward(id: "reward2", title: "Choose dessert", peanuts: 8, color: Color(hex: "#7F9BAD")),
                    CatalogReward(id: "reward3", title: "Sticker pack", peanuts: 5, color: Color(hex: "#A7AD7F")),
                    CatalogReward(id: "reward4", title: "Family movie night", peanuts: 15, color: Color(hex: "#AD807F")),
                    CatalogReward(id: "reward5", title: "Small toy", peanuts: 20, color: Color(hex: "#D5A412"))
                ]
                let rewardsCatalogIds = rewardsCatalog.map { $0.id }
                CatalogRewardsModal(onSave: { selectedIds in
                    // Archive rewards that are active and in the catalog but not selected
                    for reward in store.rewards.filter({ $0.isActive && rewardsCatalog.map { $0.id }.contains($0.id) }) {
                        if !selectedIds.contains(reward.id) {
                            store.archiveReward(reward)
                        }
                    }
                    // Add or reactivate selected rewards from the catalog
                    for id in selectedIds {
                        if let reward = store.rewards.first(where: { $0.id == id }) {
                            if !reward.isActive {
                                if let cat = rewardsCatalog.first(where: { $0.id == id }) {
                                    var reactivated = reward
                                    reactivated.title = cat.title
                                    reactivated.cost = cat.peanuts
                                    reactivated.isActive = true
                                    store.addReward(reactivated)
                                }
                            }
                        } else if let cat = rewardsCatalog.first(where: { $0.id == id }) {
                            let newReward = Reward(id: cat.id, title: cat.title, cost: cat.peanuts, isActive: true)
                            store.addReward(newReward)
                        }
                    }
                    showCatalogueModal = false
                })
                .environmentObject(store)
            }
        }
    }
    
    private func currentKind(for tab: AdminTab) -> TaskKind {
        switch tab {
        case .rules: return .rule
        case .chores: return .chore
        case .shop: return .reward
        }
    }
}

struct EmptyAdminState: View {
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
                    .padding(.top, -35)
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

// Minimal test view for debugging interaction issues
struct MinimalTestView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        VStack(spacing: 24) {
            Text("Minimal Test View")
                .font(.title)
            SubTabBar(
                tabs: [0, 1],
                selectedTab: $selectedTab,
                title: { $0 == 0 ? "Tab One" : "Tab Two" }
            )
            Button(action: {
                print("MinimalTestView: Button tapped")
            }) {
                Text("Tap Me")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct MinimalBannerTestView: View {
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: 300,
            bannerContent: {
                ZStack {
                    Image("il_admin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300 * 1.1)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .clipped()
                        .offset(x: 14, y: 10 )
                }
                .frame(height: 300)
            },
            content: {
                MinimalTestView()
            }
        )
    }
}

#if DEBUG
struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView().environmentObject(Store())
    }
}

struct MinimalTestView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalTestView()
    }
}

struct MinimalBannerTestView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalBannerTestView()
    }
}
#endif 
