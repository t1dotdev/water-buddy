import Foundation

protocol GetStatisticsUseCase {
    func execute(for period: TimePeriod) async throws -> HydrationStatistics
    func getWeeklyStatistics() async throws -> WeeklyStatistics
    func getDailyTrend(days: Int) async throws -> [Double]
}

class GetStatisticsUseCaseImpl: GetStatisticsUseCase {
    private let waterRepository: WaterRepositoryProtocol

    init(waterRepository: WaterRepositoryProtocol) {
        self.waterRepository = waterRepository
    }

    func execute(for period: TimePeriod) async throws -> HydrationStatistics {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .today:
            return try await waterRepository.getStatistics(for: now)

        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return try await calculatePeriodStatistics(from: startOfWeek, to: endOfWeek)

        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return try await calculatePeriodStatistics(from: startOfMonth, to: endOfMonth)

        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
            return try await calculatePeriodStatistics(from: startOfYear, to: endOfYear)
        }
    }

    func getWeeklyStatistics() async throws -> WeeklyStatistics {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now

        return try await waterRepository.getWeeklyStatistics(from: startOfWeek, to: endOfWeek)
    }

    func getDailyTrend(days: Int) async throws -> [Double] {
        let calendar = Calendar.current
        let today = Date()
        var trendData: [Double] = []

        for i in (0..<days).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let intake = try await waterRepository.getTotalIntakeForDate(date)
            trendData.append(intake)
        }

        return trendData
    }

    // MARK: - Private Methods

    private func calculatePeriodStatistics(from startDate: Date, to endDate: Date) async throws -> HydrationStatistics {
        let entries = try await waterRepository.getEntries(from: startDate, to: endDate)

        let totalIntake = entries.reduce(0) { $0 + $1.amount }
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let averageIntake = totalIntake / Double(max(daysDifference, 1))

        // Calculate hourly distribution
        var hourlyDistribution: [Int: Double] = [:]
        for entry in entries {
            let hour = calendar.component(.hour, from: entry.timestamp)
            hourlyDistribution[hour, default: 0] += entry.amount
        }

        // Calculate container usage
        var containerUsage: [ContainerType: Int] = [:]
        for entry in entries {
            containerUsage[entry.containerType, default: 0] += 1
        }

        // Get weekly trend (last 7 days from end date)
        var weeklyTrend: [Double] = []
        for i in (0...6).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: endDate) ?? endDate
            let dayEntries = entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            let dayIntake = dayEntries.reduce(0) { $0 + $1.amount }
            weeklyTrend.append(dayIntake)
        }

        return HydrationStatistics(
            date: endDate,
            totalIntake: totalIntake,
            goalAchieved: totalIntake >= 2000.0, // Default goal
            hourlyDistribution: hourlyDistribution,
            weeklyTrend: weeklyTrend,
            containerUsage: containerUsage,
            averageIntake: averageIntake,
            streakCount: 0, // Will be updated by repository
            unit: .milliliters
        )
    }
}