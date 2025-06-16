import SwiftUI
// If needed, add: import Models

struct CatalogRewardsModal: View {
    var onSave: ([String]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selected: Set<String>
    let catalog = rewardsCatalog
    init(onSave: @escaping ([String]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A5ADC3"),
            bannerHeight: 100,
            content: {
                VStack(spacing: 0) {
                    // Fixed header
                    PageTitle("Select Rewards") {
                        ButtonRegular(iconName: "icon_close", variant: .light) { save() }
                        .accessibilityIdentifier("saveRewardsButton")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .padding(.horizontal, horizontalSizeClass == .compact ? 4 : 24)
                    // Scrollable list
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(catalog, id: \.id) { item in
                                RewardAdultCard(
                                    reward: Reward(id: item.id, title: item.title, cost: item.peanuts, isActive: true),
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
                                .accessibilityIdentifier("rewardCell_\(item.id)")
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
    private func save() {
        onSave(Array(selected))
        dismiss()
    }
} 