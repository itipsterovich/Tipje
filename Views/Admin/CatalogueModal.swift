import SwiftUI

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
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                PageTitle(modalTitle) {
                    IconRoundButton(iconName: "icon_close", action: onClose)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(catalogue) { cat in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(categoryTitle(cat.category))
                                    .font(.custom("Inter-Medium", size: 24))
                                    .foregroundColor(cat.category.selectedColor)
                                    .padding(.bottom, 4)
                                ForEach(cat.items) { template in
                                    CatalogueRow(template: template, isSelected: selectedTemplates.contains(template.id)) {
                                        if selectedTemplates.contains(template.id) {
                                            selectedTemplates.remove(template.id)
                                            store.deleteTaskByTemplateID(template.id)
                                        } else {
                                            selectedTemplates.insert(template.id)
                                            store.addTaskFromTemplate(template, kind: kind)
                                        }
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
    let onTap: () -> Void
    var body: some View {
        HStack(spacing: 0) {
            // Left section: flexible width
            ZStack(alignment: .leading) {
                (isSelected ? template.category.selectedColor : template.category.defaultColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(template.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(isSelected ? .white : template.category.defaultTextColor)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            // Dashed line, always visible
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(isSelected ? template.category.selectedColor : template.category.defaultColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            // Right section: fixed width (144pt)
            ZStack {
                (isSelected ? template.category.selectedColor : template.category.defaultColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    Text("\(template.peanuts)")
                        .foregroundColor(isSelected ? .white : template.category.defaultTextColor)
                        .frame(width: 20)
                    Spacer().frame(width: 4)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? .white : template.category.defaultTextColor)
                    Spacer().frame(width: 24)
                    Button(action: onTap) {
                        Image(isSelected ? "icon_delete" : "icon_plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelected ? .white : template.category.defaultTextColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: 144, height: 90)
        }
        .font(.custom("Inter-Medium", size: 24))
        .frame(height: 90)
        .frame(maxWidth: .infinity)
    }
} 