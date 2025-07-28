import SwiftUI

struct OnboardingView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("shouldShowAdminAfterOnboarding") var shouldShowAdminAfterOnboarding: Bool = false
    @EnvironmentObject var onboardingState: OnboardingStateManager
    @State private var userId: String = ""
    @EnvironmentObject var tipjeStore: TipjeStore
    @EnvironmentObject var authManager: AuthManager
    var isStage1: Bool // True for intro/login, False for kids/PIN setup
    @State private var currentPage = 0
    @State private var showRegistration: Bool = false
    @State private var showLogin: Bool = false
    @State private var showSubscription: Bool = false

    init(isStage1: Bool = true) {
        self.isStage1 = isStage1
    }

    var body: some View {
#if DEBUG
        VStack {
            Button("Expire Trial (DEBUG)") {
                onboardingState.trialStartDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.red)
            .font(.caption)
            .zIndex(100)
            // Only show in DEBUG
            Spacer(minLength: 0)
        }
#endif
        if isStage1 {
            // Stage 1: Intro slides and login in TabView, then subscription
            if !onboardingState.didLogin {
                OnboardingSlidesAndLoginView(onLoginSuccess: { uid in
                    Task {
                        onboardingState.reset()
                    userId = uid
                        tipjeStore.setUser(userId: uid)
                    onboardingState.userId = uid
                        onboardingState.didLogin = true
                        await StoreKitManager.shared.refreshSubscriptionStatus()
                        onboardingState.hasActiveSubscription = StoreKitManager.shared.isSubscribed
                        onboardingState.refreshState(for: uid)
                    }
                })
            } else if onboardingState.isInTrialPeriod {
                // During trial, skip paywall and StoreKit, allow full access
                OnboardingView(isStage1: false)
                    .environmentObject(onboardingState)
                    .environmentObject(tipjeStore)
                    .environmentObject(authManager)
            } else if !onboardingState.hasActiveSubscription {
                SubscriptionView(onPlanSelected: { plan in
                    Task {
                        await StoreKitManager.shared.refreshSubscriptionStatus()
                        onboardingState.hasActiveSubscription = StoreKitManager.shared.isSubscribed
                        onboardingState.refreshState(for: onboardingState.userId)
                }
                })
            } else {
                // Proceed to next onboarding stage
                OnboardingView(isStage1: false)
                    .environmentObject(onboardingState)
                    .environmentObject(tipjeStore)
                    .environmentObject(authManager)
            }
        } else {
            // Stage 2: Kids profile, PIN setup, admin cards based on onboarding flags
            Group {
                if onboardingState.needsKidsProfile {
                    KidsProfileView(userId: onboardingState.userId) {
                        onboardingState.refreshState(for: onboardingState.userId)
                    } onLoginRequest: {
                        authManager.signOut()
                    }
                } else if onboardingState.needsPinSetup {
                    PinSetupView(userId: onboardingState.userId) {
                        onboardingState.refreshState(for: onboardingState.userId)
                    }
                } else if onboardingState.needsCardsSetup {
                    AdminView(onComplete: {
                        onboardingState.refreshState(for: onboardingState.userId)
                    })
                    .environmentObject(tipjeStore)
                } else {
                    // Onboarding complete, transition to main app
                    EmptyView()
                }
            }
        }
    }
}

struct OnboardingSlidesAndLoginView: View {
    var onLoginSuccess: (String) -> Void
    @State private var currentPage = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedLanguage = LocalizationManager.shared.currentLanguage
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                onboardingScreen1.tag(0)
                onboardingScreen2.tag(1)
                onboardingScreen3.tag(2)
                LoginView(onLogin: { uid in
                    onLoginSuccess(uid)
                }).tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            .onChange(of: currentPage) { newValue in
                if newValue > 3 {
                    currentPage = 3 // Snap back if user tries to swipe past
                }
            }
            // Remove the old language selector since it's now below the logo
        }
    }
    
    // --- Modular onboarding screens for compiler performance and maintainability ---
    private var onboardingScreen1: some View {
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
                    
                    // Language selector below logo
                    LanguageSelector(selectedLanguage: $selectedLanguage, context: .onboarding)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .accessibilityIdentifier("languageSelector")
                    
                    Spacer(minLength: 0)
                    Image("on_2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.bottom, 0)
                    LocalizedText("onboarding_title_iphone")
                        .font(.custom("Inter-Regular_SemiBold", size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(.bottom, 16)
                    LocalizedText("onboarding_subtitle_iphone")
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
                        
                        // Language selector below logo for iPad
                        LanguageSelector(selectedLanguage: $selectedLanguage, context: .onboarding)
                            .padding(.horizontal, 48)
                            .padding(.top, 24)
                            .accessibilityIdentifier("languageSelector")
                        
                        Spacer().frame(height: 100)
                        Image("on_2")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1.6)
                            .frame(height: 300)
                            .padding(.bottom, 16)
                            .allowsHitTesting(false)
                        Spacer().frame(height: 100)
                        LocalizedText("onboarding_title_ipad")
                            .font(.custom("Inter-Regular_SemiBold", size: 46))
                            .frame(maxWidth: 600)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .padding(.bottom, 16)
                        LocalizedText("onboarding_subtitle_ipad")
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: 600)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                    .padding(.bottom, 80)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
    private var onboardingScreen2: some View {
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
                    LocalizedText("onboarding2_title")
                        .frame(maxWidth: 700)
                        .font(.custom("Inter-Regular_SemiBold", size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 16)
                    LocalizedText("onboarding2_subtitle")
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
                        .frame(height: 700)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 32)
                        .allowsHitTesting(false)
                        .padding(.top, 60)
                    LocalizedText("onboarding2_title")
                        .font(.custom("Inter-Regular_SemiBold", size: 46))
                        .frame(maxWidth: 600)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().frame(height: 16)
                    LocalizedText("onboarding2_subtitle")
                        .font(.custom("Inter-Regular_Medium", size: 24))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxWidth: 600)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                    Spacer()
                }
                // --- iPad layout end ---
            }
        }
    }
    private var onboardingScreen3: some View {
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
                        LocalizedText("onboarding3_title")
                            .font(.custom("Inter-Regular_SemiBold", size: 32))
                            .frame(maxWidth: 700)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .padding(.bottom, 16)
                        LocalizedText("onboarding3_subtitle")
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
                            .offset(x: 280, y: 24)
                            .opacity(1.0)
                            .ignoresSafeArea(edges: .bottom)
                            .alignmentGuide(.bottom) { d in d[.bottom] }
                    }
                    // Foreground: text and button
                    VStack(spacing: 0) {
                        Spacer().frame(height: 480)
                        LocalizedText("onboarding3_title")
                            .font(.custom("Inter-Regular_SemiBold", size: 46))
                            .frame(maxWidth: 600)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .padding(.bottom, 16)
                            .padding(.top,32)
                        LocalizedText("onboarding3_subtitle")
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: 600)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                }
            }
        }
    }
    private var onboardingScreen4: some View {
        // (Screen 4 content here, or leave empty if not needed)
        EmptyView()
    }
    private var onboardingScreen5: some View {
        // ... (move all code for screen 5 here)
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
    }
    private func startPurchase(for plan: Plan) {
        // TODO: Implement StoreKit purchase logic here
        print("[Onboarding] Would start purchase for plan: \(plan)")
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
