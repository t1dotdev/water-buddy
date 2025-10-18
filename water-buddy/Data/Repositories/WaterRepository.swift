import Foundation

class WaterRepository: WaterRepositoryProtocol {
    private let localDataSource: LocalDataSource
    private let remoteDataSource: RemoteDataSource

    init(localDataSource: LocalDataSource, remoteDataSource: RemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func addEntry(_ entry: WaterEntry) async throws {
        // Save locally first
        try await localDataSource.save(entry)

        // Try to sync remotely (don't fail if remote sync fails)
        do {
            try await remoteDataSource.sync(entry)
        } catch {
            print("Remote sync failed: \(error.localizedDescription)")
        }
    }

    func getEntries(for date: Date) async throws -> [WaterEntry] {
        return try await localDataSource.getEntries(for: date)
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WaterEntry] {
        return try await localDataSource.getEntries(from: startDate, to: endDate)
    }

    func deleteEntry(id: UUID) async throws {
        try await localDataSource.deleteEntry(id: id)
    }

    func updateEntry(_ entry: WaterEntry) async throws {
        try await localDataSource.updateEntry(entry)
    }

    func getStatistics(for date: Date) async throws -> HydrationStatistics {
        let entries = try await getEntries(for: date)
        return calculateStatistics(for: entries, date: date)
    }

    func getWeeklyStatistics(from startDate: Date, to endDate: Date) async throws -> WeeklyStatistics {
        let calendar = Calendar.current
        var dailyStats: [HydrationStatistics] = []

        var currentDate = startDate
        while currentDate <= endDate {
            let dayEntries = try await getEntries(for: currentDate)
            let dayStats = calculateStatistics(for: dayEntries, date: currentDate)
            dailyStats.append(dayStats)

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }

        return WeeklyStatistics(
            startDate: startDate,
            endDate: endDate,
            dailyStats: dailyStats
        )
    }

    func getTotalIntakeForDate(_ date: Date) async throws -> Double {
        let entries = try await getEntries(for: date)
        return entries.reduce(0) { $0 + $1.amount }
    }

    func getLastSevenDaysIntake() async throws -> [Double] {
        let calendar = Calendar.current
        let today = Date()
        var intakes: [Double] = []

        for i in (0...6).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let intake = try await getTotalIntakeForDate(date)
            intakes.append(intake)
        }

        return intakes
    }

    func getAllEntries() async throws -> [WaterEntry] {
        return try await localDataSource.getAllEntries()
    }

    func clearAllData() async throws {
        try await localDataSource.clearAllEntries()
    }

    // MARK: - Private Methods

    private func calculateStatistics(for entries: [WaterEntry], date: Date) -> HydrationStatistics {
        let totalIntake = entries.reduce(0) { $0 + $1.amount }
        let calendar = Calendar.current

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

        // Get last 7 days trend (simplified version)
        let weeklyTrend = Array(repeating: totalIntake, count: 7) // Simplified for now

        let goalAchieved = totalIntake >= 2000.0 // Default goal

        return HydrationStatistics(
            date: date,
            totalIntake: totalIntake,
            goalAchieved: goalAchieved,
            hourlyDistribution: hourlyDistribution,
            weeklyTrend: weeklyTrend,
            containerUsage: containerUsage,
            averageIntake: totalIntake,
            streakCount: goalAchieved ? 1 : 0,
            unit: .milliliters
        )
    }
}