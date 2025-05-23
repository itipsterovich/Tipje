import SwiftUI

struct RuleAdultCard: View {
    @EnvironmentObject var store: Store
    let task: Task
    var body: some View {
        HStack(spacing: 0) {
            // Left section: flexible width
            ZStack(alignment: .leading) {
                (task.isSelected ? task.category.selectedColor : task.category.defaultColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(task.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(task.isSelected ? .white : task.category.defaultTextColor)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            // Dashed line, always visible, inside right section
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(task.isSelected ? task.category.selectedColor : task.category.defaultColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            // Right section: fixed width (144pt)
            ZStack {
                (task.isSelected ? task.category.selectedColor : task.category.defaultColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    Text("\(task.peanuts)")
                        .foregroundColor(task.isSelected ? .white : task.category.defaultTextColor)
                        .frame(width: 20)
                    Spacer().frame(width: 4)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(task.isSelected ? .white : task.category.defaultTextColor)
                    Spacer().frame(width: 24)
                    Button(action: { store.toggleSelection(for: task) }) {
                        Image(task.isSelected ? "icon_delete" : "icon_plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(task.isSelected ? .white : task.category.defaultTextColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: 144, height: 90)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
    }
} 