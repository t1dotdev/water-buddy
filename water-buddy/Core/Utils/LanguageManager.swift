import Foundation

class LanguageManager {
    static let shared = LanguageManager()

    private let userDefaults = UserDefaults.standard
    private let languageKey = "app_language"

    // Current app language
    private(set) var currentLanguage: String

    // Notification name for language changes
    static let languageDidChangeNotification = Notification.Name("LanguageDidChange")

    private init() {
        // Initialize with saved language or default to English
        self.currentLanguage = userDefaults.string(forKey: languageKey) ?? "en"
        print("🌐 LanguageManager initialized with language: \(currentLanguage)")
    }

    // Get the bundle for the current language
    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("⚠️ Failed to load bundle for language: \(currentLanguage), falling back to main bundle")
            return Bundle.main
        }
        return bundle
    }

    // Set new language
    func setLanguage(_ languageCode: String) {
        guard languageCode != currentLanguage else {
            print("🌐 Language already set to: \(languageCode)")
            return
        }

        // Verify the language bundle exists
        guard Bundle.main.path(forResource: languageCode, ofType: "lproj") != nil else {
            print("❌ Language bundle not found for: \(languageCode)")
            return
        }

        print("🌐 Changing language from \(currentLanguage) to \(languageCode)")
        currentLanguage = languageCode
        userDefaults.set(languageCode, forKey: languageKey)
        userDefaults.synchronize()

        // Post notification for language change
        NotificationCenter.default.post(name: LanguageManager.languageDidChangeNotification, object: nil)
        print("✅ Language changed to: \(currentLanguage)")
    }

    // Get localized string
    func localizedString(forKey key: String, value: String? = nil, comment: String = "") -> String {
        return bundle.localizedString(forKey: key, value: value, table: nil)
    }

    // Initialize with user's saved language preference
    func initializeWithUserLanguage(_ userLanguage: String?) {
        guard let userLanguage = userLanguage else { return }

        // Only set if different from current
        if userLanguage != currentLanguage {
            print("🌐 Initializing language from user preference: \(userLanguage)")
            currentLanguage = userLanguage
            userDefaults.set(userLanguage, forKey: languageKey)
            userDefaults.synchronize()
        }
    }
}
