import SwiftUI

struct OnboardingView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false
    @EnvironmentObject var onboardingState: OnboardingStateManager
    @State private var userId: String = ""
    @EnvironmentObject var store: Store
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        switch onboardingState.onboardingStep {
        case .slides:
            OnboardingSlidesView(onNext: { onboardingState.onboardingStep = .login })
        case .login:
            LoginView(onLogin: { uid in
                userId = uid
                store.setUser(userId: uid)
                onboardingState.userId = uid
                onboardingState.checkOnboardingState(userId: uid)
            })
        case .kidsProfile:
            KidsProfileView(userId: onboardingState.userId, onNext: {
                onboardingState.onboardingStep = .pinSetup
            })
        case .pinSetup:
            PinSetupView(userId: onboardingState.userId, onPinSet: {
                shouldShowAdminAfterOnboarding = true
                didCompleteOnboarding = true
                onboardingState.completeOnboarding(userId: onboardingState.userId)
                onboardingState.onboardingStep = .done
            })
        case .done:
            EmptyView() // Onboarding is done, TipjeApp/MainView will take over
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            TabView(selection: $currentPage) {
                // Screen 1
                ZStack {
                    Color(hex: "#D78C28").ignoresSafeArea()
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()
                    if horizontalSizeClass == .compact {
                        // iPhone Portrait: Logo 1.3x, mascot offset y:70
                        VStack(spacing: 24) {
                            Image("Tipje_logo")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.3)
                                .frame(height: 72)
                                .padding(.top, 24)
                            Image("on_2")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.7)
                                .frame(height: 180)
                                .offset(y: 30)
                            Spacer()
                            VStack(spacing: 24) {
                                Text("Raise confident kids, connect as a family")
                                    .font(.custom("Inter-Regular_SemiBold", size: 32))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                Text("Tipje helps you build habits, stay connected, and enjoy parenting more.")
                                    .font(.custom("Inter-Regular_Medium", size: 20))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .frame(maxWidth: 500)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.bottom, 14)
                            CustomDropdownCompact(
                                selection: $selectedLanguage,
                                options: languageOptions,
                                display: languageDisplay
                            )
                            .padding(.bottom, 16)
                            ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#D78C28"), action: {
                                withAnimation { currentPage = 1 }
                            })
                            .accessibilityIdentifier("onboardingNextButton1")
                            .padding(.bottom, 48)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    } else {
                        // iPad Portrait: as is
                        ZStack(alignment: .top) {
                            Color(hex: "#D78C28").ignoresSafeArea()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).ignoresSafeArea()
                            VStack {
                                Spacer().frame(height: 100)
                                Image("Tipje_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(1.0)
                                    .frame(height: 144)
                                    .padding(.top, 24)
                                Spacer().frame(height: 100)
                                Image("on_2")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(1.6)
                                    .frame(height: 260)
                                    .allowsHitTesting(false)
                                Spacer().frame(height: 100)
                                VStack(spacing: 16) {
                                    Text("Raise confident kids, connect as a family")
                                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                                        .frame(maxWidth: 700)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("Tipje helps you build habits, stay connected, and enjoy parenting more.")
                                        .font(.custom("Inter-Regular_Medium", size: 20))
                                        .foregroundColor(.white)
                                        .opacity(0.8)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                        .frame(maxWidth: 500)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.bottom, 24)
                                CustomDropdownCompact(
                                    selection: $selectedLanguage,
                                    options: languageOptions,
                                    display: languageDisplay
                                )
                                .padding(.bottom, 40)
                                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#D78C28"), action: {
                                    withAnimation { currentPage = 1 }
                                })
                                .accessibilityIdentifier("onboardingNextButton1")
                                .padding(.bottom, 64)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
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
                    if horizontalSizeClass == .compact {
                        VStack {
                            Spacer().frame(height: 72)
                            Image("mascot_reward")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.0)
                                .frame(height: 400)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .padding(.bottom, 20)
                                .allowsHitTesting(false)
                                .padding(.top, 0)
                            Text("Fun Tasks & Real Rewards")
                                .font(.custom("Inter-Regular_SemiBold", size: 32))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer().frame(height: 16)
                            Text("Kids build good habits, earn peanuts, and unlock real-life treats chosen by you.")
                                .font(.custom("Inter-Regular_Medium", size: 20))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .frame(maxWidth: 500)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7F9BAD"), action: {
                                withAnimation { currentPage = 2 }
                            })
                            .accessibilityIdentifier("onboardingNextButton2")
                            .padding(.bottom, 64)
                        }
                    } else {
                        VStack {
                            Spacer().frame(height: 72)
                            Image("mascot_reward")
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
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer().frame(height: 16)
                            Text("Kids build good habits, earn peanuts, and unlock real-life treats chosen by you.")
                                .font(.custom("Inter-Regular_Medium", size: 20))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .frame(maxWidth: 500)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7F9BAD"), action: {
                                withAnimation { currentPage = 2 }
                            })
                            .accessibilityIdentifier("onboardingNextButton2")
                            .padding(.bottom, 64)
                        }
                    }
                }
                .tag(1)
                // Screen 3
                Group {
                    if horizontalSizeClass == .compact {
                        // iPhone: both on_3a and on_3b as background, text/button above
                        ZStack {
                            Color(hex: "#7FAD98").ignoresSafeArea()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).ignoresSafeArea()
                            VStack(spacing: 0) {
                                Image("on_3a")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .top)
                                    .allowsHitTesting(false)
                                Spacer()
                                Image("on_3b")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 400)
                                    .offset(x: 140, y: 50)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .bottom)
                                    .alignmentGuide(.bottom) { d in d[.bottom] }
                            }
                            VStack(spacing: 0) {
                                Text("Set Rules That Match Your Family's Values")
                                    .font(.custom("Inter-Regular_SemiBold", size: 40))
                                    .frame(maxWidth: 700)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                Spacer().frame(height: 16)
                                Text("Choose from a curated collection of mindful rules—designed to guide your family with clarity and kindness.")
                                    .font(.custom("Inter-Regular_Medium", size: 20))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .frame(maxWidth: 500)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7FAD98"), action: {
                                    onNext()
                                })
                                .accessibilityIdentifier("onboardingNextButton3")
                                .padding(.bottom, 64)
                            }
                        }
                    } else {
                        // iPad: on_3a at top, on_3b at bottom, text/button above
                        ZStack {
                            Color(hex: "#7FAD98").ignoresSafeArea()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).ignoresSafeArea()
                            VStack(spacing: 0) {
                                Image("on_3a")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 500)
                                    .frame(maxWidth: .infinity)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .top)
                                    .allowsHitTesting(false)
                                Spacer()
                                Image("on_3b")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 500)
                                    .offset(x: 250, y: 0)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .bottom)
                                    .alignmentGuide(.bottom) { d in d[.bottom] }
                            }
                            VStack(spacing: 0) {
                                Text("Set Rules That Match Your Family's Values")
                                    .font(.custom("Inter-Regular_SemiBold", size: 40))
                                    .frame(maxWidth: 700)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                Spacer().frame(height: 16)
                                Text("Choose from a curated collection of mindful rules—designed to guide your family with clarity and kindness.")
                                    .font(.custom("Inter-Regular_Medium", size: 20))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .frame(maxWidth: 500)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7FAD98"), action: {
                                    onNext()
                                })
                                .accessibilityIdentifier("onboardingNextButton3")
                                .padding(.bottom, 64)
                            }
                        }
                    }
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
        }
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
