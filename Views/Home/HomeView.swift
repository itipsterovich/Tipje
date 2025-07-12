import SwiftUI

let rulesCatalogIds = rulesCatalog.map { $0.id }
let choresCatalogIds = choresCatalog.map { $0.id }

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct HomeView: View {
    @EnvironmentObject var store: TipjeStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1] }
    var body: some View {
        if horizontalSizeClass == .compact {
            HomeViewiPhone().environmentObject(store)
        } else {
            HomeViewiPad().environmentObject(store)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct HomeViewiPhone: View {
    @EnvironmentObject var store: TipjeStore
    @State private var selectedTab: TaskKind = .rule
    @State private var showUsedModal: Bool = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    private var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    private var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1] }
    @ViewBuilder
    private func rulesList() -> some View {
        ForEach(Array(store.rules.filter { $0.isActive }.enumerated()), id: \.element.id) { index, rule in
            let catalogRule = (rulesCatalog + store.customRules).first(where: { $0.id == rule.id })
            let cardColor = catalogRule?.color ?? Color(.systemGray5)
            let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
            RuleKidCard(
                rule: rule,
                isCompleted: completedToday,
                cardColor: cardColor,
                onTap: {
                    if !completedToday {
                        store.completeRule(rule)
                        toastMessage = "Great job! Task completed"
                        toastIcon = "checkmark.circle.fill"
                        toastIconColor = Color(hex: "#799B44")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        if store.balance < rule.peanutValue {
                            showUsedModal = true
                        } else {
                            store.uncompleteRule(rule)
                            toastMessage = "Task marked as not done"
                            toastIcon = "xmark.circle.fill"
                            toastIconColor = Color(hex: "#DC5754")
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                        }
                    }
                }
            )
        }
    }
    @ViewBuilder
    private func choresList() -> some View {
        ForEach(Array(filteredChores.enumerated()), id: \.element.id) { index, chore in
            let catalogChore = (choresCatalog + store.customChores).first(where: { $0.id == chore.id })
            let cardColor = catalogChore?.color ?? Color(.systemGray5)
            let title = catalogChore?.title ?? chore.title
            let peanuts = catalogChore?.peanuts ?? chore.peanutValue
            let completedToday = chore.completions.contains { Calendar.current.isDateInToday($0) }
            ChoreKidCard(
                chore: Chore(id: chore.id, title: title, peanutValue: peanuts, isActive: chore.isActive, completions: chore.completions),
                isCompleted: completedToday,
                cardColor: cardColor,
                onTap: {
                    if !completedToday {
                        store.completeChore(chore)
                        toastMessage = "Great job! Task completed"
                        toastIcon = "checkmark.circle.fill"
                        toastIconColor = Color(hex: "#799B44")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        if store.balance < peanuts {
                            showUsedModal = true
                        } else {
                            store.uncompleteChore(chore)
                            toastMessage = "Task marked as not done"
                            toastIcon = "xmark.circle.fill"
                            toastIconColor = Color(hex: "#DC5754")
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                        }
                    }
                }
            )
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
                            .font(.custom("Inter", size: 64).weight(.bold))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                        HStack(alignment: .center, spacing: 4) {
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Text("peanuts earned")
                                .font(.custom("Inter", size: 22).weight(.medium))
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
                    PageTitle("\(kidName)'s Mindful \(weekday)")
                        .padding(.top, 14)
                    SubTabBar(
                        tabs: [TaskKind.rule, TaskKind.chore],
                        selectedTab: $selectedTab,
                        title: { $0 == .rule ? "Family Rules" : "Chores" }
                    )
                    if selectedTab == .rule {
                        if filteredRules.isEmpty {
                            TipjeEmptyStateiPhone(
                                imageName: "mascot_ticket",
                                subtitle: "Your tasks will show up here once a grown-up sets them.\nCheck back soon to start earning peanuts! 🥜",
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
                                subtitle: "Your tasks will show up here once a grown-up sets them.\nCheck back soon to start earning peanuts! 🥜",
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
                message: "You've done this today and got your peanuts!\nLet's make sure it's really done. 💪",
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: TaskKind = .rule
    @State private var showUsedModal: Bool = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = nil
    @State private var toastIconColor: Color = Color(hex: "#799B44")
    private var filteredRules: [Rule] { store.rules.filter { $0.isActive } }
    private var filteredChores: [Chore] { store.chores.filter { $0.isActive } }
    var kidName: String { store.selectedKid?.name ?? "" }
    var weekday: String { DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1] }
    @ViewBuilder
    private func rulesListPad() -> some View {
        ForEach(Array(filteredRules.enumerated()), id: \.element.id) { index, rule in
            let catalogRule = (rulesCatalog + store.customRules).first(where: { $0.id == rule.id })
            let cardColor = catalogRule?.color ?? Color(.systemGray5)
            let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
            RuleKidCard(
                rule: rule,
                isCompleted: completedToday,
                cardColor: cardColor,
                onTap: {
                    if !completedToday {
                        store.completeRule(rule)
                        toastMessage = "Great job! Task completed"
                        toastIcon = "checkmark.circle.fill"
                        toastIconColor = Color(hex: "#799B44")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        if store.balance < rule.peanutValue {
                            showUsedModal = true
                        } else {
                            store.uncompleteRule(rule)
                            toastMessage = "Task marked as not done"
                            toastIcon = "xmark.circle.fill"
                            toastIconColor = Color(hex: "#DC5754")
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                        }
                    }
                }
            )
        }
    }
    @ViewBuilder
    private func choresListPad() -> some View {
        ForEach(Array(filteredChores.enumerated()), id: \.element.id) { index, chore in
            let catalogChore = (choresCatalog + store.customChores).first(where: { $0.id == chore.id })
            let cardColor = catalogChore?.color ?? Color(.systemGray5)
            let title = catalogChore?.title ?? chore.title
            let peanuts = catalogChore?.peanuts ?? chore.peanutValue
            let completedToday = chore.completions.contains { Calendar.current.isDateInToday($0) }
            ChoreKidCard(
                chore: Chore(id: chore.id, title: title, peanutValue: peanuts, isActive: chore.isActive, completions: chore.completions),
                isCompleted: completedToday,
                cardColor: cardColor,
                onTap: {
                    if !completedToday {
                        store.completeChore(chore)
                        toastMessage = "Great job! Task completed"
                        toastIcon = "checkmark.circle.fill"
                        toastIconColor = Color(hex: "#799B44")
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                    } else {
                        if store.balance < peanuts {
                            showUsedModal = true
                        } else {
                            store.uncompleteChore(chore)
                            toastMessage = "Task marked as not done"
                            toastIcon = "xmark.circle.fill"
                            toastIconColor = Color(hex: "#DC5754")
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
                        }
                    }
                }
            )
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
                            Text("peanuts earned")
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
                    PageTitle("\(kidName)'s Mindful \(weekday)")
                        .padding(.top, 24)
                    SubTabBar(
                        tabs: [TaskKind.rule, TaskKind.chore],
                        selectedTab: $selectedTab,
                        title: { $0 == .rule ? "Family Rules" : "Chores" }
                    )
                    if selectedTab == .rule {
                        if filteredRules.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_ticket",
                                subtitle: "Your tasks will show up here once a grown-up sets them.\nCheck back soon to start earning peanuts! 🥜",
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
                        if filteredChores.isEmpty {
                            TipjeEmptyState(
                                imageName: "mascot_ticket",
                                subtitle: "Your tasks will show up here once a grown-up sets them.\nCheck back soon to start earning peanuts! 🥜",
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
                message: "You've done this today and got your peanuts!\nLet's make sure it's really done. 💪",
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
