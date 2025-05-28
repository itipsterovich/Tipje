import SwiftUI

struct AddRewardModal: View {
    var onSave: (Task) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var peanuts: Int = 1
    @State private var category: Category = .fun
    
    var body: some View {
        BannerPanelLayout(
            bannerColor: Color(hex: "#A5ADC3"),
            bannerHeight: 100,
            content: {
                ScrollView {
                    VStack(spacing: 24) {
                        PageTitle("Add reward") {
                            IconRoundButton(iconName: "icon_close", action: { dismiss() })
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        // Preview card
                        HStack(spacing: 0) {
                            // Left section: flexible width
                            ZStack(alignment: .leading) {
                                category.selectedColor
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                Text(title.isEmpty ? "Reward title" : title)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 24)
                                    .padding(.vertical, 14)
                                    .foregroundColor(.white)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
                            // Dash + right section: fixed width group
                            HStack(spacing: 0) {
                                // Dash
                                Path { path in
                                    path.move(to: CGPoint(x: 0.75, y: 0))
                                    path.addLine(to: CGPoint(x: 0.75, y: 60))
                                }
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                                .foregroundColor(category.selectedColor)
                                .frame(width: 1.5, height: 60)
                                .padding(.vertical, 15)
                                // Right section
                                ZStack {
                                    category.selectedColor
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    HStack(spacing: 0) {
                                        Spacer().frame(width: 24)
                                        Text("\(peanuts)")
                                            .foregroundColor(.white)
                                            .frame(width: 32, alignment: .trailing)
                                        Spacer().frame(width: 12)
                                        Image("icon_peanut")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.white)
                                        Spacer().frame(width: 24)
                                        Image("icon_plus")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.white)
                                        Spacer().frame(width: 24)
                                    }
                                    .frame(height: 90)
                                }
                                .frame(width: 168, height: 90)
                            }
                            .fixedSize() // Ensures dash + right section never shrink
                        }
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        // End preview card
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
        let task = Task(kind: .reward, title: title, peanuts: peanuts, category: category, isSelected: true)
        onSave(task)
        dismiss()
    }
} 