import SwiftUI

struct RewardKidCard: View {
    let reward: Reward
    var canBuy: Bool = true
    var onTap: (() -> Void)? = nil
    var basketMode: Bool = false
    var quantity: Int = 1
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            RewardKidCardiPhone(reward: reward, canBuy: canBuy, onTap: onTap, basketMode: basketMode, quantity: quantity)
        } else {
            RewardKidCardiPad(reward: reward, canBuy: canBuy, onTap: onTap, basketMode: basketMode, quantity: quantity)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct RewardKidCardiPhone: View {
    let reward: Reward
    var canBuy: Bool = true
    var onTap: (() -> Void)? = nil
    var basketMode: Bool = false
    var quantity: Int = 1
    @State private var isTapped: Bool = false
    @EnvironmentObject var store: TipjeStore
    var body: some View {
        let catalogItem = (rewardsCatalog + store.customRewards).first(where: { $0.id == reward.id })
        let baseColor = catalogItem?.color ?? Color(.systemGray5)
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(catalogItem?.title ?? "")
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 14)
                    .padding(.trailing, 14)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Medium", size: 17))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, alignment: .leading)
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 40))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(baseColor)
            .frame(width: 1.5, height: 40)
            .padding(.vertical, 14)
            ZStack {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 10)
                    if basketMode {
                        HStack(spacing: 4) {
                            Text("x\(quantity)")
                                .font(.custom("Inter-Medium", size: 17))
                                .foregroundColor(.white)
                            Button(action: { onTap?() }) {
                                Image("icon_give")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        HStack(spacing: 4) {
                            Text("\(reward.cost)")
                                .foregroundColor(.white)
                                .font(.custom("Inter-Medium", size: 17))
                                .frame(width: 20, alignment: .trailing)
                            Image("icon_peanut")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer().frame(width: 10)
                }
                .frame(height: 70)
            }
            .frame(width: 100, height: 70)
        }
        .frame(height: 70)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .opacity((!canBuy && !basketMode) ? 0.75 : 1.0)
        .onTapGesture {
            if basketMode {
                onTap?()
            } else if canBuy {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                }
                onTap?()
            } else {
                // Disabled, but still call onTap to allow parent to show modal
                onTap?()
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] RewardKidCardiPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct RewardKidCardiPad: View {
    let reward: Reward
    var canBuy: Bool = true
    var onTap: (() -> Void)? = nil
    var basketMode: Bool = false
    var quantity: Int = 1
    @State private var isTapped: Bool = false
    @EnvironmentObject var store: TipjeStore
    var body: some View {
        let catalogItem = (rewardsCatalog + store.customRewards).first(where: { $0.id == reward.id })
        let baseColor = catalogItem?.color ?? Color(.systemGray5)
        HStack(spacing: 0) {
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
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(baseColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
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
            .frame(width: 128, height: 90)
        }
        .frame(height: 90)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .opacity((!canBuy && !basketMode) ? 0.75 : 1.0)
        .onTapGesture {
            if basketMode {
                onTap?()
            } else if canBuy {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                }
                onTap?()
            } else {
                // Disabled, but still call onTap to allow parent to show modal
                onTap?()
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] RewardKidCardiPad size: \(geo.size)")
                    }
            }
        )
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
