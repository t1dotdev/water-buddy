import Foundation

protocol WeatherRepositoryProtocol {
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherData
    func getWeatherRecommendation(weather: WeatherData, userGoal: Double) async throws -> HydrationRecommendation
}

struct WeatherData: Codable, Equatable {
    let temperature: Double
    let humidity: Double
    let condition: WeatherCondition
    let feelsLike: Double
    let location: String

    init(
        temperature: Double,
        humidity: Double,
        condition: WeatherCondition,
        feelsLike: Double,
        location: String
    ) {
        self.temperature = temperature
        self.humidity = humidity
        self.condition = condition
        self.feelsLike = feelsLike
        self.location = location
    }
}

enum WeatherCondition: String, Codable, CaseIterable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case snowy = "snowy"
    case hot = "hot"
    case humid = "humid"

    var displayName: String {
        switch self {
        case .sunny:
            return NSLocalizedString("weather.sunny", value: "Sunny", comment: "")
        case .cloudy:
            return NSLocalizedString("weather.cloudy", value: "Cloudy", comment: "")
        case .rainy:
            return NSLocalizedString("weather.rainy", value: "Rainy", comment: "")
        case .snowy:
            return NSLocalizedString("weather.snowy", value: "Snowy", comment: "")
        case .hot:
            return NSLocalizedString("weather.hot", value: "Hot", comment: "")
        case .humid:
            return NSLocalizedString("weather.humid", value: "Humid", comment: "")
        }
    }

    var systemImageName: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .hot:
            return "thermometer.sun.fill"
        case .humid:
            return "humidity.fill"
        }
    }
}

struct HydrationRecommendation: Codable, Equatable {
    let recommendedIntake: Double
    let reason: String
    let multiplier: Double
    let priority: RecommendationPriority

    init(
        recommendedIntake: Double,
        reason: String,
        multiplier: Double = 1.0,
        priority: RecommendationPriority = .normal
    ) {
        self.recommendedIntake = recommendedIntake
        self.reason = reason
        self.multiplier = multiplier
        self.priority = priority
    }
}

enum RecommendationPriority: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"

    var displayColor: String {
        switch self {
        case .low:
            return "systemGray"
        case .normal:
            return "systemBlue"
        case .high:
            return "systemOrange"
        case .urgent:
            return "systemRed"
        }
    }
}