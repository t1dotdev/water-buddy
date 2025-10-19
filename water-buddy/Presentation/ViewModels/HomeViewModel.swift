import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dailyIntake: Double = 0
    @Published var dailyGoal: Double = 2000
    @Published var percentage: Double = 0
    @Published var user: User?
    @Published var weatherRecommendation: String = ""
    @Published var hydrationRecommendation: HydrationRecommendation?
    @Published var currentTemperature: Double = 0.0
    @Published var weatherData: WeatherData?
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

                // Reload data to get updated stats, streak, and weekly overview
                await loadTodayStats()
                await loadUserAndWeeklyData()

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
        // Update percentage when intake, goal, or recommendation changes
        Publishers.CombineLatest3($dailyIntake, $dailyGoal, $hydrationRecommendation)
            .map { [weak self] intake, goal, recommendation in
                guard let self = self else { return 0.0 }
                let goalToUse = recommendation != nil ? (goal * recommendation!.multiplier) : goal
                guard goalToUse > 0 else { return 0.0 }
                return min(intake / goalToUse, 1.0) * 100.0
            }
            .assign(to: &$percentage)
    }

    func calculateProgress() {
        let goalToUse = recommendedDailyGoal
        guard goalToUse > 0 else {
            percentage = 0
            return
        }
        percentage = min(dailyIntake / goalToUse, 1.0) * 100.0
    }

    private func loadWeatherData() async {
        do {
            let weather = try await getWeatherUseCase.getCurrentWeather()
            let recommendation = try await getWeatherUseCase.execute()

            weatherData = weather
            currentTemperature = weather.temperature
            weatherRecommendation = recommendation.reason
            hydrationRecommendation = recommendation
        } catch {
            print("Weather loading failed: \(error.localizedDescription)")
            weatherRecommendation = NSLocalizedString("weather.unavailable", value: "Weather data unavailable", comment: "")
            currentTemperature = 0.0
            weatherData = nil
            hydrationRecommendation = nil
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

    private func loadUserAndWeeklyData() async {
        do {
            async let userData = getUserDataUseCase.execute()
            async let weeklyTrend = getStatisticsUseCase.getDailyTrend(days: 7)

            let (loadedUser, trend) = try await (userData, weeklyTrend)

            self.user = loadedUser
            self.streakCount = loadedUser.streakCount
            self.lastSevenDays = trend
        } catch {
            print("Failed to load user and weekly data: \(error.localizedDescription)")
        }
    }

    // MARK: - Computed Properties

    var formattedDailyIntake: String {
        let unit = user?.preferredUnit ?? .milliliters
        return String(format: "%.0f %@", dailyIntake, unit.symbol)
    }

    var formattedDailyGoal: String {
        let unit = user?.preferredUnit ?? .milliliters
        return String(format: "%.0f %@", dailyGoal, unit.symbol)
    }

    var formattedPercentage: String {
        return String(format: "%.0f%%", percentage)
    }

    var remainingAmount: Double {
        return max(dailyGoal - dailyIntake, 0)
    }

    var formattedRemainingAmount: String {
        let unit = user?.preferredUnit ?? .milliliters
        return String(format: "%.0f %@", remainingAmount, unit.symbol)
    }

    var isGoalAchieved: Bool {
        return dailyIntake >= dailyGoal
    }

    var recommendedDailyGoal: Double {
        guard let recommendation = hydrationRecommendation else { return dailyGoal }
        return dailyGoal * recommendation.multiplier
    }

    var shouldShowRecommendation: Bool {
        guard let recommendation = hydrationRecommendation else { return false }
        return recommendation.multiplier != 1.0
    }

    var recommendationPercentage: Int {
        guard let recommendation = hydrationRecommendation else { return 0 }
        return Int((recommendation.multiplier - 1.0) * 100)
    }

    var formattedRecommendedGoal: String {
        let unit = user?.preferredUnit ?? .milliliters
        return String(format: "%.0f %@", recommendedDailyGoal, unit.symbol)
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