import Foundation

protocol UpdateUserDataUseCase {
    func updateDailyGoal(_ goal: Double) async throws
    func updatePreferredUnit(_ unit: WaterUnit) async throws
    func updateName(_ name: String) async throws
    func updateLanguage(_ language: String) async throws
    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws
    func updateProfileImage(_ imageData: Data?) async throws
    func resetAllData() async throws
}

class UpdateUserDataUseCaseImpl: UpdateUserDataUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func updateDailyGoal(_ goal: Double) async throws {
        guard goal > 0 && goal <= 10000 else {
            throw WaterBuddyError.invalidAmount
        }
        try await userRepository.updateDailyGoal(goal)
    }

    func updatePreferredUnit(_ unit: WaterUnit) async throws {
        try await userRepository.updatePreferredUnit(unit)
    }

    func updateName(_ name: String) async throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw UserDataError.invalidName
        }
        try await userRepository.updateName(name)
    }

    func updateLanguage(_ language: String) async throws {
        let supportedLanguages = ["en", "th"]
        guard supportedLanguages.contains(language) else {
            throw UserDataError.unsupportedLanguage
        }
        try await userRepository.updateLanguage(language)
    }

    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws {
        // Validate time range
        guard startTime < endTime else {
            throw UserDataError.invalidTimeRange
        }

        // Validate interval (should be between 30 minutes and 8 hours)
        guard interval >= 1800 && interval <= 28800 else {
            throw UserDataError.invalidInterval
        }

        try await userRepository.updateReminderSettings(
            enabled: enabled,
            interval: interval,
            startTime: startTime,
            endTime: endTime
        )
    }

    func updateProfileImage(_ imageData: Data?) async throws {
        // Validate image data size if provided (max 5MB)
        if let data = imageData, data.count > 5 * 1024 * 1024 {
            throw UserDataError.imageTooLarge
        }
        try await userRepository.updateProfileImage(imageData)
    }

    func resetAllData() async throws {
        try await userRepository.resetUserData()
    }
}

enum UserDataError: Error, LocalizedError {
    case invalidName
    case unsupportedLanguage
    case invalidTimeRange
    case invalidInterval
    case imageTooLarge

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return NSLocalizedString("error.invalid_name", value: "Please enter a valid name", comment: "")
        case .unsupportedLanguage:
            return NSLocalizedString("error.unsupported_language", value: "Unsupported language", comment: "")
        case .invalidTimeRange:
            return NSLocalizedString("error.invalid_time_range", value: "Start time must be before end time", comment: "")
        case .invalidInterval:
            return NSLocalizedString("error.invalid_interval", value: "Reminder interval must be between 30 minutes and 8 hours", comment: "")
        case .imageTooLarge:
            return NSLocalizedString("error.image_too_large", value: "Image size must be less than 5MB", comment: "")
        }
    }
}