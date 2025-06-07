import SwiftUI

enum OnboardingStep {
    case slides, login, kidsProfile, pinSetup
}

struct OnboardingView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false
    @State private var step: OnboardingStep = .slides
    @State private var userId: String = ""
    @EnvironmentObject var store: Store

    var body: some View {
        switch step {
        case .slides:
            OnboardingSlidesView(onNext: { step = .login })
        case .login:
            LoginView(onLogin: { uid in
                userId = uid
                store.setUser(userId: uid)
                // Check if user already has kids
                FirestoreManager.shared.fetchKids(userId: uid) { kids in
                    DispatchQueue.main.async {
                        if kids.isEmpty {
                            step = .kidsProfile
                        } else {
                            // User already has kids, complete onboarding and go to main app
                            didCompleteOnboarding = true
                        }
                    }
                }
            })
        case .kidsProfile:
            KidsProfileView(userId: userId, onNext: { step = .pinSetup })
        case .pinSetup:
            PinSetupView(userId: userId) {
                shouldShowAdminAfterOnboarding = true
                didCompleteOnboarding = true
            }
        }
    }
}

struct OnboardingSlidesView: View {
    var onNext: () -> Void
    @State private var currentPage = 0
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    let colors: [Color] = [
        Color(hex: "#D78C28"),
        Color(hex: "#7F9BAD"),
        Color(hex: "#7FAD98"),
        Color(hex: "#C48A8A"),
        Color(hex: "#ADA57F")
    ]
    var languageOptions: [String] { ["en", "nl"] }
    func languageDisplay(_ code: String) -> String {
        switch code {
        case "en": return "🇬🇧 English"
        case "nl": return "🇳🇱 Dutch"
        default: return code
        }
    }
    var body: some View {
        TabView(selection: $currentPage) {
            // Screen 1
            ZStack {
                Color(hex: "#D78C28").ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                VStack {
                    Spacer().frame(height: 0)
                    Image("Tipje_logo")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .frame(height: 96)
                        .padding(.top, 100)
                        .padding(.bottom, 40)
                    Image("on_2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 480)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 40)
                        .allowsHitTesting(false)
                    VStack {
                        Text("Built your safe family castle")
                            .font(.custom("Inter-Regular_SemiBold", size: 40))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Spacer().frame(height: 16)
                        Text("Bring harmony and clarity to your family life with personalized rules and fun rewards")
                            .font(.custom("Inter-Regular_Medium", size: 20))
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 500)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer().frame(height: 24)
                        CustomDropdownCompact(
                            selection: $selectedLanguage,
                            options: languageOptions,
                            display: languageDisplay
                        )
                        .padding(.bottom, 60)
                    }
                    ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#D78C28"), action: {
                        withAnimation { currentPage = 1 }
                    })
                    .padding(.bottom, 64)
                }
            }
            .tag(0)
            // Screen 2
            ZStack {
                Color(hex: "#7F9BAD").ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                VStack {
                    Spacer().frame(height: 72)
                    Image("on_1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 641)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 32)
                        .allowsHitTesting(false)
                        .padding(.top, 60)
                    Text("Fun Tasks & Real Rewards")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 16)
                    Text("Kids complete exciting tasks, earn peanuts, and redeem real-life rewards chosen by you.")
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, )
                        .frame(maxWidth: 500)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7F9BAD"), action: {
                        withAnimation { currentPage = 2 }
                    })
                    .padding(.bottom, 64)
                }
            }
            .tag(1)
            // Screen 3
            ZStack {
                Color(hex: "#7FAD98").ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                Image("on_3b")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 641)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .ignoresSafeArea()
                    .offset(y: 40)
                    .allowsHitTesting(false)
                VStack(spacing: 0) {
                    Image("on_3a")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                        .allowsHitTesting(false)
                    Text("Customize Your Family Rules")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 16)
                    Text("Select from a curated catalog of rules and chores that fit your unique family dynamic. No more repeating yourself—just clear, consistent communication.")
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 500)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7FAD98"), action: {
                        withAnimation { currentPage = 3 }
                    })
                    .padding(.bottom, 64)
                }
            }
            .tag(2)
            // Screen 4
            ZStack {
                Color(hex: "#C48A8A").ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                VStack {
                    Spacer().frame(height: 72)
                    Image("on_4")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 641)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 32)
                        .allowsHitTesting(false)
                    Text("Strengthen Family Bonds")
                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer().frame(height: 16)
                    Text("Kids complete exciting tasks, earn peanuts, and redeem real-life rewards chosen by you.")
                        .font(.custom("Inter-Regular_Medium", size: 20))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 500)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#C48A8A"), action: {
                        onNext()
                    })
                    .padding(.bottom, 64)
                }
            }
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif

// Place the extension here, after everything else:
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
} 
