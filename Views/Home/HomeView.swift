import SwiftUI

let rulesCatalogIds = rulesCatalog.map { $0.id }
let choresCatalogIds = choresCatalog.map { $0.id }

struct HomeView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: TaskKind = .rule // .rule or .chore

    private var filteredRules: [Rule] {
        store.rules.filter { $0.isActive }
    }
    private var filteredChores: [Chore] {
        store.chores.filter { $0.isActive }
    }

    private func debugPrints() {
        print("Current balance: \(store.balance)")
        for rule in store.rules.filter({ $0.isActive && rulesCatalogIds.contains($0.id) }) {
            let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
            print("Rule \(rule.title) completions: \(rule.completions), completedToday: \(completedToday)")
        }
    }

    var body: some View {
        let kidName = store.selectedKid?.name ?? ""
        let weekday = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
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
                    PageTitle("\(kidName)'s \(weekday)")
                        .padding(.top, 24)
                    SubTabBar(
                        tabs: [TaskKind.rule, TaskKind.chore],
                        selectedTab: $selectedTab,
                        title: { $0 == .rule ? "Family Rules" : "Chores" }
                    )
                    if selectedTab == .rule {
                        if filteredRules.isEmpty {
                            EmptyHomeState(image: "mascot_empty", text: "You don't have family rules yet")
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(store.rules.filter { $0.isActive && rulesCatalogIds.contains($0.id) }) { rule in
                                        let completedToday = rule.completions.contains { Calendar.current.isDateInToday($0) }
                                        RuleKidCard(
                                            rule: rule,
                                            isCompleted: completedToday,
                                            onTap: {
                                                if !completedToday {
                                                    store.completeRule(rule)
                                                } else {
                                                    store.uncompleteRule(rule)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else {
                        if filteredChores.isEmpty {
                            EmptyHomeState(image: "mascot_ticket", text: "You don't have chores yet")
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(store.chores.filter { $0.isActive && choresCatalogIds.contains($0.id) }) { chore in
                                        let completedToday = chore.completions.contains { Calendar.current.isDateInToday($0) }
                                        ChoreKidCard(
                                            chore: chore,
                                            isCompleted: completedToday,
                                            onTap: {
                                                if !completedToday {
                                                    store.completeChore(chore)
                                                } else {
                                                    // Double-tap logic to mark as incomplete and update balance, but never negative
                                                    // Implement as needed
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .font(.custom("Inter-Medium", size: 24))
                .background(
                    RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        .fill(Color.white)
                )
            }
        )
        .onAppear {
            debugPrints()
        }
    }
}

struct EmptyHomeState: View {
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(Store())
    }
}
#endif 
