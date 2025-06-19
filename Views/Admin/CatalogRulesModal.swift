import SwiftUI
// Import the shared catalog models
// If needed, use: import Models

struct RuleCatalogItem: Identifiable, Equatable {
    let id: String
    let title: String
    let peanuts: Int
    let category: Category
}

struct CatalogRulesModal: View {
    var onSave: ([String]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selected: Set<String>
    let catalog = rulesCatalog
    init(onSave: @escaping ([String]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A2AFC1"),
            bannerHeight: 100,
            containerOffsetY: -36,
            content: {
                VStack(spacing: 0) {
                    // Fixed header
                    PageTitle("Select Rules") {
                        ButtonRegular(iconName: "icon_close", variant: .light) {
                            saveAndClose()
                        }
                        .accessibilityIdentifier("saveRulesButton")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                    // Scrollable list
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(catalog, id: \ .id) { item in
                                RuleAdultCard(
                                    rule: Rule(id: item.id, title: item.title, peanutValue: item.peanuts, isActive: true),
                                    selected: selected.contains(item.id),
                                    baseColor: item.color,
                                    onTap: {
                                        if selected.contains(item.id) {
                                            selected.remove(item.id)
                                        } else {
                                            selected.insert(item.id)
                                        }
                                    }
                                )
                                .accessibilityIdentifier("ruleCell_\(item.id)")
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                        .padding(.top, horizontalSizeClass == .compact ? 0 : 8)
                        .padding(.bottom, horizontalSizeClass == .compact ? 0 : 24)
                    }
                }
            }
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
    private func saveAndClose() {
        onSave(Array(selected))
        dismiss()
    }
} 
