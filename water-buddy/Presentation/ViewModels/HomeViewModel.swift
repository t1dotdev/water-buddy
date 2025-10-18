import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dailyIntake: Double = 0
    @Published var dailyGoal: Double = 2000
    @Published var percentage: Double = 0
    @Published var user: User?
    @Published var weatherRecommendation: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastSevenDays: [Double] = []
    @Published var streakCount: Int = 0
    @Published var todayEntries: [WaterEntry] = []

    private let addWaterUseCase: AddWaterUseCase
    private let getWeatherUseCase: GetWeatherUseCase
    private let getUserDataUseCase: GetUserDataUseCase
    private let getStatisticsUseCase: GetStatisticsUseCase

    private var cancellables = Set<AnyCancellable>()

    init(
        addWaterUseCase: AddWaterUseCase,
        getWeatherUseCase: GetWeatherUseCase,
        getUserDataUseCase: GetUserDataUseCase,
        getStatisticsUseCase: GetStatisticsUseCase
    ) {
        self.addWaterUseCase = addWaterUseCase
        self.getWeatherUseCase = getWeatherUseCase
        self.getUserDataUseCase = getUserDataUseCase
        self.getStatisticsUseCase = getStatisticsUseCase

        setupBindings()
    }

    // MARK: - Public Methods

    func loadData() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                async let userData = getUserDataUseCase.execute()
                async let todayStats = getStatisticsUseCase.execute(for: .today)
                async let weeklyTrend = getStatisticsUseCase.getDailyTrend(days: 7)

                let (loadedUser, stats, trend) = try await (userData, todayStats, weeklyTrend)

                self.user = loadedUser
                self.dailyGoal = loadedUser.dailyGoal
                self.streakCount = loadedUser.streakCount
                self.dailyIntake = stats.totalIntake
                self.lastSevenDays = trend
                self.calculateProgress()

                await loadWeatherData()

            } catch {
                self.errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func addWater(amount: Double, container: ContainerType) {
        Task {
            do {
                let entry = try await addWaterUseCase.execute(amount: amount, container: container)
                todayEntries.append(entry)
                dailyIntake += amount
                calculateProgress()

                // Reload data to get updated stats
                await loadTodayStats()

            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func refreshData() {
        loadData()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Update percentage when intake or goal changes
        Publishers.CombineLatest($dailyIntake, $dailyGoal)
            .map { intake, goal in
                guard goal > 0 else { return 0.0 }
                return min(intake / goal, 1.0) * 100.0
            }
            .assign(to: &$percentage)
    }

    func calculateProgress() {
        guard dailyGoal > 0 else {
            percentage = 0
            return
        }
        percentage = min(dailyIntake / dailyGoal, 1.0) * 100.0
    }

    private func loadWeatherData() async {
        do {
            let recommendation = try await getWeatherUseCase.execute()
            weatherRecommendation = recommendation.reason
        } catch {
            print("Weather loading failed: \(error.localizedDescription)")
            weatherRecommendation = NSLocalizedString("weather.unavailable", value: "Weather data unavailable", comment: "")
        }
    }

    private func loadTodayStats() async {
        do {
            let stats = try await getStatisticsUseCase.execute(for: .today)
            dailyIntake = stats.totalIntake
            calculateProgress()
        } catch {
            print("Failed to load today stats: \(error.localizedDescription)")
        }
    }

    // MARK: - Computed Properties

    var formattedDailyIntake: String {
        return String(format: "%.0f ml", dailyIntake)
    }

    var formattedDailyGoal: String {
        return String(format: "%.0f ml", dailyGoal)
    }

    var formattedPercentage: String {
        return String(format: "%.0f%%", percentage)
    }

    var remainingAmount: Double {
        return max(dailyGoal - dailyIntake, 0)
    }

    var formattedRemainingAmount: String {
        return String(format: "%.0f ml", remainingAmount)
    }

    var isGoalAchieved: Bool {
        return dailyIntake >= dailyGoal
    }

    var motivationalMessage: String {
        switch percentage {
        case 0..<25:
            return NSLocalizedString("motivation.start", value: "Great start! Keep hydrating! 💧", comment: "")
        case 25..<50:
            return NSLocalizedString("motivation.quarter", value: "You're doing well! Keep it up! 👍", comment: "")
        case 50..<75:
            return NSLocalizedString("motivation.half", value: "Halfway there! You've got this! 💪", comment: "")
        case 75..<100:
            return NSLocalizedString("motivation.almost", value: "Almost there! Final push! 🏃", comment: "")
        default:
            return NSLocalizedString("motivation.achieved", value: "Goal achieved! Fantastic! 🎉", comment: "")
        }
    }
}