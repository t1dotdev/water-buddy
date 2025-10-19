import UIKit

struct Constants {

    // MARK: - Colors
    struct Colors {
        static let primaryBlue = UIColor.systemBlue
        static let secondaryBlue = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.3)
        static let waterBlue = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        static let lightBlue = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)

        static let success = UIColor.systemGreen
        static let warning = UIColor.systemOrange
        static let error = UIColor.systemRed

        static let backgroundPrimary = UIColor.systemBackground
        static let backgroundSecondary = UIColor.secondarySystemBackground
        static let backgroundTertiary = UIColor.tertiarySystemBackground

        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel

        static let separator = UIColor.separator
        static let shadow = UIColor.black.withAlphaComponent(0.1)
    }

    // MARK: - Dimensions
    struct Dimensions {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let cellHeight: CGFloat = 60

        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 16
        static let paddingLarge: CGFloat = 24
        static let paddingExtraLarge: CGFloat = 32

        static let marginSmall: CGFloat = 8
        static let marginMedium: CGFloat = 16
        static let marginLarge: CGFloat = 24

        static let progressCircleSize: CGFloat = 220
        static let quickAddButtonSize: CGFloat = 85
        static let containerImageSize: CGFloat = 60
    }

    // MARK: - Animation
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let fastDuration: TimeInterval = 0.15
        static let slowDuration: TimeInterval = 0.6

        static let bounceScale: CGFloat = 1.1
        static let pressedScale: CGFloat = 0.95

        static let waterFillDuration: TimeInterval = 1.0
    }

    // MARK: - Water Buddy
    struct WaterBuddy {
        static let defaultDailyGoal: Double = 2000.0 // ml
        static let minAmount: Double = 1.0
        static let maxAmount: Double = 5000.0

        // Quick add amounts in milliliters
        static let quickAddAmountsML: [Double] = [100, 250, 500, 750, 1000]

        // Quick add amounts in ounces (common bottle sizes)
        static let quickAddAmountsOZ: [Double] = [4, 8, 12, 16, 20]

        // Legacy property for backward compatibility
        static let quickAddAmounts: [Double] = quickAddAmountsML

        static let defaultReminderInterval: TimeInterval = 3600 // 1 hour
        static let minReminderInterval: TimeInterval = 1800 // 30 minutes
        static let maxReminderInterval: TimeInterval = 28800 // 8 hours

        // Get quick add amounts for a specific unit (returns amounts in milliliters)
        static func getQuickAddAmounts(for unit: WaterUnit) -> [Double] {
            switch unit {
            case .milliliters:
                return quickAddAmountsML
            case .ounces:
                // Convert oz amounts to ml for storage
                return quickAddAmountsOZ.map { $0 * 29.5735 }
            }
        }

        // Get display amounts for a specific unit (for showing in UI)
        static func getDisplayAmounts(for unit: WaterUnit) -> [Double] {
            switch unit {
            case .milliliters:
                return quickAddAmountsML
            case .ounces:
                return quickAddAmountsOZ
            }
        }
    }

    // MARK: - Tab Bar
    struct TabBar {
        enum Tab: Int, CaseIterable {
            case home = 0
            case statistics = 1
            case addWater = 2
            case history = 3
            case settings = 4

            var title: String {
                switch self {
                case .home:
                    return NSLocalizedString("tab.home", value: "Home", comment: "")
                case .statistics:
                    return NSLocalizedString("tab.statistics", value: "Stats", comment: "")
                case .addWater:
                    return NSLocalizedString("tab.add_water", value: "Add Water", comment: "")
                case .history:
                    return NSLocalizedString("tab.history", value: "History", comment: "")
                case .settings:
                    return NSLocalizedString("tab.settings", value: "Settings", comment: "")
                }
            }

            var systemImageName: String {
                switch self {
                case .home:
                    return "house"
                case .statistics:
                    return "chart.bar"
                case .addWater:
                    return "plus.circle.fill"
                case .history:
                    return "clock"
                case .settings:
                    return "gear"
                }
            }
        }
    }

    // MARK: - Images
    struct Images {
        static let placeholderProfile = "person.circle.fill"
        static let waterDrop = "drop.fill"
        static let goal = "target"
        static let streak = "flame.fill"
        static let weather = "cloud.sun.fill"
        static let reminder = "bell.fill"
        static let export = "square.and.arrow.up"
        static let delete = "trash"
        static let edit = "pencil"
        static let checkmark = "checkmark.circle.fill"
    }

    // MARK: - URLs
    struct URLs {
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
        static let support = "mailto:support@example.com"
    }

    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let user = "current_user"
        static let waterEntries = "water_entries"
        static let hasLaunchedBefore = "has_launched_before"
        static let selectedLanguage = "selected_language"
        static let notificationsEnabled = "notifications_enabled"
    }
}