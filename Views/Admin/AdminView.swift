import SwiftUI

enum AdminTab: String, CaseIterable, Identifiable {
    case rules = "Rules"
    case chores = "Chores"
    case shop = "Shop"
    var id: String { rawValue }
}

struct AdminView: View {
    @EnvironmentObject var store: Store
    @State private var selectedTab: AdminTab = .rules
    @State private var showCatalogueModal = false
    @State private var selectedTemplates: Set<String> = []
    
    private var filteredTasks: [Task] {
        switch selectedTab {
        case .rules:
            return store.tasks.filter { $0.kind == .rule && $0.isSelected }
        case .chores:
            return store.tasks.filter { $0.kind == .chore && $0.isSelected }
        case .shop:
            return store.tasks.filter { $0.kind == .reward && $0.isSelected }
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            PageTitle("Your mindful home") {
                if !filteredTasks.isEmpty {
                    IconRoundButton(iconName: "icon_plus") {
                        syncSelectedTemplates()
                        showCatalogueModal = true
                    }
                }
            }
            // Local SegmentedControl
            SubTabBar(
                tabs: AdminTab.allCases,
                selectedTab: $selectedTab,
                title: { $0.rawValue }
            )
            .padding(.vertical, 8)
            // List or Empty State
            if filteredTasks.isEmpty {
                GeometryReader { geometry in
                    let mascotHeight = min(geometry.size.height * 0.45, 500)
                    VStack(spacing: 24) {
                        Image(selectedTab == .rules ? "mascot_empty" : selectedTab == .chores ? "mascot_ticket" : "mascot_reward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: mascotHeight)
                        Text(emptyStateText)
                            .font(.custom("Inter-Medium", size: 24))
                            .foregroundColor(Color(hex: "#8E9293"))
                        Button(action: {
                            syncSelectedTemplates()
                            showCatalogueModal = true
                        }) {
                            Text("Add New")
                                .font(.custom("Inter-Medium", size: 24))
                                .foregroundColor(Color(hex: "#799B44"))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(Color(hex: "#EAF3EA"))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(filteredTasks) { task in
                            switch selectedTab {
                            case .rules:
                                RuleAdultCard(task: task)
                            case .chores:
                                ChoreAdultCard(task: task)
                            case .shop:
                                RewardAdultCard(task: task)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
        .fullScreenCover(isPresented: $showCatalogueModal) {
            CatalogueModal(kind: currentKind, selectedTemplates: $selectedTemplates) {
                showCatalogueModal = false
            }
            .environmentObject(store)
        }
        .onAppear(perform: syncSelectedTemplates)
        .onChange(of: selectedTab) { _ in syncSelectedTemplates() }
    }
    private var emptyStateText: String {
        switch selectedTab {
        case .rules: return "You don't have family rules yet"
        case .chores: return "You don't have chores yet"
        case .shop: return "You don't have rewards yet"
        }
    }
    private var currentKind: TaskKind {
        switch selectedTab {
        case .rules: return .rule
        case .chores: return .chore
        case .shop: return .reward
        }
    }
    private func syncSelectedTemplates() {
        let kind = currentKind
        selectedTemplates = Set(store.tasks.filter { $0.kind == kind && $0.isSelected }.compactMap { $0.templateID })
    }
}

#if DEBUG
struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView().environmentObject(Store())
    }
}
#endif 