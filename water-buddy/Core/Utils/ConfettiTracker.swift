import Foundation

class ConfettiTracker {

    static let shared = ConfettiTracker()

    private let userDefaults = UserDefaults.standard
    private let confettiDateKey = "lastConfettiShownDate"

    private init() {}

    /// Check if confetti should be shown for today's goal completion
    var shouldShowConfetti: Bool {
        guard let lastShownDate = userDefaults.object(forKey: confettiDateKey) as? Date else {
            return true
        }

        return !Calendar.current.isDateInToday(lastShownDate)
    }

    /// Mark confetti as shown for today
    func markConfettiShown() {
        userDefaults.set(Date(), forKey: confettiDateKey)
    }

    /// Reset confetti state (useful for testing)
    func reset() {
        userDefaults.removeObject(forKey: confettiDateKey)
    }
}
