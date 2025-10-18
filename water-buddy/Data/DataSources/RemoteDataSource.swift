import Foundation

protocol RemoteDataSource {
    func sync(_ entry: WaterEntry) async throws
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func syncAllEntries(_ entries: [WaterEntry]) async throws
}

class RemoteDataSourceImpl: RemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func sync(_ entry: WaterEntry) async throws {
        // In a real app, this would sync to a backend service
        // For now, we'll just simulate the network call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
    }

    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        return try await apiClient.fetchWeatherData(latitude: latitude, longitude: longitude)
    }

    func syncAllEntries(_ entries: [WaterEntry]) async throws {
        // Batch sync entries to remote server
        for entry in entries {
            try await sync(entry)
        }
    }
}

// MARK: - Weather Response Models

struct WeatherResponse: Codable {
    let current: CurrentWeather
    let location: Location
}

struct CurrentWeather: Codable {
    let tempC: Double
    let tempF: Double
    let humidity: Int
    let condition: WeatherConditionResponse
    let feelslikeC: Double
    let feelslikeF: Double

    private enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case humidity
        case condition
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
    }
}

struct WeatherConditionResponse: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tzId: String
    let localtimeEpoch: Int
    let localtime: String

    private enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzId = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}