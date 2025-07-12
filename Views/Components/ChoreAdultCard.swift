import SwiftUI

/// Main switcher: delegates to iPhone/iPad sub-structs based on horizontalSizeClass.
struct ChoreAdultCard: View {
    let chore: Chore
    var onArchive: (() -> Void)? = nil
    var selected: Bool = false
    var baseColor: Color = Color(hex: "#A2AFC1")
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            ChoreAdultCardiPhone(chore: chore, onArchive: onArchive, selected: selected, baseColor: baseColor, onTap: onTap, expanded: expanded)
        } else {
            ChoreAdultCardiPad(chore: chore, onArchive: onArchive, selected: selected, baseColor: baseColor, onTap: onTap, expanded: expanded)
        }
    }
}

// =======================
// iPhone layout
// =======================
struct ChoreAdultCardiPhone: View {
    let chore: Chore
    var onArchive: (() -> Void)? = nil
    var selected: Bool = false
    var baseColor: Color = Color(hex: "#A2AFC1")
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    @State private var isTapped: Bool = false
    var body: some View {
        let backgroundColor = selected ? baseColor : baseColor.opacity(0.2)
        let contentColor = selected ? Color.white : baseColor
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(chore.title)
                    .lineLimit(expanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 14)
                    .padding(.trailing, 14)
                    .padding(.vertical, 14)
                    .foregroundColor(contentColor)
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
                    onTap?()
                }
            }
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 42))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(backgroundColor)
            .frame(width: 1.5, height: 42)
            .padding(.vertical, 14)
            ZStack {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 10)
                    Text("\(chore.peanutValue)")
                        .foregroundColor(contentColor)
                        .font(.custom("Inter-Medium", size: 17))
                        .frame(width: 20, alignment: .trailing)
                    Spacer().frame(width: 4)
                    Image("icon_peanut")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(contentColor)
                    Spacer().frame(width: 12)
                    Image(selected ? "icon_delete" : "icon_plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(contentColor)
                    Spacer().frame(width: 14)
                }
                .frame(height: 70)
            }
            .frame(width: 100, height: 70)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onArchive?()
                }
            }
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .scaleEffect(isTapped ? 1.08 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.interpolatingSpring(stiffness: 700, damping: 14), value: isTapped)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("[DEBUG] ChoreAdultCardiPhone size: \(geo.size)")
                    }
            }
        )
    }
}

// =======================
// iPad layout
// =======================
struct ChoreAdultCardiPad: View {
    let chore: Chore
    var onArchive: (() -> Void)? = nil
    var selected: Bool = false
    var baseColor: Color = Color(hex: "#A2AFC1")
    var onTap: (() -> Void)? = nil
    var expanded: Bool = false
    @State private var isTapped: Bool = false
    var body: some View {
        let backgroundColor = selected ? baseColor : baseColor.opacity(0.2)
        let contentColor = selected ? Color.white : baseColor
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(chore.title)
                    .lineLimit(expanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                    .padding(.vertical, 14)
                    .foregroundColor(contentColor)
                    .font(.custom("Inter-Medium", size: 24))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90, alignment: .leading)
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
            Path { path in
                path.move(to: CGPoint(x: 0.75, y: 0))
                path.addLine(to: CGPoint(x: 0.75, y: 60))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
            .foregroundColor(backgroundColor)
            .frame(width: 1.5, height: 60)
            .padding(.vertical, 15)
            ZStack {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                HStack(spacing: 0) {
                    Spacer().frame(width: 24)
                    Text("\(chore.peanutValue)")
                        .foregroundColor(contentColor)
                        .font(.custom("Inter-Medium", size: 24))
                        .frame(width: 20, alignment: .trailing)
                    Spacer().frame(width: 4)
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
            .frame(width: 144, height: 90)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 700, damping: 14)) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped = false
                    onArchive?()
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
                        print("[DEBUG] ChoreAdultCardiPad size: \(geo.size)")
                    }
            }
        )
    }
} 