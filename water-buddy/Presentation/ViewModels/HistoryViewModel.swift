import Foundation
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var waterEntries: [WaterEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedDate: Date = Date()

    private let waterRepository: WaterRepositoryProtocol

    init(waterRepository: WaterRepositoryProtocol) {
        self.waterRepository = waterRepository
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
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func refreshData() {
        loadEntries(for: selectedDate)
    }
}