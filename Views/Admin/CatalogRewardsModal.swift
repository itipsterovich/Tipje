import SwiftUI
// If needed, add: import Models

struct CatalogRewardsModal: View {
    var onSave: ([String]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Set<String> = []
    let catalog = rewardsCatalog
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A5ADC3"),
            bannerHeight: 100,
            content: {
                ScrollView {
                    VStack(spacing: 24) {
                        PageTitle("Add rewards") {
                            ButtonRegular(iconName: "icon_close", variant: .light) { dismiss() }
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        ForEach(catalog, id: \.id) { item in
                            RewardAdultCard(
                                reward: Reward(id: item.id, title: item.title, cost: item.peanuts, isActive: true),
                                selected: selected.contains(item.id),
                                baseColor: item.color
                            )
                            .onTapGesture {
                                if selected.contains(item.id) {
                                    selected.remove(item.id)
                                } else {
                                    selected.insert(item.id)
                                }
                            }
                        }
                        Button(action: { save() }) {
                            Text("Save")
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
                        .disabled(selected.isEmpty)
                    }
                    .padding(24)
                }
            }
        )
    }
    private func save() {
        onSave(Array(selected))
        dismiss()
    }
} 