import Foundation

protocol RemoteDataSource {
    func sync(_ entry: WaterEntry) async throws
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> OpenMeteoResponse
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

    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> OpenMeteoResponse {
        return try await apiClient.fetchWeatherData(latitude: latitude, longitude: longitude)
    }

    func syncAllEntries(_ entries: [WaterEntry]) async throws {
        // Batch sync entries to remote server
        for entry in entries {
            try await sync(entry)
        }
    }
}

// MARK: - Open-Meteo Weather Response Models

struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let daily: DailyWeather
    let timezone: String
    let generationtimeMs: Double?
    let utcOffsetSeconds: Int?
    let elevation: Double?

    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case daily
        case timezone
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case elevation
    }
}

struct DailyWeather: Codable {
    let time: [String]
    let temperature2mMean: [Double]

    private enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMean = "temperature_2m_mean"
    }
}