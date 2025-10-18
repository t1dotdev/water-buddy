import Foundation

struct HydrationStatistics: Codable, Equatable {
    let date: Date
    let totalIntake: Double
    let goalAchieved: Bool
    let hourlyDistribution: [Int: Double]
    let weeklyTrend: [Double]
    let containerUsage: [ContainerType: Int]
    let averageIntake: Double
    let streakCount: Int
    let unit: WaterUnit

    init(
        date: Date = Date(),
        totalIntake: Double = 0.0,
        goalAchieved: Bool = false,
        hourlyDistribution: [Int: Double] = [:],
        weeklyTrend: [Double] = [],
        containerUsage: [ContainerType: Int] = [:],
        averageIntake: Double = 0.0,
        streakCount: Int = 0,
        unit: WaterUnit = .milliliters
    ) {
        self.date = date
        self.totalIntake = totalIntake
        self.goalAchieved = goalAchieved
        self.hourlyDistribution = hourlyDistribution
        self.weeklyTrend = weeklyTrend
        self.containerUsage = containerUsage
        self.averageIntake = averageIntake
        self.streakCount = streakCount
        self.unit = unit
    }

    // MARK: - Computed Properties

    var completionPercentage: Double {
        guard totalIntake > 0 else { return 0.0 }
        return min(totalIntake / 2000.0, 1.0) * 100.0 // Assuming 2L default goal
    }

    var formattedTotalIntake: String {
        return String(format: "%.0f %@", totalIntake, unit.symbol)
    }

    var mostUsedContainer: ContainerType? {
        return containerUsage.max { $0.value < $1.value }?.key
    }

    var peakHour: Int? {
        return hourlyDistribution.max { $0.value < $1.value }?.key
    }

    // MARK: - Helper Methods

    func intakeInUnit(_ targetUnit: WaterUnit) -> Double {
        return targetUnit.convert(from: unit, amount: totalIntake)
    }

    func weeklyTrendInUnit(_ targetUnit: WaterUnit) -> [Double] {
        return weeklyTrend.map { targetUnit.convert(from: unit, amount: $0) }
    }

    func getBestStreak() -> Int {
        return streakCount
    }

    func getWorstDay() -> Double? {
        return weeklyTrend.min()
    }

    func getBestDay() -> Double? {
        return weeklyTrend.max()
    }
}

struct WeeklyStatistics: Codable, Equatable {
    let startDate: Date
    let endDate: Date
    let dailyStats: [HydrationStatistics]
    let totalWeeklyIntake: Double
    let averageDailyIntake: Double
    let goalsAchieved: Int
    let unit: WaterUnit

    init(
        startDate: Date,
        endDate: Date,
        dailyStats: [HydrationStatistics],
        unit: WaterUnit = .milliliters
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.dailyStats = dailyStats
        self.unit = unit

        self.totalWeeklyIntake = dailyStats.reduce(0) { $0 + $1.totalIntake }
        self.averageDailyIntake = dailyStats.isEmpty ? 0 : totalWeeklyIntake / Double(dailyStats.count)
        self.goalsAchieved = dailyStats.filter { $0.goalAchieved }.count
    }

    var weeklyGoalAchievementRate: Double {
        guard !dailyStats.isEmpty else { return 0.0 }
        return Double(goalsAchieved) / Double(dailyStats.count) * 100.0
    }

    var formattedTotalWeeklyIntake: String {
        return String(format: "%.1f %@", totalWeeklyIntake, unit.symbol)
    }

    var formattedAverageDailyIntake: String {
        return String(format: "%.1f %@", averageDailyIntake, unit.symbol)
    }
}

enum TimePeriod: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
    case year = "year"

    var displayName: String {
        switch self {
        case .today:
            return NSLocalizedString("period.today", value: "Today", comment: "")
        case .week:
            return NSLocalizedString("period.week", value: "This Week", comment: "")
        case .month:
            return NSLocalizedString("period.month", value: "This Month", comment: "")
        case .year:
            return NSLocalizedString("period.year", value: "This Year", comment: "")
        }
    }
}