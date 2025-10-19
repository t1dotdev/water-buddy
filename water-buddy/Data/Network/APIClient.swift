import Foundation

protocol APIClient {
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> OpenMeteoResponse
}

class APIClientImpl: APIClient {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let urlSession = URLSession.shared

    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> OpenMeteoResponse {
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: "temperature_2m_mean"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        // Make the API request
        let (data, response) = try await urlSession.data(from: url)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        // Decode the response
        do {
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(OpenMeteoResponse.self, from: data)
            return weatherResponse
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
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