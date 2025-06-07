import SwiftUI

struct BasketCard: View {
    let purchase: RewardPurchase
    var reward: Reward? = nil
    var onConfirm: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                Color(.systemGray5)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(reward?.title ?? "Reward")
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
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
                    Button(action: { onConfirm?() }) {
                        Image("icon_give")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
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
            onConfirm?()
        }
    }
}

#if DEBUG
import FirebaseFirestore
struct BasketCard_Previews: PreviewProvider {
    static var previews: some View {
        let dummyRef = Firestore.firestore().collection("dummy").document("dummy")
        BasketCard(purchase: RewardPurchase(id: "1", rewardRef: dummyRef, status: "IN_BASKET", purchasedAt: Date(), givenAt: nil), reward: Reward(id: "r1", title: "Ice Cream", cost: 10, isActive: true))
            .previewLayout(.sizeThatFits)
    }
}
#endif 