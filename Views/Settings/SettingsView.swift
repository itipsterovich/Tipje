import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Add LanguagePicker (EN / NL)
            // TODO: Add Change PIN, Change email/password, Log out
            // TODO: Add version label
        }
        .padding(.horizontal, 24)
        .font(.custom("Inter-Medium", size: 24))
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif 