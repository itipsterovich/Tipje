import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @Published var currentLanguage: String {
        didSet {
            selectedLanguage = currentLanguage
        }
    }
    
    private init() {
        self.currentLanguage = selectedLanguage
    }
    
    let supportedLanguages = [
        Language(id: "en", name: "English", code: "en"),
        Language(id: "nl", name: "Nederlands", code: "nl"),
        Language(id: "fr", name: "Français", code: "fr"),
        Language(id: "de", name: "Deutsch", code: "de"),
        Language(id: "es", name: "Español", code: "es"),
        Language(id: "it", name: "Italiano", code: "it"),
        Language(id: "pt", name: "Português", code: "pt"),
        Language(id: "ru", name: "Русский", code: "ru"),
        Language(id: "ja", name: "日本語", code: "ja"),
        Language(id: "ko", name: "한국어", code: "ko"),
        Language(id: "zh-Hans", name: "简体中文", code: "zh-Hans"),
        Language(id: "zh-Hant", name: "繁體中文", code: "zh-Hant"),
        Language(id: "ar", name: "العربية", code: "ar"),
        Language(id: "hi", name: "हिन्दी", code: "hi"),
        Language(id: "tr", name: "Türkçe", code: "tr"),
        Language(id: "pl", name: "Polski", code: "pl"),
        Language(id: "vi", name: "Tiếng Việt", code: "vi"),
        Language(id: "th", name: "ไทย", code: "th"),
        Language(id: "id", name: "Bahasa Indonesia", code: "id"),
        Language(id: "ms", name: "Bahasa Melayu", code: "ms")
    ]
    
    func getCurrentLanguageName() -> String {
        return supportedLanguages.first { $0.code == currentLanguage }?.name ?? "English"
    }
    
    func setLanguage(_ code: String) {
        guard currentLanguage != code,
              supportedLanguages.contains(where: { $0.code == code }) else {
            return
        }
        
        currentLanguage = code
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

struct Language: Identifiable {
    let id: String
    let name: String
    let code: String
} 