import Foundation

class UserRepository: UserRepositoryProtocol {
    private let userDefaultsDataSource: UserDefaultsDataSource
    private let userKey = "current_user"

    init(userDefaultsDataSource: UserDefaultsDataSource) {
        self.userDefaultsDataSource = userDefaultsDataSource
    }

    func getUser() async throws -> User {
        // Try safe loading first
        if let user = userDefaultsDataSource.loadSafely(User.self, forKey: userKey) {
            return user
        }
        
        // If no user or corrupted data, create default user
        let defaultUser = User()
        try await saveUser(defaultUser)
        return defaultUser
    }

    func saveUser(_ user: User) async throws {
        try userDefaultsDataSource.save(user, forKey: userKey)
    }

    func updateDailyGoal(_ goal: Double) async throws {
        var user = try await getUser()
        user.dailyGoal = goal
        try await saveUser(user)
    }

    func updatePreferredUnit(_ unit: WaterUnit) async throws {
        var user = try await getUser()
        user.preferredUnit = unit
        try await saveUser(user)
    }

    func updateName(_ name: String) async throws {
        var user = try await getUser()
        user.name = name
        try await saveUser(user)
    }

    func updateLanguage(_ language: String) async throws {
        var user = try await getUser()
        user.language = language
        try await saveUser(user)

        // Update app language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws {
        var user = try await getUser()
        user.reminderEnabled = enabled
        user.reminderInterval = interval
        user.startTime = startTime
        user.endTime = endTime
        try await saveUser(user)
    }

    func updateStreakCount(_ count: Int) async throws {
        var user = try await getUser()
        user.streakCount = count
        try await saveUser(user)
    }

    func updateProfileImage(_ imageData: Data?) async throws {
        var user = try await getUser()
        user.profileImageData = imageData
        try await saveUser(user)
    }

    func resetUserData() async throws {
        let defaultUser = User()
        try await saveUser(defaultUser)
    }

    func updateLastActiveDate() async throws {
        var user = try await getUser()
        user.updateLastActiveDate()
        try await saveUser(user)
    }

    func incrementStreak() async throws {
        var user = try await getUser()
        user.incrementStreak()
        try await saveUser(user)
    }

    func resetStreak() async throws {
        var user = try await getUser()
        user.resetStreak()
        try await saveUser(user)
    }
}