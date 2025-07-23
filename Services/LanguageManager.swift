import Foundation
import SwiftUI
import ObjectiveC

private var bundleKey: UInt8 = 0

final class LocalizedBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static let once: Void = { object_setClass(Bundle.main, type(of: LocalizedBundle())) }()
    static func setLanguage(_ language: String) {
        Bundle.once
        let isBase = (language == "en") // or your default
        let path = isBase ? Bundle.main.path(forResource: "en", ofType: "lproj") : Bundle.main.path(forResource: language, ofType: "lproj")
        objc_setAssociatedObject(Bundle.main, &bundleKey, path, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            Bundle.setLanguage(currentLanguage)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    private init() {
        if let lang = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = lang
        } else {
            currentLanguage = Locale.current.languageCode ?? "en"
        }
        Bundle.setLanguage(currentLanguage)
    }
    func setLanguage(_ lang: String) {
        guard lang != currentLanguage else { return }
        currentLanguage = lang
        Bundle.setLanguage(lang)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
} 