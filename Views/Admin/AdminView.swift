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
            // Header + Mascot
            HStack {
                Text("Your mindful home")
                    .font(.custom("Inter-Medium", size: 24))
                Spacer()
                Image("mascot_happy")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            .padding(.top, 14)
            // Local SegmentedControl
            Picker("Tab", selection: $selectedTab) {
                ForEach(AdminTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 8)
            // Add New Button
            Button(action: {
                showCatalogueModal = true
            }) {
                Text("Add New")
                    .font(.custom("Inter-Medium", size: 24))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.vertical, 8)
            // List or Empty State
            if filteredTasks.isEmpty {
                VStack(spacing: 14) {
                    Image(selectedTab == .rules ? "mascot_empty_rules" : selectedTab == .chores ? "mascot_empty_rules" : "mascot_empty_rules")
                        .resizable()
                        .frame(width: 120, height: 120)
                    Text(emptyStateText)
                        .font(.custom("Inter-Medium", size: 24))
                }
                .padding(.top, 32)
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
        selectedTemplates = Set(store.tasks.filter { $0.kind == kind && $0.isSelected }.map { $0.id.uuidString })
    }
}

#if DEBUG
struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView().environmentObject(Store())
    }
}
#endif 