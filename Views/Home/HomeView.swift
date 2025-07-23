import SwiftUI

let rulesCatalogIds = getLocalizedRulesCatalog().map { $0.id }
let choresCatalogIds = getLocalizedChoresCatalog().map { $0.id }

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct HomeView: View {
    @EnvironmentObject var store: TipjeStore
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { 
        let formatter = DateFormatter()
        let languageCode = LocalizationManager.shared.currentLanguage
        formatter.locale = Locale(identifier: languageCode)
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
    }
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                HomeViewiPhone().environmentObject(store)
            } else {
                HomeViewiPad().environmentObject(store)
            }
        }
        .id(localizationManager.currentLanguage)
    }
}

// =======================
// iPhone layout
// =======================
struct HomeViewiPhone: View {
    @EnvironmentObject var store: TipjeStore
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedTab: TaskKind = .rule
    @State private var showUsedModal: Bool = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRuleIds: Set<String> = []
    @State private var expandedChoreIds: Set<String> = []
    private var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    private var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { 
        let formatter = DateFormatter()
        let languageCode = LocalizationManager.shared.currentLanguage
        formatter.locale = Locale(identifier: languageCode)
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
    }
    @ViewBuilder
    private func rulesList() -> some View {
        ForEach(activeRules, id: \.id) { rule in
            ruleCard(for: rule)
        }
    }
    
    private var activeRules: [Rule] {
        store.rules.filter { $0.isActive }
    }
    
    @ViewBuilder
    private func ruleCard(for rule: Rule) -> some View {
        let catalogRule = (getLocalizedRulesCatalog() + store.customRules).first(where: { $0.id == rule.id })
        let cardColor = catalogRule?.color ?? Color(.systemGray5)
        let title = catalogRule?.title ?? rule.title
        let peanuts = catalogRule?.peanuts ?? rule.peanutValue
        let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
        let isExpanded = expandedRuleIds.contains(rule.id)
        
        RuleKidCard(
            rule: Rule(id: rule.id, title: title, peanutValue: peanuts, isActive: rule.isActive, completions: rule.completions),
            isCompleted: completedToday,
            cardColor: cardColor,
            onTap: {
                handleRuleTap(rule: rule, completedToday: completedToday, peanuts: peanuts)
            },
            expanded: isExpanded,
            onExpand: {
                handleRuleExpand(ruleId: rule.id)
            }
        )
    }
    
    private func handleRuleTap(rule: Rule, completedToday: Bool, peanuts: Int) {
        if !completedToday {
            store.completeRule(rule)
            toastMessage = NSLocalizedString("toast_task_completed", tableName: nil, bundle: Bundle.main, value: "", comment: "")
            toastIcon = "checkmark.circle.fill"
            toastIconColor = Color(hex: "#799B44")
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
        } else {
            if store.balance < peanuts {
                showUsedModal = true
            } else {
                store.uncompleteRule(rule)
                toastMessage = NSLocalizedString("toast_task_undone", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                toastIcon = "xmark.circle.fill"
                toastIconColor = Color(hex: "#DC5754")
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
            }
        }
    }
    
    private func handleRuleExpand(ruleId: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedRuleIds.contains(ruleId) {
                expandedRuleIds.remove(ruleId)
            } else {
                expandedRuleIds.insert(ruleId)
            }
        }
    }
    
    @ViewBuilder
    private func choresList() -> some View {
        ForEach(activeChores, id: \.id) { chore in
            choreCard(for: chore)
        }
    }
    
    private var activeChores: [Chore] {
        store.chores.filter { $0.isActive }
    }
    
    @ViewBuilder
    private func choreCard(for chore: Chore) -> some View {
        let catalogChore = (getLocalizedChoresCatalog() + store.customChores).first(where: { $0.id == chore.id })
        let cardColor = catalogChore?.color ?? Color(.systemGray5)
        let title = catalogChore?.title ?? chore.title
        let peanuts = catalogChore?.peanuts ?? chore.peanutValue
        let completedToday = chore.completions.contains { Calendar.current.isDateInToday($0) }
        let isExpanded = expandedChoreIds.contains(chore.id)
        
        ChoreKidCard(
            chore: Chore(id: chore.id, title: title, peanutValue: peanuts, isActive: chore.isActive, completions: chore.completions),
            isCompleted: completedToday,
            cardColor: cardColor,
            onTap: {
                handleChoreTap(chore: chore, completedToday: completedToday, peanuts: peanuts)
            },
            expanded: isExpanded,
            onExpand: {
                handleChoreExpand(choreId: chore.id)
            }
        )
    }
    
    private func handleChoreTap(chore: Chore, completedToday: Bool, peanuts: Int) {
        if !completedToday {
            store.completeChore(chore)
            toastMessage = NSLocalizedString("toast_task_completed", tableName: nil, bundle: Bundle.main, value: "", comment: "")
            toastIcon = "checkmark.circle.fill"
            toastIconColor = Color(hex: "#799B44")
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
        } else {
            if store.balance < peanuts {
                showUsedModal = true
            } else {
                store.uncompleteChore(chore)
                toastMessage = NSLocalizedString("toast_task_undone", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                toastIcon = "xmark.circle.fill"
                toastIconColor = Color(hex: "#DC5754")
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
            }
        }
    }
    
    private func handleChoreExpand(choreId: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedChoreIds.contains(choreId) {
                expandedChoreIds.remove(choreId)
            } else {
                expandedChoreIds.insert(choreId)
            }
        }
    }
    @ViewBuilder
    private func mainContent() -> some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A9C6C0"),
            bannerHeight: 300,
            bannerContent: {
                ZStack {
                    Image("il_home_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .offset(y: -10)
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(store.balance)")
                            .font(.custom("Inter", size: 64).weight(.bold))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Text(NSLocalizedString("home_peanuts_earned", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter", size: 18).weight(.medium))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(.top, -12)
                        Spacer()
                    }
                    .padding(.top, 36)
                }
                .frame(height: 300)
            },
            content: {
                VStack(spacing: 16) {
                    PageTitle(String(format: NSLocalizedString("home_title_mindful_weekday", tableName: nil, bundle: Bundle.main, value: "", comment: ""), kidName, weekday))
                        .padding(.top, 14)
                    SubTabBar(
                        tabs: [TaskKind.rule, TaskKind.chore],
                        selectedTab: $selectedTab,
                        title: { $0 == .rule ? NSLocalizedString("home_tab_rules", tableName: nil, bundle: Bundle.main, value: "", comment: "") : NSLocalizedString("home_tab_chores", tableName: nil, bundle: Bundle.main, value: "", comment: "") }
                    )
                    if selectedTab == .rule {
                        if activeRules.isEmpty {
                            TipjeEmptyStateiPhone(
                                imageName: "mascot_ticket",
                                subtitle: NSLocalizedString("empty_home_tasks", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                                imageHeight: 300
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    rulesList()
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    } else {
                        if filteredChores.isEmpty {
                            TipjeEmptyStateiPhone(
                                imageName: "mascot_ticket",
                                subtitle: NSLocalizedString("empty_home_tasks", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                                imageHeight: 300
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    choresList()
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    }
                }
                .font(.custom("Inter-Regular-Medium", size: 24))
                .ignoresSafeArea(.container, edges: .horizontal)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showUsedModal) {
            TipjeModal(
                imageName: "il_used",
                message: NSLocalizedString("modal_task_done_today", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                onClose: { showUsedModal = false }
            )
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
        .onAppear {
            print("[HomeViewiPhone] Appeared. UserId: \(store.userId), Balance: \(store.balance), Kids: \(store.kids.map { $0.name })")
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    var body: some View {
        mainContent()
    }
}

// =======================
// iPad layout
// =======================
struct HomeViewiPad: View {
    @EnvironmentObject var store: TipjeStore
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: TaskKind = .rule
    @State private var showUsedModal: Bool = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    @State private var expandedRuleIds: Set<String> = []
    @State private var expandedChoreIds: Set<String> = []
    private var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    private var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { 
        let formatter = DateFormatter()
        let languageCode = LocalizationManager.shared.currentLanguage
        formatter.locale = Locale(identifier: languageCode)
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
    }
    @ViewBuilder
    private func rulesListPad() -> some View {
        ForEach(activeRules, id: \.id) { rule in
            ruleCardPad(for: rule)
        }
    }
    
    @ViewBuilder
    private func ruleCardPad(for rule: Rule) -> some View {
        let catalogRule = (getLocalizedRulesCatalog() + store.customRules).first(where: { $0.id == rule.id })
        let cardColor = catalogRule?.color ?? Color(.systemGray5)
        let title = catalogRule?.title ?? rule.title
        let peanuts = catalogRule?.peanuts ?? rule.peanutValue
        let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
        let isExpanded = expandedRuleIds.contains(rule.id)
        
        RuleKidCard(
            rule: Rule(id: rule.id, title: title, peanutValue: peanuts, isActive: rule.isActive, completions: rule.completions),
            isCompleted: completedToday,
            cardColor: cardColor,
            onTap: {
                handleRuleTapPad(rule: rule, completedToday: completedToday, peanuts: peanuts)
            },
            expanded: isExpanded,
            onExpand: {
                handleRuleExpandPad(ruleId: rule.id)
            }
        )
    }
    
    private func handleRuleTapPad(rule: Rule, completedToday: Bool, peanuts: Int) {
        if !completedToday {
            store.completeRule(rule)
            toastMessage = NSLocalizedString("toast_task_completed", tableName: nil, bundle: Bundle.main, value: "", comment: "")
            toastIcon = "checkmark.circle.fill"
            toastIconColor = Color(hex: "#799B44")
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
        } else {
            if store.balance < peanuts {
                showUsedModal = true
            } else {
                store.uncompleteRule(rule)
                toastMessage = NSLocalizedString("toast_task_undone", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                toastIcon = "xmark.circle.fill"
                toastIconColor = Color(hex: "#DC5754")
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
            }
        }
    }
    
    private func handleRuleExpandPad(ruleId: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedRuleIds.contains(ruleId) {
                expandedRuleIds.remove(ruleId)
            } else {
                expandedRuleIds.insert(ruleId)
            }
        }
    }
    
    @ViewBuilder
    private func choresListPad() -> some View {
        ForEach(activeChores, id: \.id) { chore in
            choreCardPad(for: chore)
        }
    }
    
    @ViewBuilder
    private func choreCardPad(for chore: Chore) -> some View {
        let catalogChore = (getLocalizedChoresCatalog() + store.customChores).first(where: { $0.id == chore.id })
        let cardColor = catalogChore?.color ?? Color(.systemGray5)
        let title = catalogChore?.title ?? chore.title
        let peanuts = catalogChore?.peanuts ?? chore.peanutValue
        let completedToday = chore.completions.contains { Calendar.current.isDateInToday($0) }
        let isExpanded = expandedChoreIds.contains(chore.id)
        
        ChoreKidCard(
            chore: Chore(id: chore.id, title: title, peanutValue: peanuts, isActive: chore.isActive, completions: chore.completions),
            isCompleted: completedToday,
            cardColor: cardColor,
            onTap: {
                handleChoreTapPad(chore: chore, completedToday: completedToday, peanuts: peanuts)
            },
            expanded: isExpanded,
            onExpand: {
                handleChoreExpandPad(choreId: chore.id)
            }
        )
    }
    
    private func handleChoreTapPad(chore: Chore, completedToday: Bool, peanuts: Int) {
        if !completedToday {
            store.completeChore(chore)
            toastMessage = NSLocalizedString("toast_task_completed", tableName: nil, bundle: Bundle.main, value: "", comment: "")
            toastIcon = "checkmark.circle.fill"
            toastIconColor = Color(hex: "#799B44")
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
        } else {
            if store.balance < peanuts {
                showUsedModal = true
            } else {
                store.uncompleteChore(chore)
                toastMessage = NSLocalizedString("toast_task_undone", tableName: nil, bundle: Bundle.main, value: "", comment: "")
                toastIcon = "xmark.circle.fill"
                toastIconColor = Color(hex: "#DC5754")
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
            }
        }
    }
    
    private func handleChoreExpandPad(choreId: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedChoreIds.contains(choreId) {
                expandedChoreIds.remove(choreId)
            } else {
                expandedChoreIds.insert(choreId)
            }
        }
    }
    @ViewBuilder
    private func mainContent() -> some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A9C6C0"),
            bannerHeight: 300,
            bannerContent: {
                ZStack {
                    Image("il_home_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .offset(y: 0)
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(store.balance)")
                            .font(.custom("Inter", size: 84).weight(.bold))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            Text(NSLocalizedString("home_peanuts_earned", tableName: nil, bundle: Bundle.main, value: "", comment: ""))
                                .font(.custom("Inter", size: 24).weight(.medium))
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
                    PageTitle(String(format: NSLocalizedString("home_title_mindful_weekday", tableName: nil, bundle: Bundle.main, value: "", comment: ""), kidName, weekday))
                        .padding(.top, 24)
                    SubTabBar(
                        tabs: [TaskKind.rule, TaskKind.chore],
                        selectedTab: $selectedTab,
                        title: { $0 == .rule ? NSLocalizedString("home_tab_rules", tableName: nil, bundle: Bundle.main, value: "", comment: "") : NSLocalizedString("home_tab_chores", tableName: nil, bundle: Bundle.main, value: "", comment: "") }
                    )
                    if selectedTab == .rule {
                        if activeRules.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_ticket",
                                subtitle: NSLocalizedString("empty_home_tasks", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                                imageHeight: 400,
                                topPadding: 0
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    rulesListPad()
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    } else {
                        if activeChores.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_ticket",
                                subtitle: NSLocalizedString("empty_home_tasks", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                                imageHeight: 400,
                                topPadding: 0
                            )
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    choresListPad()
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 80)
                            }
                        }
                    }
                }
                .font(.custom("Inter-Medium", size: 24))
                .padding(.horizontal, 24)
                .ignoresSafeArea(.container, edges: .horizontal)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showUsedModal) {
            TipjeModal(
                imageName: "il_used",
                message: NSLocalizedString("modal_task_done_today", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
                onClose: { showUsedModal = false }
            )
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
        .onAppear {
            print("[HomeViewiPad] Appeared. UserId: \(store.userId), Balance: \(store.balance), Kids: \(store.kids.map { $0.name })")
        }
    }
    private var activeRules: [Rule] { filteredRules }
    private var activeChores: [Chore] { filteredChores }
    var body: some View {
        mainContent()
    }
}

struct EmptyHomeState: View {
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(TipjeStore())
    }
}
#endif 
