import Foundation

protocol AddWaterUseCase {
    func execute(amount: Double, container: ContainerType) async throws -> WaterEntry
}

class AddWaterUseCaseImpl: AddWaterUseCase {
    private let waterRepository: WaterRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    init(
        waterRepository: WaterRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.waterRepository = waterRepository
        self.userRepository = userRepository
    }

    func execute(amount: Double, container: ContainerType) async throws -> WaterEntry {
        // Validate amount
        guard amount > 0 && amount <= 5000 else {
            throw WaterBuddyError.invalidAmount
        }

        // Get user preferences for unit
        let user = try await userRepository.getUser()

        // Get intake BEFORE adding water to detect goal completion
        let intakeBeforeAdding = try await waterRepository.getTotalIntakeForDate(Date())

        // Create water entry
        let entry = WaterEntry(
            amount: amount,
            unit: user.preferredUnit,
            containerType: container
        )

        // Save the entry
        try await waterRepository.addEntry(entry)

        // Update user's last active date
        try await userRepository.updateLastActiveDate()

        // Get intake AFTER adding water
        let intakeAfterAdding = try await waterRepository.getTotalIntakeForDate(Date())

        // Check if goal was just completed
        checkGoalCompletion(
            intakeBefore: intakeBeforeAdding,
            intakeAfter: intakeAfterAdding,
            goal: user.dailyGoal
        )

        // Check if daily goal is achieved and update streak
        try await updateStreakIfNeeded(user: user)

        return entry
    }

    private func checkGoalCompletion(intakeBefore: Double, intakeAfter: Double, goal: Double) {
        // Check if we just crossed the goal threshold
        if intakeBefore < goal && intakeAfter >= goal {
            // Post notification for goal completion on main thread (triggers UI updates)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("GoalCompletedNotification"),
                    object: nil,
                    userInfo: ["intake": intakeAfter]
                )
            }
        }
    }

    private func updateStreakIfNeeded(user: User) async throws {
        let calendar = Calendar.current
        let today = Date()

        // Get today's total intake
        let todayIntake = try await waterRepository.getTotalIntakeForDate(today)

        // Check if goal is achieved
        guard todayIntake >= user.dailyGoal else {
            return // Goal not achieved yet
        }

        // Check if we already updated streak today
        if let lastUpdate = user.lastStreakUpdateDate,
           calendar.isDate(lastUpdate, inSameDayAs: today) {
            return // Already updated today
        }

        // Check if this is a consecutive day
        if let lastUpdate = user.lastStreakUpdateDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            if calendar.isDate(lastUpdate, inSameDayAs: yesterday) {
                // Consecutive day - increment streak
                try await userRepository.incrementStreak()
            } else if calendar.isDate(lastUpdate, inSameDayAs: today) {
                // Already updated today - do nothing
                return
            } else {
                // Missed days - reset streak to 1
                try await userRepository.updateStreakCount(1)
            }
        } else {
            // First time achieving goal - set streak to 1
            try await userRepository.updateStreakCount(1)
        }
    }
}

enum WaterBuddyError: Error, LocalizedError {
    case invalidAmount
    case dataNotFound
    case saveFailed
    case networkError
    case invalidUser
    case dataCorrupted

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return NSLocalizedString("error.invalid_amount", value: "Please enter a valid amount between 1-5000ml", comment: "")
        case .dataNotFound:
            return NSLocalizedString("error.data_not_found", value: "Data not found", comment: "")
        case .saveFailed:
            return NSLocalizedString("error.save_failed", value: "Failed to save data", comment: "")
        case .networkError:
            return NSLocalizedString("error.network", value: "Network error occurred", comment: "")
        case .invalidUser:
            return NSLocalizedString("error.invalid_user", value: "Invalid user data", comment: "")
        case .dataCorrupted:
            return NSLocalizedString("error.data_corrupted", value: "Data is corrupted. Please try resetting app data.", comment: "")
        }
    }
}