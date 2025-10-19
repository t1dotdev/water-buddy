import Foundation
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var waterEntries: [WaterEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedDate: Date = Date()

    private let waterRepository: WaterRepositoryProtocol
    private let getUserDataUseCase: GetUserDataUseCase

    init(waterRepository: WaterRepositoryProtocol, getUserDataUseCase: GetUserDataUseCase) {
        self.waterRepository = waterRepository
        self.getUserDataUseCase = getUserDataUseCase
    }

    func loadEntries(for date: Date = Date()) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                selectedDate = date
                waterEntries = try await waterRepository.getEntries(for: date)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func deleteEntry(id: UUID) {
        Task {
            do {
                try await waterRepository.deleteEntry(id: id)
                loadEntries(for: selectedDate)

                // Check if user dropped below goal and reset confetti tracker if needed
                let currentIntake = try await waterRepository.getTotalIntakeForDate(Date())
                let user = try await getUserDataUseCase.execute()
                ConfettiTracker.shared.resetIfBelowGoal(currentIntake: currentIntake, goal: user.dailyGoal)

                // Notify other views to refresh
                NotificationCenter.default.post(
                    name: Notification.Name("WaterIntakeUpdated"),
                    object: nil,
                    userInfo: ["amount": currentIntake]
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func refreshData() {
        loadEntries(for: selectedDate)
    }
}