import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct RuleKidCard: View {
    let rule: Rule
    var isCompleted: Bool
    var cardColor: Color = Color(.systemGray5)
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    var onExpand: (() -> Void)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            RuleKidCardiPhone(rule: rule, isCompleted: isCompleted, cardColor: cardColor, onTap: onTap, expanded: expanded, onExpand: onExpand)
        } else {
            RuleKidCardiPad(rule: rule, isCompleted: isCompleted, cardColor: cardColor, onTap: onTap, expanded: expanded, onExpand: onExpand)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct RuleKidCardiPhone: View {
    let rule: Rule
    var isCompleted: Bool
    var cardColor: Color = Color(.systemGray5)
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    var onExpand: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    var body: some View {
        let baseColor = cardColor
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(rule.title)
                    .lineLimit(expanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 14)
                    .padding(.trailing, 14)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Medium", size: 17))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onExpand?()
                }
            }
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 40))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(isCompleted ? baseColor.opacity(0.3) : baseColor)
            .frame(width: 1.5, height: 40)
            .padding(.vertical, 14)
            ZStack {
                (isCompleted ? baseColor.opacity(0.3) : baseColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#799B44"))
                        .opacity(1.0)
                } else {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 14)
                        Text("\(rule.peanutValue)")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Medium", size: 17))
                            .frame(width: 15, alignment: .trailing)
                        Spacer().frame(width: 4)
                        Image("icon_peanut")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        Spacer().frame(width: 14)
                    }
                    .frame(height: 70)
                }
            }
            .frame(width: 100, height: 70)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onTap?()
                }
            }
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
    }
}

// =======================
// iPad layout
// =======================
struct RuleKidCardiPad: View {
    let rule: Rule
    var isCompleted: Bool
    var cardColor: Color = Color(.systemGray5)
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    var onExpand: (() -> Void)? = nil
    @State private var isTapped: Bool = false
    var body: some View {
        let baseColor = cardColor
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                baseColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(rule.title)
                    .lineLimit(expanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Medium", size: 24))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onExpand?()
                }
            }
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(isCompleted ? baseColor.opacity(0.3) : baseColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            ZStack {
                (isCompleted ? baseColor.opacity(0.3) : baseColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color(hex: "#799B44"))
                        .opacity(1.0)
                } else {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 24)
                        Text("\(rule.peanutValue)")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Medium", size: 24))
                            .frame(width: 15, alignment: .trailing)
                        Spacer().frame(width: 4)
                        Image("icon_peanut")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        Spacer().frame(width: 24)
                    }
                    .frame(height: 90)
                }
            }
            .frame(width: 128, height: 90)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onTap?()
                }
            }
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] RuleKidCardiPad size: \(geo.size)")
                    }
            }
        )
    }
}

#if DEBUG
struct RuleKidCard_Previews: PreviewProvider {
    static var previews: some View {
        RuleKidCard(
            rule: Rule(id: "rule1", title: "Take off your shoes", peanutValue: 3, isActive: true),
            isCompleted: false
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif 