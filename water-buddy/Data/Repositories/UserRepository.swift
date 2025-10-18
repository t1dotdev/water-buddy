import Foundation
import SwiftData

@MainActor
class UserRepository: UserRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getUser() async throws -> User {
        // Fetch the first user from SwiftData
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)

        if let existingUser = users.first {
            print("📖 Loaded user from SwiftData. Daily goal: \(existingUser.dailyGoal)")
            return existingUser
        }

        // If no user exists, create default user
        print("⚠️ No user found. Creating default user with dailyGoal=2000.")
        let defaultUser = User()
        modelContext.insert(defaultUser)
        try modelContext.save()
        print("✅ Default user created and saved with SwiftData")
        return defaultUser
    }

    func saveUser(_ user: User) async throws {
        // SwiftData tracks changes automatically
        // Just save the context to persist any changes
        try modelContext.save()
        print("💾 User saved with SwiftData")
    }

    func updateDailyGoal(_ goal: Double) async throws {
        let user = try await getUser()
        print("📊 Current daily goal: \(user.dailyGoal), New daily goal: \(goal)")
        user.dailyGoal = goal
        try modelContext.save()
        print("✅ Daily goal updated to \(goal) and saved with SwiftData")
    }

    func updatePreferredUnit(_ unit: WaterUnit) async throws {
        let user = try await getUser()
        user.preferredUnit = unit
        try modelContext.save()
        print("✅ Preferred unit updated and saved")
    }

    func updateName(_ name: String) async throws {
        let user = try await getUser()
        user.name = name
        try modelContext.save()
        print("✅ Name updated and saved")
    }

    func updateLanguage(_ language: String) async throws {
        let user = try await getUser()
        user.language = language
        try modelContext.save()

        // Update app language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        print("✅ Language updated and saved")
    }

    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws {
        let user = try await getUser()
        user.reminderEnabled = enabled
        user.reminderInterval = interval
        user.startTime = startTime
        user.endTime = endTime
        try modelContext.save()
        print("✅ Reminder settings updated and saved")
    }

    func updateDailyReminderSettings(enabled: Bool, time: Date) async throws {
        let user = try await getUser()
        user.reminderEnabled = enabled
        user.reminderTime = time
        try modelContext.save()
        print("✅ Daily reminder settings updated - Enabled: \(enabled), Time: \(time)")
    }

    func updateStreakCount(_ count: Int) async throws {
        let user = try await getUser()
        user.streakCount = count
        try modelContext.save()
        print("✅ Streak count updated and saved")
    }

    func updateProfileImage(_ imageData: Data?) async throws {
        let user = try await getUser()
        user.profileImageData = imageData
        try modelContext.save()
        print("✅ Profile image updated and saved")
    }

    func resetUserData() async throws {
        // Delete existing user
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        users.forEach { modelContext.delete($0) }

        // Create new default user
        let defaultUser = User()
        modelContext.insert(defaultUser)
        try modelContext.save()
        print("✅ User data reset to defaults")
    }

    func updateLastActiveDate() async throws {
        let user = try await getUser()
        user.updateLastActiveDate()
        try modelContext.save()
        print("✅ Last active date updated")
    }

    func incrementStreak() async throws {
        let user = try await getUser()
        user.incrementStreak()
        try modelContext.save()
        print("✅ Streak incremented and saved")
    }

    func resetStreak() async throws {
        let user = try await getUser()
        user.resetStreak()
        try modelContext.save()
        print("✅ Streak reset and saved")
    }
}