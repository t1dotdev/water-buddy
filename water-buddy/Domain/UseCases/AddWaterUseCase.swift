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

        // Check if daily goal is achieved and update streak
        let todayStats = try await waterRepository.getStatistics(for: Date())
        if todayStats.goalAchieved {
            let alreadyAchieved = await isGoalAlreadyAchievedToday(todayStats)
            if !alreadyAchieved {
                try await userRepository.incrementStreak()
            }
        }

        return entry
    }

    private func isGoalAlreadyAchievedToday(_ stats: HydrationStatistics) async -> Bool {
        // Check if this is the first time achieving goal today
        let calendar = Calendar.current
        let today = Date()
        let todayEntries = try? await waterRepository.getEntries(for: today)

        // Calculate intake before this entry
        let previousIntake = (todayEntries?.reduce(0) { $0 + $1.amount } ?? 0) - stats.totalIntake
        return previousIntake >= 2000.0 // Assuming 2L default goal
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