import Foundation

class WeatherRepository: WeatherRepositoryProtocol {
    private let remoteDataSource: RemoteDataSource

    init(remoteDataSource: RemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let weatherResponse = try await remoteDataSource.fetchWeatherData(latitude: latitude, longitude: longitude)
        return mapToWeatherData(weatherResponse)
    }

    func getWeatherRecommendation(weather: WeatherData, userGoal: Double) async throws -> HydrationRecommendation {
        return calculateHydrationRecommendation(weather: weather, userGoal: userGoal)
    }

    // MARK: - Private Methods

    private func mapToWeatherData(_ response: WeatherResponse) -> WeatherData {
        let condition = mapWeatherCondition(response.current.condition.text)

        return WeatherData(
            temperature: response.current.tempC,
            humidity: Double(response.current.humidity),
            condition: condition,
            feelsLike: response.current.feelslikeC,
            location: response.location.name
        )
    }

    private func mapWeatherCondition(_ conditionText: String) -> WeatherCondition {
        let lowercased = conditionText.lowercased()

        if lowercased.contains("sun") || lowercased.contains("clear") {
            return .sunny
        } else if lowercased.contains("cloud") {
            return .cloudy
        } else if lowercased.contains("rain") || lowercased.contains("drizzle") {
            return .rainy
        } else if lowercased.contains("snow") {
            return .snowy
        } else {
            return .cloudy // Default
        }
    }

    private func calculateHydrationRecommendation(weather: WeatherData, userGoal: Double) -> HydrationRecommendation {
        var multiplier: Double = 1.0
        var priority: RecommendationPriority = .normal
        var reason = NSLocalizedString("weather.recommendation.normal", value: "Normal hydration recommended", comment: "")

        // Temperature-based adjustments
        if weather.temperature > 30 {
            multiplier += 0.3
            priority = .high
            reason = NSLocalizedString("weather.recommendation.hot", value: "Hot weather! Increase water intake by 30%", comment: "")
        } else if weather.temperature > 25 {
            multiplier += 0.15
            priority = .normal
            reason = NSLocalizedString("weather.recommendation.warm", value: "Warm weather. Increase water intake by 15%", comment: "")
        }

        // Humidity adjustments
        if weather.humidity < 30 {
            multiplier += 0.1
            reason += NSLocalizedString("weather.recommendation.dry", value: " Dry air increases dehydration.", comment: "")
        } else if weather.humidity > 80 {
            multiplier += 0.05
            reason += NSLocalizedString("weather.recommendation.humid", value: " High humidity requires extra hydration.", comment: "")
        }

        // Activity-based adjustments for different weather conditions
        switch weather.condition {
        case .sunny:
            multiplier += 0.1
            if priority == .normal {
                priority = .high
            }
            reason += NSLocalizedString("weather.recommendation.sunny", value: " Sunny conditions increase water needs.", comment: "")

        case .hot:
            multiplier += 0.4
            priority = .urgent
            reason = NSLocalizedString("weather.recommendation.extreme_heat", value: "Extreme heat! Critical to stay hydrated", comment: "")

        case .humid:
            multiplier += 0.2
            priority = .high
            reason += NSLocalizedString("weather.recommendation.very_humid", value: " Very humid conditions increase sweating.", comment: "")

        default:
            break
        }

        let recommendedIntake = userGoal * multiplier

        return HydrationRecommendation(
            recommendedIntake: recommendedIntake,
            reason: reason,
            multiplier: multiplier,
            priority: priority
        )
    }
}