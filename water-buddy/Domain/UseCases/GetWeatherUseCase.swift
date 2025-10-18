import Foundation
import CoreLocation

protocol GetWeatherUseCase {
    func execute() async throws -> HydrationRecommendation
    func getCurrentWeather() async throws -> WeatherData
}

class GetWeatherUseCaseImpl: GetWeatherUseCase {
    private let weatherRepository: WeatherRepositoryProtocol
    private let locationManager = CLLocationManager()

    init(weatherRepository: WeatherRepositoryProtocol) {
        self.weatherRepository = weatherRepository
    }

    func execute() async throws -> HydrationRecommendation {
        let weather = try await getCurrentWeather()
        return try await weatherRepository.getWeatherRecommendation(weather: weather, userGoal: 2000.0)
    }

    func getCurrentWeather() async throws -> WeatherData {
        let location = try await getCurrentLocation()
        return try await weatherRepository.getCurrentWeather(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    // MARK: - Private Methods

    private func getCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            // Check current authorization status
            let status = locationManager.authorizationStatus
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if let location = locationManager.location {
                    continuation.resume(returning: location)
                } else {
                    // Use a default location if current location is not available
                    // Default to San Francisco coordinates for demo
                    let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                    continuation.resume(returning: defaultLocation)
                }
            case .denied, .restricted:
                // Use default location instead of throwing error
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                continuation.resume(returning: defaultLocation)
            case .notDetermined:
                // Request permission
                locationManager.requestWhenInUseAuthorization()
                // Use default location for now
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                continuation.resume(returning: defaultLocation)
            @unknown default:
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                continuation.resume(returning: defaultLocation)
            }
        }
    }
}

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case permissionNotDetermined
    case locationNotAvailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("error.location.denied", value: "Location permission denied", comment: "")
        case .permissionNotDetermined:
            return NSLocalizedString("error.location.not_determined", value: "Location permission not determined", comment: "")
        case .locationNotAvailable:
            return NSLocalizedString("error.location.not_available", value: "Location not available", comment: "")
        case .unknown:
            return NSLocalizedString("error.location.unknown", value: "Unknown location error", comment: "")
        }
    }
}