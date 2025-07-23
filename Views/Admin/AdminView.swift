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

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct AdminView: View {
    @EnvironmentObject var store: TipjeStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var onComplete: (() -> Void)? = nil
    var body: some View {
        if horizontalSizeClass == .compact {
            AdminViewiPhone(onComplete: onComplete).environmentObject(store)
        } else {
            AdminViewiPad(onComplete: onComplete).environmentObject(store)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct AdminViewiPhone: View {
    @EnvironmentObject var store: TipjeStore
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var adminOnboardingComplete: Bool = false
    var adminOnboardingKey: String { "adminOnboardingComplete_\(store.userId)" }
    @State private var selectedTab: AdminTab = .rules
    @State private var showCatalogueModal = false
    @State private var showCongratsModal = false
    @State private var showNoKidAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRuleId: String? = nil
    @State private var expandedChoreId: String? = nil
    @State private var expandedRewardId: String? = nil
    let bannerHeight: CGFloat = 300
    let cornerRadius: CGFloat = 24
    var onComplete: (() -> Void)? = nil
    // Computed properties for filtering
    var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var filteredRewards: [Reward] { store.rewards.filter { $0.isActive } }
    var activeRuleIDs: [String] { filteredRules.map { $0.id } }
    var activeChoreIDs: [String] { filteredChores.map { $0.id } }
    var activeRewardIDs: [String] { filteredRewards.map { $0.id } }
    // Extracted banner view
    var adminBanner: some View {
        ZStack {
            Image("il_admin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: bannerHeight * 1.3)
                .offset(x: 14, y: 10)
        }
        .frame(height: bannerHeight)
    }
    // Header view
    var headerView: some View {
        VStack(spacing: 4) {
            PageTitle(NSLocalizedString("admin_title", tableName: nil, bundle: Bundle.main, value: "", comment: "")) {
                IconRoundButton(iconName: "icon_plus") {
                    showCatalogueModal = true
                }
                .accessibilityIdentifier("addRuleButton")
            }
            .padding(.top, 14)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            print("[DEBUG] PageTitle width: \(geo.size.width)")
                        }
                }
            )
            SubTabBar(
                tabs: AdminTab.allCases,
                selectedTab: $selectedTab,
                title: { tab in
                    switch tab {
                    case .rules: return NSLocalizedString("admin_tab_rules", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    case .chores: return NSLocalizedString("admin_tab_chores", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    case .shop: return NSLocalizedString("admin_tab_shop", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                }
            )
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            print("[DEBUG] SubTabBar width: \(geo.size.width)")
                        }
                }
            )
        }
    }
    // Row subviews
    private struct RuleRow: View {
        let rule: Rule
        let baseColor: Color
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedRuleId: String?
        
        // Create localized rule with catalog title
        private var localizedRule: Rule {
            var localized = rule
            if let catalogRule = getLocalizedRulesCatalog().first(where: { $0.id == rule.id }) {
                localized.title = catalogRule.title
            }
            return localized
        }
        
        var body: some View {
            RuleAdultCard(
                rule: localizedRule, // Use localized rule instead of original
                onArchive: {
                    if rule.isActive {
                        store.archiveRule(rule)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addRule(rule)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: baseColor,
                onTap: {
                    if expandedRuleId == rule.id {
                        expandedRuleId = nil
                    } else {
                        expandedRuleId = rule.id
                    }
                },
                expanded: expandedRuleId == rule.id
            )
        }
    }
    private struct ChoreRow: View {
        let chore: Chore
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedChoreId: String?
        
        // Create localized chore with catalog title
        private var localizedChore: Chore {
            var localized = chore
            if let catalogChore = getLocalizedChoresCatalog().first(where: { $0.id == chore.id }) {
                localized.title = catalogChore.title
            }
            return localized
        }
        
        var body: some View {
            ChoreAdultCard(
                chore: localizedChore, // Use localized chore instead of original
                onArchive: {
                    if chore.isActive {
                        store.archiveChore(chore)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addChore(chore)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: (getLocalizedChoresCatalog() + store.customChores).first { $0.id == chore.id }?.color ?? Color(.systemGray5),
                onTap: {
                    if expandedChoreId == chore.id {
                        expandedChoreId = nil
                    } else {
                        expandedChoreId = chore.id
                    }
                },
                expanded: expandedChoreId == chore.id
            )
        }
    }
    private struct RewardRow: View {
        let reward: Reward
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedRewardId: String?
        
        // Create localized reward with catalog title
        private var localizedReward: Reward {
            var localized = reward
            if let catalogReward = getLocalizedRewardsCatalog().first(where: { $0.id == reward.id }) {
                localized.title = catalogReward.title
            }
            return localized
        }
        
        var body: some View {
            RewardAdultCard(
                reward: localizedReward, // Use localized reward instead of original
                onArchive: {
                    if reward.isActive {
                        store.archiveReward(reward)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addReward(reward)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: (getLocalizedRewardsCatalog() + store.customRewards).first { $0.id == reward.id }?.color ?? Color(.systemGray5),
                onTap: {
                    if expandedRewardId == reward.id {
                        expandedRewardId = nil
                    } else {
                        expandedRewardId = reward.id
                    }
                },
                expanded: expandedRewardId == reward.id
            )
        }
    }
    // List subviews
    private var rulesList: some View {
        Group {
            if filteredRules.isEmpty {
                TipjeEmptyStateiPhone(
                    imageName: "mascot_ticket",
                    subtitle: NSLocalizedString("empty_admin_rules", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                    imageHeight: 300,
                    topPadding: 25,
                    centered: true
                )
            } else {
                ForEach(Array(filteredRules.enumerated()), id: \.element.id) { index, rule in
                    RuleRow(
                        rule: rule,
                        baseColor: (getLocalizedRulesCatalog() + store.customRules).first { $0.id == rule.id }?.color ?? Color(.systemGray5),
                        showToast: $showToast,
                        toastMessage: $toastMessage,
                        toastIcon: $toastIcon,
                        toastIconColor: $toastIconColor,
                        expandedRuleId: $expandedRuleId
                    ).environmentObject(store)
                }
            }
        }
    }
    private var choresList: some View {
        Group {
            if filteredChores.isEmpty {
                TipjeEmptyStateiPhone(
                    imageName: "mascot_ticket",
                    subtitle: NSLocalizedString("empty_admin_chores", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                    imageHeight: 300,
                    topPadding: 25,
                    centered: true
                )
            } else {
                ForEach(filteredChores) { ChoreRow(chore: $0, showToast: $showToast, toastMessage: $toastMessage, toastIcon: $toastIcon, toastIconColor: $toastIconColor, expandedChoreId: $expandedChoreId).environmentObject(store) }
            }
        }
    }
    private var rewardsList: some View {
        Group {
            if filteredRewards.isEmpty {
                TipjeEmptyStateiPhone(
                    imageName: "mascot_ticket",
                    subtitle: NSLocalizedString("empty_admin_rewards", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                    imageHeight: 300,
                    topPadding: 25,
                    centered: true
                )
            } else {
                ForEach(filteredRewards) { RewardRow(reward: $0, showToast: $showToast, toastMessage: $toastMessage, toastIcon: $toastIcon, toastIconColor: $toastIconColor, expandedRewardId: $expandedRewardId).environmentObject(store) }
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
                .padding(.top, 8)
            }
        }
        .ignoresSafeArea(.container, edges: .horizontal)
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
    // Modal switch as a @ViewBuilder
    @ViewBuilder
    private func catalogModal() -> some View {
        switch selectedTab {
        case .rules:
            CatalogRulesModal(
                onSave: handleRulesSave(_:customRules:),
                initiallySelected: activeRuleIDs
            )
            .environmentObject(LocalizationManager.shared)
        case .chores:
            CatalogChoresModal(
                onSave: handleChoresSave(_:customChores:),
                initiallySelected: activeChoreIDs
            )
            .environmentObject(LocalizationManager.shared)
            .accessibilityIdentifier("choresCatalogModal")
        case .shop:
            CatalogRewardsModal(
                onSave: handleRewardsSave(_:customRewards:),
                initiallySelected: activeRewardIDs
            )
            .environmentObject(LocalizationManager.shared)
            .accessibilityIdentifier("rewardsCatalogModal")
        }
    }
    // Save handlers
    private func handleRulesSave(_ selectedIds: [String], customRules: [CatalogRule]) {
        guard let kid = store.selectedKid else { showNoKidAlert = true; return }
        // Archive rules that are active and in the catalog but not selected
        for rule in store.rules.filter({ $0.isActive && (getLocalizedRulesCatalog().map { $0.id } + customRules.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(rule.id) {
                store.archiveRule(rule)
            }
        }
        // Add or reactivate selected rules from the catalog or custom
        let allCatalogRules = getLocalizedRulesCatalog() + customRules
        for id in selectedIds {
            if let rule = store.rules.first(where: { $0.id == id }) {
                if !rule.isActive {
                    if let cat = allCatalogRules.first(where: { $0.id == id }) {
                        var reactivated = rule
                        reactivated.title = cat.title
                        reactivated.peanutValue = cat.peanuts
                        reactivated.isActive = true
                        print("[DEBUG] Reactivating rule: \(reactivated)")
                        store.addRule(reactivated)
                        // Also write to Firestore under kid's rules collection
                        FirestoreManager.shared.addRule(userId: store.userId, kidId: kid.id, rule: reactivated) { _ in }
                    }
                }
            } else if let cat = allCatalogRules.first(where: { $0.id == id }) {
                // This will catch both curated and custom rules
                let newRule = Rule(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                print("[DEBUG] Adding new rule: \(newRule)")
                store.addRule(newRule)
                // Also write to Firestore under kid's rules collection
                FirestoreManager.shared.addRule(userId: store.userId, kidId: kid.id, rule: newRule) { _ in }
            } else {
                print("[DEBUG] Could not find CatalogRule for id: \(id)")
            }
        }
        // Ensure Admin always reflects the latest custom rules
        store.customRules = customRules
        showCatalogueModal = false
    }
    private func handleChoresSave(_ selectedIds: [String], customChores: [CatalogChore]) {
        guard store.selectedKid != nil else { showNoKidAlert = true; return }
        // Archive chores that are active and in the catalog (curated or custom) but not selected
        for chore in store.chores.filter({ $0.isActive && (getLocalizedChoresCatalog().map { $0.id } + customChores.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(chore.id) {
                store.archiveChore(chore)
            }
        }
        // Add or reactivate selected chores from the catalog or custom
        let allCatalogChores = getLocalizedChoresCatalog() + customChores
        for id in selectedIds {
            if let chore = store.chores.first(where: { $0.id == id }) {
                if !chore.isActive {
                    if let cat = allCatalogChores.first(where: { $0.id == id }) {
                        var reactivated = chore
                        reactivated.title = cat.title
                        reactivated.peanutValue = cat.peanuts
                        reactivated.isActive = true
                        store.addChore(reactivated)
                    }
                }
            } else if let cat = allCatalogChores.first(where: { $0.id == id }) {
                let newChore = Chore(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                store.addChore(newChore)
            }
        }
        // Ensure Admin always reflects the latest custom chores
        store.customChores = customChores
        showCatalogueModal = false
    }
    private func handleRewardsSave(_ selectedIds: [String], customRewards: [CatalogReward]) {
        guard let kid = store.selectedKid else { showNoKidAlert = true; return }
        // Archive rewards that are active and in the catalog (curated or custom) but not selected
        for reward in store.rewards.filter({ $0.isActive && (getLocalizedRewardsCatalog().map { $0.id } + customRewards.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(reward.id) {
                store.archiveReward(reward)
            }
        }
        // Add or reactivate selected rewards from the catalog or custom
        let allCatalogRewards = getLocalizedRewardsCatalog() + customRewards
        for id in selectedIds {
            if let reward = store.rewards.first(where: { $0.id == id }) {
                if !reward.isActive {
                    if let cat = allCatalogRewards.first(where: { $0.id == id }) {
                        var reactivated = reward
                        reactivated.title = cat.title
                        reactivated.cost = cat.peanuts
                        reactivated.isActive = true
                        store.addReward(reactivated)
                        // Also write to Firestore under kid's rewards collection
                        FirestoreManager.shared.addReward(userId: store.userId, kidId: kid.id, reward: reactivated) { _ in }
                    }
                }
            } else if let cat = allCatalogRewards.first(where: { $0.id == id }) {
                let newReward = Reward(id: cat.id, title: cat.title, cost: cat.peanuts, isActive: true)
                store.addReward(newReward)
                // Also write to Firestore under kid's rewards collection
                FirestoreManager.shared.addReward(userId: store.userId, kidId: kid.id, reward: newReward) { _ in }
            }
        }
        // Ensure Admin always reflects the latest custom rewards
        store.customRewards = customRewards
        showCatalogueModal = false;
    }
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    print("[DEBUG] AdminViewiPhone geometry: \(geo.size)")
                }
            BannerPanelLayout(
                bannerColor: Color(hex: "#A2AFC1"),
                bannerHeight: bannerHeight,
                bannerContent: { adminBanner },
                content: { adminContent }
            )
            .id(localizationManager.currentLanguage)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showCatalogueModal) {
            catalogModal()
                .environmentObject(store)
        }
        .sheet(isPresented: $showCongratsModal) {
            TipjeModal(
                imageName: "on_4",
                message: NSLocalizedString("admin_all_set_modal", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                onClose: {
                    showCongratsModal = false
                    adminOnboardingComplete = true
                    UserDefaults.standard.set(true, forKey: adminOnboardingKey)
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
        .onAppear {
            print("[AdminViewiPhone] Appeared. UserId: \(store.userId), Kids: \(store.kids.map { $0.name })")
            adminOnboardingComplete = UserDefaults.standard.bool(forKey: adminOnboardingKey)
            checkShowCongrats()
        }
        .onChange(of: store.userId) { newUserId in
            adminOnboardingComplete = UserDefaults.standard.bool(forKey: adminOnboardingKey)
        }
        .alert(isPresented: $showNoKidAlert) {
            Alert(
                title: Text(NSLocalizedString("admin_no_kid_title", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                message: Text(NSLocalizedString("admin_no_kid_message", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                dismissButton: .default(Text(NSLocalizedString("ok", tableName: nil, bundle: Bundle.main, value: "", comment: "")))
            )
        }
    }
    private func checkShowCongrats() {
        // Only check for onboarding completion if it hasn't already been completed
        if adminOnboardingComplete { return }
        let hasAll = !filteredRules.isEmpty && !filteredChores.isEmpty && !filteredRewards.isEmpty
        print("[AdminViewiPhone] checkShowCongrats: hasAll=\(hasAll), adminOnboardingComplete=\(adminOnboardingComplete), showCongratsModal=\(showCongratsModal)")
        if hasAll && !showCongratsModal {
            showCongratsModal = true
        }
    }
}

// =======================
// iPad layout
// =======================
struct AdminViewiPad: View {
    @EnvironmentObject var store: TipjeStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var adminOnboardingComplete: Bool = false
    var adminOnboardingKey: String { "adminOnboardingComplete_\(store.userId)" }
    @State private var selectedTab: AdminTab = .rules
    @State private var showCatalogueModal = false
    @State private var showCongratsModal = false
    @State private var showNoKidAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRuleId: String? = nil
    @State private var expandedChoreId: String? = nil
    @State private var expandedRewardId: String? = nil
    let bannerHeight: CGFloat = 300
    let cornerRadius: CGFloat = 24
    var onComplete: (() -> Void)? = nil
    // Computed properties for filtering
    var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var filteredRewards: [Reward] { store.rewards.filter { $0.isActive } }
    var activeRuleIDs: [String] { filteredRules.map { $0.id } }
    var activeChoreIDs: [String] { filteredChores.map { $0.id } }
    var activeRewardIDs: [String] { filteredRewards.map { $0.id } }
    // Extracted banner view
    var adminBanner: some View {
        ZStack {
            Image("il_admin")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: bannerHeight * 1.1, alignment: .center)
                .clipped()
        }
        .frame(height: bannerHeight)
    }
    // Header view
    var headerView: some View {
        VStack(spacing: 4) {
            PageTitle(NSLocalizedString("admin_title", tableName: nil, bundle: Bundle.main, value: "", comment: "")) {
                IconRoundButton(iconName: "icon_plus") {
                    showCatalogueModal = true
                }
                .accessibilityIdentifier("addRuleButton")
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)
            SubTabBar(
                tabs: AdminTab.allCases,
                selectedTab: $selectedTab,
                title: { tab in
                    switch tab {
                    case .rules: return NSLocalizedString("admin_tab_rules", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    case .chores: return NSLocalizedString("admin_tab_chores", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    case .shop: return NSLocalizedString("admin_tab_shop", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                }
            )
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
        }
    }
    // Row subviews
    private struct RuleRow: View {
        let rule: Rule
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedRuleId: String?
        
        // Create localized rule with catalog title
        private var localizedRule: Rule {
            var localized = rule
            if let catalogRule = getLocalizedRulesCatalog().first(where: { $0.id == rule.id }) {
                localized.title = catalogRule.title
            }
            return localized
        }
        
        var body: some View {
            RuleAdultCard(
                rule: localizedRule, // Use localized rule instead of original
                onArchive: {
                    if rule.isActive {
                        store.archiveRule(rule)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addRule(rule)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: (getLocalizedRulesCatalog() + store.customRules).first { $0.id == rule.id }?.color ?? Color(.systemGray5),
                onTap: {
                    if expandedRuleId == rule.id {
                        expandedRuleId = nil
                    } else {
                        expandedRuleId = rule.id
                    }
                },
                expanded: expandedRuleId == rule.id
            )
        }
    }
    private struct ChoreRow: View {
        let chore: Chore
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedChoreId: String?
        
        // Create localized chore with catalog title
        private var localizedChore: Chore {
            var localized = chore
            if let catalogChore = getLocalizedChoresCatalog().first(where: { $0.id == chore.id }) {
                localized.title = catalogChore.title
            }
            return localized
        }
        
        var body: some View {
            ChoreAdultCard(
                chore: localizedChore, // Use localized chore instead of original
                onArchive: {
                    if chore.isActive {
                        store.archiveChore(chore)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addChore(chore)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: (getLocalizedChoresCatalog() + store.customChores).first { $0.id == chore.id }?.color ?? Color(.systemGray5),
                onTap: {
                    if expandedChoreId == chore.id {
                        expandedChoreId = nil
                    } else {
                        expandedChoreId = chore.id
                    }
                },
                expanded: expandedChoreId == chore.id
            )
        }
    }
    private struct RewardRow: View {
        let reward: Reward
        @EnvironmentObject var store: TipjeStore
        @Binding var showToast: Bool
        @Binding var toastMessage: String
        @Binding var toastIcon: String?
        @Binding var toastIconColor: Color
        @Binding var expandedRewardId: String?
        
        // Create localized reward with catalog title
        private var localizedReward: Reward {
            var localized = reward
            if let catalogReward = getLocalizedRewardsCatalog().first(where: { $0.id == reward.id }) {
                localized.title = catalogReward.title
            }
            return localized
        }
        
        var body: some View {
            RewardAdultCard(
                reward: localizedReward, // Use localized reward instead of original
                onArchive: {
                    if reward.isActive {
                        store.archiveReward(reward)
                        toastMessage = NSLocalizedString("toast_removed_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                        toastIcon = "trash.fill"
                        toastIconColor = Color(hex: "#BBB595")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        store.addReward(reward)
                        toastMessage = NSLocalizedString("toast_added_hub", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                    }
                },
                selected: true,
                baseColor: (getLocalizedRewardsCatalog() + store.customRewards).first { $0.id == reward.id }?.color ?? Color(.systemGray5),
                onTap: {
                    if expandedRewardId == reward.id {
                        expandedRewardId = nil
                    } else {
                        expandedRewardId = reward.id
                    }
                },
                expanded: expandedRewardId == reward.id
            )
        }
    }
    // List subviews
    private var rulesList: some View {
        Group {
            if filteredRules.isEmpty {
                VStack(spacing: 0) {
                    TipjeEmptyState(
                        imageName: "mascot_ticket",
                        subtitle: NSLocalizedString("empty_admin_rules", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                        imageHeight: 400,
                        topPadding: 0
                    )
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 14) {
                        ForEach(filteredRules) { RuleRow(rule: $0, showToast: $showToast, toastMessage: $toastMessage, toastIcon: $toastIcon, toastIconColor: $toastIconColor, expandedRuleId: $expandedRuleId).environmentObject(store) }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    private var choresList: some View {
        Group {
            if filteredChores.isEmpty {
                VStack(spacing: 0) {
                    TipjeEmptyState(
                        imageName: "mascot_ticket",
                        subtitle: NSLocalizedString("empty_admin_chores", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                        imageHeight: 400,
                        topPadding: 0
                    )
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 14) {
                        ForEach(filteredChores) { ChoreRow(chore: $0, showToast: $showToast, toastMessage: $toastMessage, toastIcon: $toastIcon, toastIconColor: $toastIconColor, expandedChoreId: $expandedChoreId).environmentObject(store) }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    private var rewardsList: some View {
        Group {
            if filteredRewards.isEmpty {
                VStack(spacing: 0) {
                    TipjeEmptyState(
                        imageName: "mascot_ticket",
                        subtitle: NSLocalizedString("empty_admin_rewards", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                        imageHeight: 400,
                        topPadding: 0
                    )
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 14) {
                        ForEach(filteredRewards) { RewardRow(reward: $0, showToast: $showToast, toastMessage: $toastMessage, toastIcon: $toastIcon, toastIconColor: $toastIconColor, expandedRewardId: $expandedRewardId).environmentObject(store) }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    // Extracted main content view
    var adminContent: some View {
        VStack(spacing: 0) {
            headerView
            Group {
                switch selectedTab {
                case .rules:   rulesList
                case .chores:  choresList
                case .shop:    rewardsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.container, edges: .horizontal)
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
    // Modal switch as a @ViewBuilder
    @ViewBuilder
    private func catalogModal() -> some View {
        switch selectedTab {
        case .rules:
            CatalogRulesModal(
                onSave: { ids, custom in handleRulesSave(ids, customRules: custom) },
                initiallySelected: activeRuleIDs
            )
            .environmentObject(LocalizationManager.shared)
        case .chores:
            CatalogChoresModal(
                onSave: { ids, custom in handleChoresSave(ids, customChores: custom) },
                initiallySelected: activeChoreIDs
            )
            .environmentObject(LocalizationManager.shared)
            .accessibilityIdentifier("choresCatalogModal")
        case .shop:
            CatalogRewardsModal(
                onSave: handleRewardsSave(_:customRewards:),
                initiallySelected: activeRewardIDs
            )
            .environmentObject(LocalizationManager.shared)
            .accessibilityIdentifier("rewardsCatalogModal")
        }
    }
    // Save handlers
    private func handleRulesSave(_ selectedIds: [String], customRules: [CatalogRule]) {
        guard let kid = store.selectedKid else { showNoKidAlert = true; return }
        // Archive rules that are active and in the catalog but not selected
        for rule in store.rules.filter({ $0.isActive && (getLocalizedRulesCatalog().map { $0.id } + customRules.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(rule.id) {
                store.archiveRule(rule)
            }
        }
        // Add or reactivate selected rules from the catalog or custom
        let allCatalogRules = getLocalizedRulesCatalog() + customRules
        for id in selectedIds {
            if let rule = store.rules.first(where: { $0.id == id }) {
                if !rule.isActive {
                    if let cat = allCatalogRules.first(where: { $0.id == id }) {
                        var reactivated = rule
                        reactivated.title = cat.title
                        reactivated.peanutValue = cat.peanuts
                        reactivated.isActive = true
                        print("[DEBUG] Reactivating rule: \(reactivated)")
                        store.addRule(reactivated)
                        // Also write to Firestore under kid's rules collection
                        FirestoreManager.shared.addRule(userId: store.userId, kidId: kid.id, rule: reactivated) { _ in }
                    }
                }
            } else if let cat = allCatalogRules.first(where: { $0.id == id }) {
                // This will catch both curated and custom rules
                let newRule = Rule(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                print("[DEBUG] Adding new rule: \(newRule)")
                store.addRule(newRule)
                // Also write to Firestore under kid's rules collection
                FirestoreManager.shared.addRule(userId: store.userId, kidId: kid.id, rule: newRule) { _ in }
            } else {
                print("[DEBUG] Could not find CatalogRule for id: \(id)")
            }
        }
        // Ensure Admin always reflects the latest custom rules
        store.customRules = customRules
        showCatalogueModal = false
    }
    private func handleChoresSave(_ selectedIds: [String], customChores: [CatalogChore]) {
        guard store.selectedKid != nil else { showNoKidAlert = true; return }
        // Archive chores that are active and in the catalog (curated or custom) but not selected
        for chore in store.chores.filter({ $0.isActive && (getLocalizedChoresCatalog().map { $0.id } + customChores.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(chore.id) {
                store.archiveChore(chore)
            }
        }
        // Add or reactivate selected chores from the catalog or custom
        let allCatalogChores = getLocalizedChoresCatalog() + customChores
        for id in selectedIds {
            if let chore = store.chores.first(where: { $0.id == id }) {
                if !chore.isActive {
                    if let cat = allCatalogChores.first(where: { $0.id == id }) {
                        var reactivated = chore
                        reactivated.title = cat.title
                        reactivated.peanutValue = cat.peanuts
                        reactivated.isActive = true
                        store.addChore(reactivated)
                    }
                }
            } else if let cat = allCatalogChores.first(where: { $0.id == id }) {
                let newChore = Chore(id: cat.id, title: cat.title, peanutValue: cat.peanuts, isActive: true)
                store.addChore(newChore)
            }
        }
        // Ensure Admin always reflects the latest custom chores
        store.customChores = customChores
        showCatalogueModal = false
    }
    private func handleRewardsSave(_ selectedIds: [String], customRewards: [CatalogReward]) {
        guard let kid = store.selectedKid else { showNoKidAlert = true; return }
        // Archive rewards that are active and in the catalog (curated or custom) but not selected
        for reward in store.rewards.filter({ $0.isActive && (getLocalizedRewardsCatalog().map { $0.id } + customRewards.map { $0.id }).contains($0.id) }) {
            if !selectedIds.contains(reward.id) {
                store.archiveReward(reward)
            }
        }
        // Add or reactivate selected rewards from the catalog or custom
        let allCatalogRewards = getLocalizedRewardsCatalog() + customRewards
        for id in selectedIds {
            if let reward = store.rewards.first(where: { $0.id == id }) {
                if !reward.isActive {
                    if let cat = allCatalogRewards.first(where: { $0.id == id }) {
                        var reactivated = reward
                        reactivated.title = cat.title
                        reactivated.cost = cat.peanuts
                        reactivated.isActive = true
                        store.addReward(reactivated)
                        // Also write to Firestore under kid's rewards collection
                        FirestoreManager.shared.addReward(userId: store.userId, kidId: kid.id, reward: reactivated) { _ in }
                    }
                }
            } else if let cat = allCatalogRewards.first(where: { $0.id == id }) {
                let newReward = Reward(id: cat.id, title: cat.title, cost: cat.peanuts, isActive: true)
                store.addReward(newReward)
                // Also write to Firestore under kid's rewards collection
                FirestoreManager.shared.addReward(userId: store.userId, kidId: kid.id, reward: newReward) { _ in }
            }
        }
        // Ensure Admin always reflects the latest custom rewards
        store.customRewards = customRewards
        showCatalogueModal = false;
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: bannerHeight,
            bannerContent: { adminBanner },
            content: { adminContent }
        )
        .id(localizationManager.currentLanguage)
        .fullScreenCover(isPresented: $showCatalogueModal) {
            catalogModal()
                .environmentObject(store)
        }
        .sheet(isPresented: $showCongratsModal) {
            TipjeModal(
                imageName: "on_4",
                message: NSLocalizedString("admin_all_set_modal", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                onClose: {
                    showCongratsModal = false
                    adminOnboardingComplete = true
                    UserDefaults.standard.set(true, forKey: adminOnboardingKey)
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
        .onAppear {
            print("[AdminViewiPad] Appeared. UserId: \(store.userId), Kids: \(store.kids.map { $0.name })")
            adminOnboardingComplete = UserDefaults.standard.bool(forKey: adminOnboardingKey)
            checkShowCongrats()
        }
        .onChange(of: store.userId) { newUserId in
            adminOnboardingComplete = UserDefaults.standard.bool(forKey: adminOnboardingKey)
        }
        .alert(isPresented: $showNoKidAlert) {
            Alert(
                title: Text(NSLocalizedString("admin_no_kid_title", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                message: Text(NSLocalizedString("admin_no_kid_message", tableName: nil, bundle: Bundle.main, value: "", comment: "")),
                dismissButton: .default(Text(NSLocalizedString("ok", tableName: nil, bundle: Bundle.main, value: "", comment: "")))
            )
        }
    }
    private func checkShowCongrats() {
        if adminOnboardingComplete { return }
        let hasAll = !filteredRules.isEmpty && !filteredChores.isEmpty && !filteredRewards.isEmpty
        print("[AdminViewiPad] checkShowCongrats: hasAll=\(hasAll), adminOnboardingComplete=\(adminOnboardingComplete), showCongratsModal=\(showCongratsModal)")
        if hasAll && !showCongratsModal {
            showCongratsModal = true
        }
    }
}

struct EmptyAdminState: View {
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
        AdminView()
            .environmentObject(TipjeStore())
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
