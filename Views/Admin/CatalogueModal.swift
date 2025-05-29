import SwiftUI
import Foundation

struct TaskTemplate: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let peanuts: Int
    let category: Category
}

struct CatalogueCategory: Codable, Identifiable {
    let id: String
    let items: [TaskTemplate]
    var category: Category { Category(rawValue: id.lowercased()) ?? .fun }
}

struct CatalogueModal: View {
    let kind: TaskKind
    @Binding var selectedTemplates: Set<String>
    var onClose: () -> Void
    @State private var catalogue: [CatalogueCategory] = []
    @State private var loading = true
    @EnvironmentObject var store: Store
    
    private var modalTitle: String {
        switch kind {
        case .rule: return "Add Rules"
        case .chore: return "Add Chores"
        case .reward: return "Add Rewards"
        }
    }
    private var bannerColor: Color {
        switch kind {
        case .rule: return Color(hex: "#A2AFC1")
        case .chore: return Color(hex: "#C3BCA5")
        case .reward: return Color(hex: "#A5ADC3")
        }
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: bannerColor,
            bannerHeight: 100,
            content: {
                VStack(spacing: 0) {
                    PageTitle(modalTitle) {
                        IconRoundButton(iconName: "icon_close", action: onClose)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(catalogue) { cat in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(categoryTitle(cat.category))
                                        .font(.custom("Inter-Medium", size: 24))
                                        .foregroundColor(cat.category.selectedColor)
                                        .padding(.bottom, 4)
                                    ForEach(Array(cat.items.enumerated()), id: \ .element.id) { index, template in
                                        let isSelected = selectedTemplates.contains(template.id)
                                        let baseColor = colorForIndex(index)
                                        let backgroundColor = isSelected ? baseColor : baseColor.opacity(0.3)
                                        let textColor = isSelected ? Color.white : baseColor
                                        if kind == .reward {
                                            // Use RewardAdultCard for rewards, pass textColor
                                            RewardAdultCard(
                                                task: Task(
                                                    kind: .reward,
                                                    title: template.title,
                                                    peanuts: template.peanuts,
                                                    category: template.category,
                                                    isSelected: isSelected,
                                                    templateID: template.id
                                                ),
                                                backgroundColor: backgroundColor,
                                                textColor: textColor,
                                                onTap: {
                                                    if isSelected {
                                                        selectedTemplates.remove(template.id)
                                                        store.deleteTaskByTemplateID(template.id)
                                                    } else {
                                                        selectedTemplates.insert(template.id)
                                                        store.addTaskFromTemplate(template, kind: kind)
                                                    }
                                                }
                                            )
                                            .environmentObject(store)
                                        } else {
                                            CatalogueRow(
                                                template: template,
                                                isSelected: isSelected,
                                                backgroundColor: backgroundColor,
                                                textColor: textColor,
                                                onTap: {
                                                    if isSelected {
                                                        selectedTemplates.remove(template.id)
                                                        store.deleteTaskByTemplateID(template.id)
                                                    } else {
                                                        selectedTemplates.insert(template.id)
                                                        store.addTaskFromTemplate(template, kind: kind)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 24)
                    }
                }
            }
        )
        .onAppear(perform: loadCatalogue)
    }
    private func categoryTitle(_ category: Category) -> String {
        switch category {
        case .security: return "Security"
        case .respect: return "Respect & Boundaries"
        case .fun: return "Fun / Other"
        }
    }
    private func loadCatalogue() {
        let filename: String
        switch kind {
        case .rule: filename = "rules"
        case .chore: filename = "chores"
        case .reward: filename = "rewards"
        }
        print("Loading catalogue for: \(filename)")
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Catalogue file not found!")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([CatalogueCategory].self, from: data)
            self.catalogue = decoded
            print("Loaded catalogue: \(decoded)")
        } catch {
            print("Failed to load catalogue: \(error)")
        }
        loading = false
    }
}

struct CatalogueRow: View {
    let template: TaskTemplate
    let isSelected: Bool
    let backgroundColor: Color
    let textColor: Color
    let onTap: () -> Void
    @State private var isTapped: Bool = false
    @EnvironmentObject private var store: Store
    var body: some View {
        HStack(spacing: 0) {
            // Left section: flexible width
            ZStack(alignment: .leading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(template.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(textColor)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            // Dashed line, always visible
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(backgroundColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            // Right section: fixed width (144pt for rule/chore, 160pt for reward)
            ZStack {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    Text("\(template.peanuts)")
                        .foregroundColor(.white)
                        .frame(width: 20)
                    Spacer().frame(width: 4)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    Spacer().frame(width: 24)
                    Image(isSelected ? "icon_delete" : "icon_plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: template.category == .fun ? 168 : 144, height: 90)
        }
        .font(.custom("Inter-Medium", size: 24))
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isTapped)
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                isTapped = false
                onTap()
            }
        }
    }
} 