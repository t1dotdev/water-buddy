import Foundation

protocol UserDefaultsDataSource {
    func save<T: Codable>(_ object: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T
    func loadSafely<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func delete(forKey key: String)
    func exists(forKey key: String) -> Bool
    func clearCorruptedData(forKey key: String)
    func resetAllData()
}

class UserDefaultsDataSourceImpl: UserDefaultsDataSource {
    private let userDefaults = UserDefaults.standard
    private let currentDataVersion = "1.0"
    private let dataVersionKey = "data_version"

    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
        
        // Save version info
        userDefaults.set(currentDataVersion, forKey: dataVersionKey)
        
        // Force synchronization to ensure data is saved immediately
        userDefaults.synchronize()
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw DataSourceError.dataNotFound
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            print("Failed to decode \(type) for key \(key): \(error)")
            clearCorruptedData(forKey: key)
            throw DataSourceError.decodingFailed
        }
    }
    
    func loadSafely<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        // Check data version compatibility
        let savedVersion = userDefaults.string(forKey: dataVersionKey)
        if savedVersion != currentDataVersion {
            print("Data version mismatch. Saved: \(savedVersion ?? "none"), Current: \(currentDataVersion)")
            clearCorruptedData(forKey: key)
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            print("Failed to decode \(type) for key \(key): \(error). Clearing corrupted data.")
            clearCorruptedData(forKey: key)
            return nil
        }
    }

    func delete(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
    
    func clearCorruptedData(forKey key: String) {
        print("Clearing potentially corrupted data for key: \(key)")
        userDefaults.removeObject(forKey: key)
    }
    
    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
        print("All app data has been reset")
    }
}

enum DataSourceError: Error, LocalizedError {
    case dataNotFound
    case encodingFailed
    case decodingFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return NSLocalizedString("error.data_not_found", value: "Data not found", comment: "")
        case .encodingFailed:
            return NSLocalizedString("error.encoding_failed", value: "Failed to encode data", comment: "")
        case .decodingFailed:
            return NSLocalizedString("error.decoding_failed", value: "Failed to decode data", comment: "")
        case .saveFailed:
            return NSLocalizedString("error.save_failed", value: "Failed to save data", comment: "")
        }
    }
}