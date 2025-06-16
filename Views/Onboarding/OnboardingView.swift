import SwiftUI

struct OnboardingView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false
    @EnvironmentObject var onboardingState: OnboardingStateManager
    @State private var userId: String = ""
    @EnvironmentObject var store: Store
    @EnvironmentObject var authManager: AuthManager
    var isStage1: Bool // True for intro/login, False for kids/PIN setup

    init(isStage1: Bool = true) {
        self.isStage1 = isStage1
    }

    var body: some View {
        if isStage1 {
            // Stage 1: Intro slides and login
            OnboardingSlidesView(
                onLoginSuccess: { uid in
                    print("[OnboardingView] onLoginSuccess, uid=\(uid)")
                    userId = uid
                    print("[OnboardingView] Setting userId in Store and OnboardingStateManager: \(uid)")
                    store.setUser(userId: uid)
                    onboardingState.userId = uid
                    onboardingState.checkOnboardingState(userId: uid)
                }
            )
        } else {
            // Stage 2: Kids profile, PIN setup, admin cards based on onboardingStep
            Group {
                switch onboardingState.onboardingStep {
                case .kidsProfile:
                    KidsProfileView(userId: onboardingState.userId) {
                        onboardingState.onboardingStep = .pinSetup
                    } onLoginRequest: {
                        // Handle case where user was logged out
                        authManager.signOut()
                    }
                case .pinSetup:
                    PinSetupView(userId: onboardingState.userId) {
                        onboardingState.onboardingStep = .adminCards
                    }
                case .adminCards:
                    AdminView(onComplete: {
                        onboardingState.onboardingStep = .done
                        onboardingState.completeOnboarding(userId: onboardingState.userId)
                    })
                    .environmentObject(store)
                case .done:
                    // This should transition to MainView via TipjeApp
                    EmptyView()
                default:
                    // Fallback for any other state
                    EmptyView()
                }
            }
            .onChange(of: onboardingState.onboardingStep) { newStep in
                print("[OnboardingView] onboardingStep changed: \(newStep), userId=\(onboardingState.userId)")
            }
        }
    }
}

struct OnboardingSlidesView: View {
    var onLoginSuccess: (String) -> Void
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
    @State private var hasTriggeredAutoAdvance = false
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
                        VStack {
                            Spacer(minLength: 48)
                            Image("Tipje_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 72)
                            Spacer(minLength: 0)
                            Image("on_2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .padding(.bottom, 0)
                            Text("Raise confident kids, connect as a family")
                                .font(.custom("Inter-Regular_SemiBold", size: 32))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .padding(.bottom, 16)
                            Text("Tipje helps you build habits, stay connected, and enjoy parenting.")
                                .font(.custom("Inter-Regular_Medium", size: 20))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .frame(maxWidth: 500)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                            Spacer(minLength: 24)
                            CustomDropdownCompact(
                                selection: $selectedLanguage,
                                options: languageOptions,
                                display: languageDisplay
                            )
                            Spacer(minLength: 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    .frame(height: 300)
                                    .padding(.bottom, 16)
                                    .allowsHitTesting(false)
                                Spacer().frame(height: 100)
                                VStack(spacing: 16) {
                                    Text("Raise confident kids, connect as a family")
                                        .font(.custom("Inter-Regular_SemiBold", size: 40))
                                        .frame(maxWidth: 600)
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
                                        .lineLimit(nil)
                                }
                                .padding(.bottom, 24)
                                CustomDropdownCompact(
                                    selection: $selectedLanguage,
                                    options: languageOptions,
                                    display: languageDisplay
                                )
                                .padding(.bottom, 24)
                                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#D78C28"), action: {
                                    withAnimation { currentPage = 1 }
                                })
                                .accessibilityIdentifier("onboardingNextButton1")
                                .padding(.bottom, 100)
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
                                .frame(height: 450)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .padding(.bottom, 20)
                                .allowsHitTesting(false)
                                .padding(.top, 0)
                            Text("Fun Tasks & Real Rewards")
                                .frame(maxWidth: 700)
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
                                .lineLimit(nil)
                            Spacer()
                        }
                    } else {
                        // --- iPad layout start ---
                        VStack {
                            Spacer().frame(height: 72)
                            Image("mascot_reward")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 650)
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
                                .lineLimit(nil)
                            Spacer()
                            ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7F9BAD"), action: {
                                withAnimation { currentPage = 2 }
                            })
                            .accessibilityIdentifier("onboardingNextButton2")
                            .padding(.bottom, 64)
                        }
                        // --- iPad layout end ---
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
                                    .frame(width: 250)
                                    .offset(x: 0, y: 50)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .bottom)
                                    .alignmentGuide(.bottom) { d in d[.bottom] }
                            }
                            VStack(spacing: 0) {
                                Spacer().frame(height: 300)
                                Text("Set Rules That Match Your Family's Values")
                                    .font(.custom("Inter-Regular_SemiBold", size: 32))
                                    .frame(maxWidth: 700)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                    .padding(.bottom, 16)
                                Text("Choose from a curated collection of mindful rules—designed to guide your family with clarity and kindness.")
                                    .font(.custom("Inter-Regular_Medium", size: 20))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .frame(maxWidth: 500)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                Spacer()
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
                            // Background illustrations
                            VStack(spacing: 0) {
                                Image("on_3a")
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .scaledToFill()
                                    .frame(height: 400)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .top)
                                    .allowsHitTesting(false)
                                Spacer()
                                Image("on_3b")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 800)
                                    .offset(x: 300, y: 24)
                                    .opacity(1.0)
                                    .ignoresSafeArea(edges: .bottom)
                                    .alignmentGuide(.bottom) { d in d[.bottom] }
                            }
                            // Foreground: text and button
                            VStack(spacing: 0) {
                                Spacer().frame(height: 500)
                                Text("Set Rules That Match Your Family's Values")
                                    .font(.custom("Inter-Regular_SemiBold", size: 40))
                                    .frame(maxWidth: 700)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                    .padding(.bottom, 16)
                                Text("Choose from a curated collection of mindful rules—designed to guide your family with clarity and kindness.")
                                    .font(.custom("Inter-Regular_Medium", size: 20))
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .frame(maxWidth: 500)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                Spacer()
                                ButtonLarge(iconName: "icon_next", iconColor: Color(hex: "#7FAD98"), action: {
                                    withAnimation { currentPage = 3 }
                                })
                                .accessibilityIdentifier("onboardingNextButton3")
                                .padding(.bottom, 100)
                            }
                        }
                    }
                }
                .tag(2)
                // Screen 4: Login
                ZStack {
                    Color(hex: "#91A9B9").ignoresSafeArea()
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.0), .white.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()
                    LoginView(onLogin: { uid in
                        onLoginSuccess(uid)
                    })
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            .onChange(of: horizontalSizeClass) { _ in
                hasTriggeredAutoAdvance = false
            }
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
