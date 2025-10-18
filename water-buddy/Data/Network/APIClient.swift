import Foundation
import Alamofire

protocol APIClient {
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse
}

class APIClientImpl: APIClient {
    private let session = Session.default
    private let baseURL = "https://api.weatherapi.com/v1"
    // Free API key for testing - replace with your own for production
    // Get your free API key at: https://www.weatherapi.com/signup.aspx
    private let apiKey = "YOUR_API_KEY" // Replace with actual API key
    private let useMockData = true // Set to false when you have a valid API key

    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        // If API key is not set or we're using mock data, return mock response
        if apiKey == "YOUR_API_KEY" || useMockData {
            return getMockWeatherResponse()
        }
        
        let urlString = "\(baseURL)/current.json"
        let parameters: [String: Any] = [
            "key": apiKey,
            "q": "\(latitude),\(longitude)",
            "aqi": "no"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlString, parameters: parameters)
                .validate()
                .responseDecodable(of: WeatherResponse.self) { response in
                    switch response.result {
                    case .success(let weatherResponse):
                        continuation.resume(returning: weatherResponse)
                    case .failure(let error):
                        // Fallback to mock data on error
                        print("Weather API error: \(error), using mock data")
                        continuation.resume(returning: self.getMockWeatherResponse())
                    }
                }
        }
    }
    
    private func getMockWeatherResponse() -> WeatherResponse {
        // Return mock weather data for testing
        let currentHour = Calendar.current.component(.hour, from: Date())
        let temperature: Double
        let humidity: Int
        let condition: String
        
        // Simulate different weather based on time of day
        switch currentHour {
        case 6..<10:
            temperature = 18.0
            humidity = 65
            condition = "Partly cloudy"
        case 10..<14:
            temperature = 25.0
            humidity = 55
            condition = "Sunny"
        case 14..<18:
            temperature = 28.0
            humidity = 45
            condition = "Clear"
        case 18..<22:
            temperature = 22.0
            humidity = 60
            condition = "Partly cloudy"
        default:
            temperature = 16.0
            humidity = 70
            condition = "Clear"
        }
        
        return WeatherResponse(
            current: CurrentWeather(
                tempC: temperature,
                tempF: temperature * 1.8 + 32,
                humidity: humidity,
                condition: WeatherConditionResponse(
                    text: condition,
                    icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
                    code: 1003
                ),
                feelslikeC: temperature - 1.0,
                feelslikeF: (temperature - 1.0) * 1.8 + 32
            ),
            location: Location(
                name: "Current Location",
                region: "",
                country: "Mock Data",
                lat: 0.0,
                lon: 0.0,
                tzId: "Local",
                localtimeEpoch: Int(Date().timeIntervalSince1970),
                localtime: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
            )
        )
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error.api.invalid_url", value: "Invalid URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("error.api.invalid_response", value: "Invalid response", comment: "")
        case .serverError(let code):
            return NSLocalizedString("error.api.server_error", value: "Server error: \(code)", comment: "")
        case .networkError(let error):
            return NSLocalizedString("error.api.network", value: "Network error: \(error.localizedDescription)", comment: "")
        case .decodingError:
            return NSLocalizedString("error.api.decoding", value: "Failed to decode response", comment: "")
        }
    }
}