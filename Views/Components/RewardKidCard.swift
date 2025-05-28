import SwiftUI

struct RewardKidCard: View {
    @Bindable var task: Task
    var onTap: (() -> Void)? = nil
    var basketMode: Bool = false
    var backgroundColor: Color
    @State private var isTapped: Bool = false
    var body: some View {
        HStack(spacing: 0) {
            // Left section: Text with left rounded corners
            ZStack(alignment: .leading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(task.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            // Dashed line, always visible, inside right section
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(backgroundColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            // Right section: fixed width (120pt)
            ZStack {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    if basketMode {
                        Button(action: { onTap?() }) {
                            Image("icon_give")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("\(task.peanuts)")
                            .foregroundColor(.white)
                        Spacer().frame(width: 4)
                        Image("icon_peanut")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: 120, height: 90)
        }
        .frame(height: 90)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isTapped)
        .onTapGesture {
            isTapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                isTapped = false
            }
            onTap?()
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#if DEBUG
struct RewardKidCard_Previews: PreviewProvider {
    static var previews: some View {
        RewardKidCard(task: .init(kind: .reward, title: "Extra screen time", peanuts: 10, category: .fun), backgroundColor: .blue)
            .previewLayout(.sizeThatFits)
    }
}
#endif 