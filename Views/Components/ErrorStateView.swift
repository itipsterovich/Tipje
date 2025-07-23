import SwiftUI

struct ErrorStateView: View {
    let headline: String
    let bodyText: String
    let buttonTitle: String
    let onButtonTap: () -> Void
    let imageName: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding(.bottom, 8)
            }
            Text(headline)
                .font(.custom("Inter-Regular_SemiBold", size: 32))
                .foregroundColor(Color(hex: "#494646"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            Text(bodyText)
                .font(.custom("Inter-Regular_Medium", size: 20))
                .foregroundColor(Color(hex: "#494646").opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            ButtonText(title: buttonTitle, variant: .primary, action: onButtonTap, fontSize: 24)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorStateView(
            headline: "Welcome back!",
            bodyText: "It looks like you were logged out. Please log in again to continue your journey with Tipje.",
            buttonTitle: NSLocalizedString("error_login", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
            onButtonTap: {},
            imageName: "mascot_empty_chores"
        )
    }
}
#endif 