import UIKit

class FontManager {
    static let shared = FontManager()

    private init() {}

    // MARK: - Font Names
    enum FontType: String, CaseIterable {
        case regular = "SF Pro Display"
        case medium = "SF Pro Display Medium"
        case semibold = "SF Pro Display Semibold"
        case bold = "SF Pro Display Bold"
        case numeric = "SF Mono" // For numbers and amounts

        var name: String {
            return rawValue
        }
    }

    // MARK: - Font Sizes
    enum FontSize: CGFloat {
        case largeTitle = 34
        case title1 = 28
        case title2 = 22
        case title3 = 20
        case headline = 17
        case body = 17.5
        case callout = 16
        case subheadline = 15
        case footnote = 13
        case caption1 = 12
        case caption2 = 11

        // Custom sizes for water tracking
        case waterAmount = 32
        case dailyGoal = 24
        case quickAdd = 18
    }

    // MARK: - Public Methods
    func font(type: FontType, size: FontSize) -> UIFont {
        return font(name: type.name, size: size.rawValue)
    }

    func font(name: String, size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: name, size: size) {
            return customFont
        }
        // Fallback to system font
        return UIFont.systemFont(ofSize: size)
    }

    // MARK: - Predefined Fonts
    var largeTitle: UIFont {
        return font(type: .bold, size: .largeTitle)
    }

    var title1: UIFont {
        return font(type: .bold, size: .title1)
    }

    var title2: UIFont {
        return font(type: .bold, size: .title2)
    }

    var title3: UIFont {
        return font(type: .semibold, size: .title3)
    }

    var headline: UIFont {
        return font(type: .semibold, size: .headline)
    }

    var body: UIFont {
        return font(type: .regular, size: .body)
    }

    var callout: UIFont {
        return font(type: .regular, size: .callout)
    }

    var subheadline: UIFont {
        return font(type: .regular, size: .subheadline)
    }

    var footnote: UIFont {
        return font(type: .regular, size: .footnote)
    }

    var caption1: UIFont {
        return font(type: .regular, size: .caption1)
    }

    var caption2: UIFont {
        return font(type: .regular, size: .caption2)
    }

    // Custom fonts for water tracking
    var waterAmount: UIFont {
        return font(type: .numeric, size: .waterAmount)
    }

    var dailyGoal: UIFont {
        return font(type: .semibold, size: .dailyGoal)
    }

    var quickAddButton: UIFont {
        return font(type: .medium, size: .quickAdd)
    }

    // MARK: - Dynamic Type Support
    func scaledFont(type: FontType, size: FontSize, textStyle: UIFont.TextStyle = .body) -> UIFont {
        let baseFont = font(type: type, size: size)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
    }
}

// MARK: - UIFont Extensions
extension UIFont {
    static func waterAmount() -> UIFont {
        return FontManager.shared.waterAmount
    }

    static func dailyGoal() -> UIFont {
        return FontManager.shared.dailyGoal
    }

    static func quickAddButton() -> UIFont {
        return FontManager.shared.quickAddButton
    }
}