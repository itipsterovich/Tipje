import SwiftUI

struct AddTaskModal: View {
    let kind: TaskKind // .rule or .chore
    var onSave: (Task) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var peanuts: Int = 1
    @State private var category: Category = .security
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PageTitle(kind == .rule ? "Add new rule" : "Add new chore")
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
    private func save() {
        let task = Task(kind: kind, title: title, peanuts: peanuts, category: category, isSelected: true)
        onSave(task)
        dismiss()
    }
} 