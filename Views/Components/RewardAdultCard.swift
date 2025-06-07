import SwiftUI

struct RewardAdultCard: View {
    let reward: Reward
    var onArchive: (() -> Void)? = nil
    var textColor: Color = .white
    var selected: Bool = false
    var baseColor: Color = Color(hex: "#A5ADC3") // Example color, replace with color library
    @State private var isTapped: Bool = false
    var body: some View {
        let backgroundColor = selected ? baseColor : baseColor.opacity(0.2)
        let contentColor = selected ? Color.white : baseColor
        HStack(spacing: 0) {
            // Left section: flexible width
            ZStack(alignment: .leading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(reward.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(contentColor)
                    .font(.custom("Inter-Medium", size: 24))
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
                .foregroundColor(backgroundColor)
                .frame(width: 1.5, height: 60)
                .padding(.vertical, 15)
                // Right section
                ZStack {
                    backgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    HStack(spacing: 0) {
                        Spacer().frame(width: 24)
                        Text("\(reward.cost)")
                            .foregroundColor(contentColor)
                            .font(.custom("Inter-Medium", size: 24))
                            .frame(width: 32, alignment: .trailing)
                        Spacer().frame(width: 12)
                        Image("icon_peanut")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(contentColor)
                        Spacer().frame(width: 24)
                        Image(selected ? "icon_delete" : "icon_plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(contentColor)
                        Spacer().frame(width: 24)
                    }
                    .frame(height: 90)
                }
                .frame(width: 168, height: 90)
            }
            .fixedSize() // Ensures dash + right section never shrink
        }
        .font(.custom("Inter-Medium", size: 24))
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isTapped)
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                isTapped = false
            }
        }
    }
} 
