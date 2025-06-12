import SwiftUI

struct RewardKidCard: View {
    let reward: Reward
    var canBuy: Bool = true
    var onTap: (() -> Void)? = nil
    var basketMode: Bool = false
    var quantity: Int = 1
    @State private var isTapped: Bool = false
    var body: some View {
        let catalogItem = rewardsCatalog.first(where: { $0.id == reward.id })
        let baseColor = catalogItem?.color ?? Color(.systemGray5)
        HStack(spacing: 0) {
            // Left section: colored background, always 100% opacity
            ZStack(alignment: .leading) {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(catalogItem?.title ?? "")
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
            // Dash
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(baseColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            // Right section: fixed width (120pt)
            ZStack {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    if basketMode {
                        HStack(spacing: 4) {
                            Text("x\(quantity)")
                                .font(.custom("Inter-Medium", size: 24))
                                .foregroundColor(.white)
                            Button(action: { onTap?() }) {
                                Image("icon_give")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        Text("\(reward.cost)")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Medium", size: 24))
                            .frame(width: 32, alignment: .trailing)
                        Spacer().frame(width: 8)
                        Image("icon_peanut")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    Spacer().frame(width: 24)
                }
                .frame(height: 90)
            }
            .frame(width: 120 + 8, height: 90)
        }
        .frame(height: 90)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .opacity((!canBuy && !basketMode) ? 0.75 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isTapped)
        .onTapGesture {
            if basketMode {
                onTap?()
            } else if canBuy {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    isTapped = false
                }
                onTap?()
            } else {
                // Disabled, but still call onTap to allow parent to show modal
                onTap?()
            }
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
        RewardKidCard(reward: .init(
            id: "reward1",
            title: "Extra screen time",
            cost: 10,
            isActive: true
        ), canBuy: true)
            .previewLayout(.sizeThatFits)
    }
}
#endif 
