import SwiftUI

struct CatalogChoresModal: View {
    var onSave: ([String]) -> Void
    var initiallySelected: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Set<String>
    let catalog = choresCatalog
    init(onSave: @escaping ([String]) -> Void, initiallySelected: [String]) {
        self.onSave = onSave
        self.initiallySelected = initiallySelected
        _selected = State(initialValue: Set(initiallySelected))
    }
    var body: some View {
        return BannerPanelLayout(
            bannerColor: Color(hex: "#C3BCA5"),
            bannerHeight: 100,
            content: {
                VStack(spacing: 0) {
                    // Fixed header
                    PageTitle("Select Chores") {
                        ButtonRegular(iconName: "icon_close", variant: .light) { save() }
                        .accessibilityIdentifier("saveChoresButton")
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 24)
                    // Scrollable list
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(catalog, id: \.id) { item in
                                ChoreAdultCard(
                                    chore: Chore(id: item.id, title: item.title, peanutValue: item.peanuts, isActive: true),
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
                                .accessibilityIdentifier("choreCell_\(item.id)")
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        )
    }
    private func save() {
        onSave(Array(selected))
        dismiss()
    }
} 