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
    @AppStorage("adminOnboardingComplete") var adminOnboardingComplete: Bool = false
    @EnvironmentObject var store: Store
    @State private var selectedTab: AdminTab = .rules
    @State private var showCatalogueModal = false
    @State private var showCongratsModal = false
    @State private var showNoKidAlert = false
    let bannerHeight: CGFloat = 300
    let cornerRadius: CGFloat = 24
    var onComplete: (() -> Void)? = nil // Optional closure for onboarding flow
    
    // Computed properties for filtering
    var ruleIds: [String] { rulesCatalog.map { $0.id } }
    var filteredRules: [Rule] { store.rules.filter { $0.isActive && ruleIds.contains($0.id) } }
    var choresCatalogIds: [String] { choresCatalog.map { $0.id } }
    var filteredChores: [Chore] { store.chores.filter { $0.isActive && choresCatalogIds.contains($0.id) } }
    var rewardsCatalogIds: [String] { rewardsCatalog.map { $0.id } }
    var filteredRewards: [Reward] { store.rewards.filter { $0.isActive && rewardsCatalogIds.contains($0.id) } }
    var activeRuleIDs: [String] { filteredRules.map { $0.id } }
    var activeChoreIDs: [String] { filteredChores.map { $0.id } }
    var activeRewardIDs: [String] { filteredRewards.map { $0.id } }

    // Extracted banner view
    var adminBanner: some View {
        ZStack {
            Image("il_admin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: bannerHeight * 1.1)
                .offset(x: 14, y: 10)
        }
        .frame(height: bannerHeight)
    }

    // Header view
    var headerView: some View {
        VStack(spacing: 4) {
            PageTitle("Mindful Home Hub") {
                IconRoundButton(iconName: "icon_plus") {
                    showCatalogueModal = true
                }
                .accessibilityIdentifier("addRuleButton")
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
    }

    // Row subviews
    private struct RuleRow: View {
        let rule: Rule
        @EnvironmentObject var store: Store
        var body: some View {
            RuleAdultCard(
                rule: rule,
                onArchive: {
                    if rule.isActive {
                        store.archiveRule(rule)
                    } else {
                        store.addRule(rule)
                    }
                },
                selected: true,
                baseColor: (rulesCatalog.first { $0.id == rule.id }?.color) ?? Color(.systemGray5)
            )
        }
    }
    private struct ChoreRow: View {
        let chore: Chore
        @EnvironmentObject var store: Store
        var body: some View {
            ChoreAdultCard(
                chore: chore,
                onArchive: {
                    if chore.isActive {
                        store.archiveChore(chore)
                    } else {
                        store.addChore(chore)
                    }
                },
                selected: true,
                baseColor: (choresCatalog.first { $0.id == chore.id }?.color) ?? Color(.systemGray5)
            )
        }
    }
    private struct RewardRow: View {
        let reward: Reward
        @EnvironmentObject var store: Store
        var body: some View {
            RewardAdultCard(
                reward: reward,
                onArchive: {
                    if reward.isActive {
                        store.archiveReward(reward)
                    } else {
                        store.addReward(reward)
                    }
                },
                selected: true,
                baseColor: (rewardsCatalog.first { $0.id == reward.id }?.color) ?? Color(.systemGray5)
            )
        }
    }

    // List subviews
    private var rulesList: some View {
        Group {
            if filteredRules.isEmpty {
                TipjeEmptyState(
                    imageName: "mascot_ticket",
                    subtitle: "Start by picking family rules that reflect your values.\nMake sure to fill all tabs—rules, chores, and rewards work together!"
                )
            } else {
                ForEach(filteredRules) { RuleRow(rule: $0).environmentObject(store) }
            }
        }
    }
    private var choresList: some View {
        Group {
            if filteredChores.isEmpty {
                TipjeEmptyState(
                    imageName: "mascot_ticket",
                    subtitle: "Choose daily chores that help build good habits.\nTap ➕ to select from our curated catalog."
                )
            } else {
                ForEach(filteredChores) { ChoreRow(chore: $0).environmentObject(store) }
            }
        }
    }
    private var rewardsList: some View {
        Group {
            if filteredRewards.isEmpty {
                TipjeEmptyState(
                    imageName: "mascot_ticket",
                    subtitle: "Add real-life rewards your kids will be excited to earn.\nTap ➕ to choose from our handpicked selection."
                )
            } else {
                ForEach(filteredRewards) { RewardRow(reward: $0).environmentObject(store) }
            }
        }
    }

    // Extracted main content view
    var adminContent: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView(showsIndicators: true) {
                VStack(spacing: 14) {
                    switch selectedTab {
                    case .rules:   rulesList
                    case .chores:  choresList
                    case .shop:    rewardsList
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

    // Modal switch as a @ViewBuilder
    @ViewBuilder
    private func catalogModal() -> some View {
        switch selectedTab {
        case .rules:
            CatalogRulesModal(
                onSave: handleRulesSave(_:),
                initiallySelected: activeRuleIDs
            )
        case .chores:
            CatalogChoresModal(
                onSave: handleChoresSave(_:),
                initiallySelected: activeChoreIDs
            )
            .accessibilityIdentifier("choresCatalogModal")
        case .shop:
            CatalogRewardsModal(
                onSave: handleRewardsSave(_:),
                initiallySelected: activeRewardIDs
            )
            .accessibilityIdentifier("rewardsCatalogModal")
        }
    }

    // Save handlers
    private func handleRulesSave(_ selectedIds: [String]) {
        guard store.selectedKid != nil else { showNoKidAlert = true; return }
        // Archive rules that are active and in the catalog but not selected
        for rule in store.rules.filter({ $0.isActive && rulesCatalog.map { $0.id }.contains($0.id) }) {
            if !selectedIds.contains(rule.id) {
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
    }
    private func handleChoresSave(_ selectedIds: [String]) {
        guard store.selectedKid != nil else { showNoKidAlert = true; return }
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
    }
    private func handleRewardsSave(_ selectedIds: [String]) {
        guard store.selectedKid != nil else { showNoKidAlert = true; return }
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
    }

    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: bannerHeight,
            bannerContent: { adminBanner },
            content: { adminContent }
        )
        .fullScreenCover(isPresented: $showCatalogueModal) {
            catalogModal()
                .environmentObject(store)
        }
        .sheet(isPresented: $showCongratsModal) {
            TipjeModal(
                imageName: "on_4",
                message: "🎉 All set! Tasks are live at home. 🔒 Admin is now PIN-locked.",
                onClose: {
                    showCongratsModal = false
                    adminOnboardingComplete = true
                    let userId = store.userId
                    if !userId.isEmpty {
                        FirestoreManager.shared.setAdminOnboardingComplete(userId: userId) { _ in }
                    }
                    onComplete?()
                }
            )
            .accessibilityIdentifier("adminSuccessModal")
        }
        .onChange(of: filteredRules.count) { _ in checkShowCongrats() }
        .onChange(of: filteredChores.count) { _ in checkShowCongrats() }
        .onChange(of: filteredRewards.count) { _ in checkShowCongrats() }
        .onAppear { checkShowCongrats() }
        .alert(isPresented: $showNoKidAlert) {
            Alert(
                title: Text("No Kid Selected"),
                message: Text("Please add and select a kid before adding rules, chores, or rewards."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func checkShowCongrats() {
        let hasAll = !filteredRules.isEmpty && !filteredChores.isEmpty && !filteredRewards.isEmpty
        if hasAll && !adminOnboardingComplete && !showCongratsModal {
            showCongratsModal = true
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
