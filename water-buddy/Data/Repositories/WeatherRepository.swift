import Foundation

class WeatherRepository: WeatherRepositoryProtocol {
    private let remoteDataSource: RemoteDataSource

    init(remoteDataSource: RemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let weatherResponse = try await remoteDataSource.fetchWeatherData(latitude: latitude, longitude: longitude)
        return mapToWeatherData(weatherResponse, latitude: latitude, longitude: longitude)
    }

    func getWeatherRecommendation(weather: WeatherData, userGoal: Double) async throws -> HydrationRecommendation {
        return calculateHydrationRecommendation(weather: weather, userGoal: userGoal)
    }

    // MARK: - Private Methods

    private func mapToWeatherData(_ response: OpenMeteoResponse, latitude: Double, longitude: Double) -> WeatherData {
        // Extract daily mean temperature (first element of the array)
        let temperature = response.daily.temperature2mMean.first ?? 20.0

        // Determine weather condition based on temperature
        let condition = mapWeatherConditionFromTemperature(temperature)

        // Use temperature as feels-like (no additional data available from basic Open-Meteo)
        let feelsLike = temperature

        // Format location string from coordinates
        let location = formatLocation(latitude: latitude, longitude: longitude)

        // Set default humidity (moderate value)
        let humidity = 50.0

        return WeatherData(
            temperature: temperature,
            humidity: humidity,
            condition: condition,
            feelsLike: feelsLike,
            location: location
        )
    }

    private func mapWeatherConditionFromTemperature(_ temperature: Double) -> WeatherCondition {
        // Map temperature ranges to weather conditions
        if temperature > 35 {
            return .hot
        } else if temperature > 30 {
            return .hot
        } else if temperature > 25 {
            return .sunny
        } else if temperature > 15 {
            return .cloudy
        } else {
            return .cloudy
        }
    }

    private func formatLocation(latitude: Double, longitude: Double) -> String {
        // Format coordinates into a readable location string
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"
        return String(format: "%.2f°%@ %.2f°%@", abs(latitude), latDirection, abs(longitude), lonDirection)
    }

    private func calculateHydrationRecommendation(weather: WeatherData, userGoal: Double) -> HydrationRecommendation {
        var multiplier: Double = 1.0
        var priority: RecommendationPriority = .normal
        var reason = NSLocalizedString("weather.recommendation.normal", value: "Normal hydration recommended", comment: "")

        // Enhanced 6-tier temperature-based adjustments
        if weather.temperature < 15 {
            // Cold weather - normal hydration
            multiplier = 1.0
            priority = .low
            reason = NSLocalizedString("weather.recommendation.cold", value: "Cool weather. Maintain regular water intake", comment: "")
        } else if weather.temperature < 20 {
            // Mild weather - slightly increased
            multiplier = 1.05
            priority = .normal
            reason = NSLocalizedString("weather.recommendation.mild", value: "Mild weather. Increase water intake by 5%", comment: "")
        } else if weather.temperature < 25 {
            // Warm weather - moderate increase
            multiplier = 1.10
            priority = .normal
            reason = NSLocalizedString("weather.recommendation.warm", value: "Warm weather. Increase water intake by 10%", comment: "")
        } else if weather.temperature < 30 {
            // Hot weather - significant increase
            multiplier = 1.20
            priority = .high
            reason = NSLocalizedString("weather.recommendation.hot", value: "Hot weather! Increase water intake by 20%", comment: "")
        } else if weather.temperature < 35 {
            // Very hot weather - high increase
            multiplier = 1.35
            priority = .high
            reason = NSLocalizedString("weather.recommendation.very_hot", value: "Very hot weather! Increase water intake by 35%", comment: "")
        } else {
            // Extreme heat - critical increase
            multiplier = 1.50
            priority = .urgent
            reason = NSLocalizedString("weather.recommendation.extreme_heat", value: "Extreme heat! Critical to stay hydrated. Increase water intake by 50%", comment: "")
        }

        // Humidity adjustments (minor refinements to base temperature recommendation)
        if weather.humidity < 30 {
            multiplier += 0.05
            reason += NSLocalizedString("weather.recommendation.dry", value: " Dry air increases dehydration.", comment: "")
        } else if weather.humidity > 80 {
            multiplier += 0.05
            reason += NSLocalizedString("weather.recommendation.humid", value: " High humidity requires extra hydration.", comment: "")
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