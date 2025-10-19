import Foundation

class ConfettiTracker {

    static let shared = ConfettiTracker()

    private let userDefaults = UserDefaults.standard
    private let confettiDateKey = "lastConfettiShownDate"
    private let confettiIntakeKey = "lastConfettiShownIntake"

    private init() {}

    /// Check if confetti should be shown for goal completion
    /// - Parameter currentIntake: The current total water intake in ml
    /// - Returns: True if confetti should be shown
    func shouldShowConfetti(currentIntake: Double) -> Bool {
        guard let lastShownDate = userDefaults.object(forKey: confettiDateKey) as? Date else {
            return true
        }

        // If it's a different day, always show confetti
        if !Calendar.current.isDateInToday(lastShownDate) {
            return true
        }

        // Same day: only show if current intake is higher than last shown intake
        // This allows re-showing confetti if user dips below goal and re-achieves it
        let lastShownIntake = userDefaults.double(forKey: confettiIntakeKey)
        return currentIntake > lastShownIntake
    }

    /// Mark confetti as shown with the current intake amount
    /// - Parameter intake: The total water intake in ml when confetti was shown
    func markConfettiShown(intake: Double) {
        userDefaults.set(Date(), forKey: confettiDateKey)
        userDefaults.set(intake, forKey: confettiIntakeKey)
    }

    /// Reset the intake tracker if current intake is below the goal
    /// This allows confetti to show again when the user re-achieves the goal
    /// - Parameters:
    ///   - currentIntake: The current total water intake in ml
    ///   - goal: The daily water goal in ml
    func resetIfBelowGoal(currentIntake: Double, goal: Double) {
        guard currentIntake < goal else {
            return // Still at or above goal, don't reset
        }

        // User dropped below goal, reset the intake tracker
        // This allows confetti to show when they reach the goal again
        userDefaults.set(0, forKey: confettiIntakeKey)
    }

    /// Reset confetti state (useful for testing)
    func reset() {
        userDefaults.removeObject(forKey: confettiDateKey)
        userDefaults.removeObject(forKey: confettiIntakeKey)
    }
}
