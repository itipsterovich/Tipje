import SwiftUI

struct ChoreKidCard: View {
    let chore: Chore
    var isCompleted: Bool
    var onTap: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                Color(.systemGray5)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(chore.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(Color(.systemGray5))
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            ZStack {
                Color(.systemGray5)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    Text("\(chore.peanutValue)")
                        .foregroundColor(.white)
                        .font(.custom("Inter-Medium", size: 24))
                        .frame(width: 32, alignment: .trailing)
                    Spacer().frame(width: 12)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: 120, height: 90)
        }
        .frame(height: 90)
        .opacity(isCompleted ? 0.3 : 1)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isTapped)
        .onTapGesture {
            guard !isCompleted else { return }
            isTapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                isTapped = false
            }
            onTap?()
        }
    }
}

#if DEBUG
struct ChoreKidCard_Previews: PreviewProvider {
    static var previews: some View {
        ChoreKidCard(chore: Chore(id: "1", title: "Clean your room", peanutValue: 5, isActive: true), isCompleted: false)
            .previewLayout(.sizeThatFits)
    }
}
#endif 