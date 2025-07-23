import SwiftUI

struct LanguageSelector: View {
    @Binding var selectedLanguage: String
    let context: LanguageSelectorContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showLanguageSheet = false

    
    enum LanguageSelectorContext {
        case onboarding
        case settings
    }
    
    private var languages: [String: String] {
        [
            "en": NSLocalizedString("English", tableName: nil, bundle: Bundle.main, value: "", comment: ""),
            "nl": NSLocalizedString("Nederlands", tableName: nil, bundle: Bundle.main, value: "", comment: "")
        ]
    }
    
    private var textColor: Color {
        switch context {
        case .onboarding:
            return .white
        case .settings:
            return Color(hex: "#7FAD98")
        }
    }
    
    private var fontSize: CGFloat {
        switch context {
        case .onboarding:
            return horizontalSizeClass == .compact ? 18 : 24
        case .settings:
            return horizontalSizeClass == .compact ? 17 : 24
        }
    }
    
    private var iconSize: CGFloat {
        switch context {
        case .onboarding:
            return horizontalSizeClass == .compact ? 20 : 24
        case .settings:
            return horizontalSizeClass == .compact ? 20 : 24
        }
    }
    
    private var minHeight: CGFloat {
        switch context {
        case .onboarding:
            return horizontalSizeClass == .compact ? 44 : 56
        case .settings:
            return horizontalSizeClass == .compact ? 44 : 56
        }
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone: Use Menu (small dropdown)
                iPhoneLanguageSelector
            } else {
                // iPad: Use Button that shows sheet (larger interface)
                iPadLanguageSelector
            }
        }
        .onAppear {
            selectedLanguage = LocalizationManager.shared.currentLanguage
        }
        .onChange(of: LocalizationManager.shared.currentLanguage) { newLang in
            selectedLanguage = newLang
        }
    }
    
    // iPhone version (Menu dropdown)
    private var iPhoneLanguageSelector: some View {
        Menu {
            ForEach(Array(languages.keys.sorted()), id: \.self) { langCode in
                Button(action: {
                    selectedLanguage = langCode
                    LocalizationManager.shared.setLanguage(langCode)
                }) {
                    HStack {
                        Text(languages[langCode] ?? langCode)
                    }
                }
            }
        } label: {
            HStack {
                if context == .settings {
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    Image("icon_globe")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(textColor)
                    
                    Text(languages[selectedLanguage] ?? selectedLanguage)
                        .font(.custom("Inter-Regular", size: fontSize))
                        .foregroundColor(textColor)
                    
                    if context == .onboarding {
                        Image("icon_she")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(textColor)
                    }
                    
                    if context == .settings {
                        Image("icon_she")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(textColor)
                    }
                }
                .frame(maxWidth: context == .onboarding ? nil : .infinity, alignment: context == .settings ? .trailing : .leading)
                .frame(minHeight: minHeight)
                .padding(.horizontal, context == .onboarding ? 16 : 0)
            }
        }
    }
    
    // iPad version (Button with sheet and icon_globe)
    private var iPadLanguageSelector: some View {
        Button(action: {
            showLanguageSheet = true
        }) {
            HStack {
                if context == .settings {
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Image("icon_globe")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(textColor)
                    
                    Text(languages[selectedLanguage] ?? selectedLanguage)
                        .font(.custom("Inter-Regular_Medium", size: 24))
                        .foregroundColor(textColor)
                    
                    if context == .onboarding {
                        Image("icon_she")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(textColor)
                    }
                    
                    if context == .settings {
                        Image("icon_she")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(textColor)
                    }
                }
                .frame(maxWidth: context == .onboarding ? nil : .infinity, alignment: context == .settings ? .trailing : .leading)
                .frame(minHeight: 64)
                .padding(.horizontal, context == .onboarding ? 20 : 0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showLanguageSheet) {
            iPadLanguageSelectionSheet(
                selectedLanguage: $selectedLanguage,
                languages: languages,
                context: context
            )
        }
    }
}

// iPad-specific language selection sheet
struct iPadLanguageSelectionSheet: View {
    @Binding var selectedLanguage: String
    let languages: [String: String]
    let context: LanguageSelector.LanguageSelectorContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(languages.keys.sorted()), id: \.self) { langCode in
                Button(action: {
                    selectedLanguage = langCode
                    LocalizationManager.shared.setLanguage(langCode)
                    dismiss()
                }) {
                    HStack {
                        Text(languages[langCode] ?? langCode)
                            .font(.custom("Inter-Regular_Medium", size: 24))
                            .foregroundColor(Color(hex: "#799B44"))
                        
                        Spacer()
                        
                        if selectedLanguage == langCode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#799B44"))
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                if langCode != languages.keys.sorted().last {
                    Divider()
                        .padding(.horizontal, 24)
                }
            }
        }
        .background(Color.white)
        .presentationDetents([.height(CGFloat(languages.count) * 64 + 16)])
    }
}

#Preview {
    VStack(spacing: 20) {
        // Onboarding context
        LanguageSelector(selectedLanguage: .constant("en"), context: .onboarding)
            .background(Color.blue)
            .padding()
        
        // Settings context
        LanguageSelector(selectedLanguage: .constant("nl"), context: .settings)
            .padding()
    }
} 