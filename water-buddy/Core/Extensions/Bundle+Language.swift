import Foundation
import ObjectiveC

private var bundleKey: UInt8 = 0

extension Bundle {
    /// Set up bundle swizzling to make NSLocalizedString use LanguageManager's bundle
    static func setupLanguageBundle() {
        object_setClass(Bundle.main, LanguageBundle.self)
    }
}

/// Helper function to replace NSLocalizedString with language-aware version
/// Usage: localizedString("key", value: "Default", comment: "Comment")
func localizedString(_ key: String, value: String? = nil, comment: String = "") -> String {
    return LanguageManager.shared.localizedString(forKey: key, value: value, comment: comment)
}

/// Custom bundle class that uses LanguageManager for localization
private class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Use LanguageManager's bundle for localization
        if let languageBundle = LanguageManager.shared.bundle as? Bundle,
           languageBundle != Bundle.main {
            return languageBundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}
