import Foundation

protocol UserRepositoryProtocol {
    func getUser() async throws -> User
    func saveUser(_ user: User) async throws
    func updateDailyGoal(_ goal: Double) async throws
    func updatePreferredUnit(_ unit: WaterUnit) async throws
    func updateName(_ name: String) async throws
    func updateLanguage(_ language: String) async throws
    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws
    func updateDailyReminderSettings(enabled: Bool, time: Date) async throws
    func updateStreakCount(_ count: Int) async throws
    func updateProfileImage(_ imageData: Data?) async throws
    func resetUserData() async throws
    func updateLastActiveDate() async throws
    func incrementStreak() async throws
    func resetStreak() async throws
}