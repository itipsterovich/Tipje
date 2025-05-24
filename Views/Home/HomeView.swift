import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: TaskKind = .rule // .rule or .chore

    private var filteredTasks: [Task] {
        store.tasks.filter { $0.isSelected && $0.kind == selectedTab }
    }

    var body: some View {
        let kidName = store.kidName
        let weekday = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
        BannerPanelLayout(
            bannerColor: Color(hex: "#A9C6C0"),
            bannerHeight: 400,
            bannerContent: {
                VStack {
                    BalanceChip(balance: store.balance)
                        .padding(.top, 32)
                    Spacer()
                }
                .frame(height: 400)
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
                    if filteredTasks.isEmpty {
                        GeometryReader { geometry in
                            let mascotHeight = min(geometry.size.height * 0.45, 500)
                            VStack(spacing: 24) {
                                Image(selectedTab == .rule ? "mascot_empty" : "mascot_ticket")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: mascotHeight)
                                Text(selectedTab == .rule ? "You don't have family rules yet" : "You don't have chores yet")
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
                                ForEach(Array(filteredTasks.enumerated()), id: \ .element.id) { index, task in
                                    let color = colorForTemplateID(task.templateID)
                                    TaskCard(task: task, isAdult: false, onTap: {
                                        withAnimation(.spring()) {
                                            task.isCompleted.toggle()
                                        }
                                    }, backgroundColor: color)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .font(.custom("Inter-Medium", size: 24))
            }
        )
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(Store())
    }
}
#endif 