import Foundation
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var currentPeriod: TimePeriod = .today
    @Published var statistics: HydrationStatistics?
    @Published var weeklyStatistics: WeeklyStatistics?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let getStatisticsUseCase: GetStatisticsUseCase

    init(getStatisticsUseCase: GetStatisticsUseCase) {
        self.getStatisticsUseCase = getStatisticsUseCase
    }

    func loadStatistics(for period: TimePeriod = .today) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                currentPeriod = period
                statistics = try await getStatisticsUseCase.execute(for: period)

                if period == .week {
                    weeklyStatistics = try await getStatisticsUseCase.getWeeklyStatistics()
                }
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func refreshData() {
        loadStatistics(for: currentPeriod)
    }
}