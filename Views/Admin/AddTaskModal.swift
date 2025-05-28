import SwiftUI

struct AddTaskModal: View {
    let kind: TaskKind // .rule or .chore
    var onSave: (Task) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var peanuts: Int = 1
    @State private var category: Category = .security
    
    private var bannerColor: Color {
        switch kind {
        case .rule: return Color(hex: "#A2AFC1")
        case .chore: return Color(hex: "#C3BCA5")
        case .reward: return Color.white // fallback, not used here
        }
    }
    var body: some View {
        BannerPanelLayout(
            bannerColor: bannerColor,
            bannerHeight: 100,
            content: {
                ScrollView {
                    VStack(spacing: 24) {
                        PageTitle(kind == .rule ? "Add new rule" : "Add new chore") {
                            IconRoundButton(iconName: "icon_close", action: { dismiss() })
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        TextField("Title", text: $title)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        HStack {
                            Text("Peanuts")
                            Stepper(value: $peanuts, in: 1...20) {
                                Text("\(peanuts)")
                            }
                        }
                        .font(.custom("Inter-Medium", size: 24))
                        Picker("Category", selection: $category) {
                            ForEach(Category.allCases, id: \.self) { cat in
                                Text(String(describing: cat).capitalized).tag(cat)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
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
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(24)
                }
            }
        )
    }
    private func save() {
        let task = Task(kind: kind, title: title, peanuts: peanuts, category: category, isSelected: true)
        onSave(task)
        dismiss()
    }
} 