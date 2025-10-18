import Foundation
import SwiftData

@Model
class User {
    var id: UUID
    var name: String
    var dailyGoal: Double
    var preferredUnit: WaterUnit
    var streakCount: Int
    var language: String
    var reminderEnabled: Bool
    var reminderInterval: TimeInterval
    var startTime: Date
    var endTime: Date
    var reminderTime: Date // Specific time for daily notification
    var profileImageData: Data?
    var createdDate: Date
    var lastActiveDate: Date

    init(
        id: UUID = UUID(),
        name: String = NSLocalizedString("user.default_name", value: "User", comment: ""),
        dailyGoal: Double = 2000.0,
        preferredUnit: WaterUnit = .milliliters,
        streakCount: Int = 0,
        language: String = "en",
        reminderEnabled: Bool = true,
        reminderInterval: TimeInterval = 3600, // 1 hour
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date(),
        endTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
        reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(), // 9:00 AM
        profileImageData: Data? = nil,
        createdDate: Date = Date(),
        lastActiveDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dailyGoal = dailyGoal
        self.preferredUnit = preferredUnit
        self.streakCount = streakCount
        self.language = language
        self.reminderEnabled = reminderEnabled
        self.reminderInterval = reminderInterval
        self.startTime = startTime
        self.endTime = endTime
        self.reminderTime = reminderTime
        self.profileImageData = profileImageData
        self.createdDate = createdDate
        self.lastActiveDate = lastActiveDate
    }

    // MARK: - Computed Properties

    var formattedDailyGoal: String {
        return String(format: "%.0f %@", dailyGoal, preferredUnit.symbol)
    }

    var isNewUser: Bool {
        return Calendar.current.isDateInToday(createdDate)
    }

    // MARK: - Helper Methods

    func dailyGoalInUnit(_ unit: WaterUnit) -> Double {
        return unit.convert(from: preferredUnit, amount: dailyGoal)
    }

    func updateLastActiveDate() {
        lastActiveDate = Date()
    }

    func incrementStreak() {
        streakCount += 1
    }

    func resetStreak() {
        streakCount = 0
    }

    func shouldShowReminder(at date: Date) -> Bool {
        guard reminderEnabled else { return false }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let startHour = calendar.component(.hour, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)

        return hour >= startHour && hour <= endHour
    }
}