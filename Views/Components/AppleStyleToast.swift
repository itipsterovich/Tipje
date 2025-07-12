import SwiftUI

struct AppleStyleToast: View {
    let message: String
    let systemImage: String?
    let iconColor: Color
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isPad: Bool { horizontalSizeClass == .regular }
    var body: some View {
        HStack(spacing: isPad ? 18 : 12) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: isPad ? 24 : 22, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            Text(message)
                .font(.custom("Inter-Regular-Medium", size: isPad ? 24 : 17))
                .foregroundColor(Color(hex: "#494646"))
        }
        .padding(.horizontal, isPad ? 32 : 24)
        .padding(.vertical, isPad ? 18 : 14)
        .background(
            RoundedRectangle(cornerRadius: isPad ? 24 : 18)
                .fill(Color.white)
        )
        .cornerRadius(isPad ? 24 : 18)
        .shadow(radius: isPad ? 12 : 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding(.top, isPad ? 80 : 60)
    }
} 