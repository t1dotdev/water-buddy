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
        print("💾 Saving \(T.self) to key: \(key)")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(object)
        print("📦 Encoded data size: \(data.count) bytes")

        // Save to UserDefaults
        userDefaults.set(data, forKey: key)

        // Save version info
        userDefaults.set(currentDataVersion, forKey: dataVersionKey)
        print("💾 Version set to: \(currentDataVersion)")

        // Force synchronization to ensure data is saved immediately
        userDefaults.synchronize()

        // CRITICAL: Immediately verify the data was actually saved
        print("🔍 Verifying UserDefaults persistence...")
        guard let savedData = userDefaults.data(forKey: key) else {
            print("❌ CRITICAL: UserDefaults.set() returned but data is NIL when reading back!")
            print("   Key: \(key)")
            print("   Original data size: \(data.count)")
            dumpUserDefaultsState()
            throw DataSourceError.saveFailed
        }

        if savedData.count != data.count {
            print("❌ CRITICAL: Data size mismatch!")
            print("   Saved: \(data.count) bytes")
            print("   Read back: \(savedData.count) bytes")
            throw DataSourceError.saveFailed
        }

        if savedData != data {
            print("❌ CRITICAL: Data content mismatch!")
            print("   Saved and read data are different!")
            throw DataSourceError.saveFailed
        }

        print("✅ Persistence verified! Data successfully saved and read back.")
        print("✅ Save completed for key: \(key)")
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
            print("📭 No data found for key: \(key)")
            return nil
        }

        // Check data version compatibility (allow nil for backward compatibility)
        let savedVersion = userDefaults.string(forKey: dataVersionKey)
        print("🔍 Loading \(key): savedVersion=\(savedVersion ?? "nil"), currentVersion=\(currentDataVersion)")

        // Only reject if version exists AND doesn't match (allow nil/missing versions)
        if let savedVersion = savedVersion, savedVersion != currentDataVersion {
            print("⚠️ Data version mismatch. Saved: \(savedVersion), Current: \(currentDataVersion)")
            clearCorruptedData(forKey: key)
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            // Try to show raw JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw JSON data: \(jsonString)")
            }

            let decoded = try decoder.decode(type, from: data)
            print("✅ Successfully decoded \(type) for key: \(key)")
            return decoded
        } catch let DecodingError.keyNotFound(codingKey, context) {
            print("❌ DECODE ERROR: Key '\(codingKey.stringValue)' not found")
            print("   Context: \(context.debugDescription)")
            print("   CodingPath: \(context.codingPath)")
            clearCorruptedData(forKey: key)
            return nil
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ DECODE ERROR: Type mismatch for type \(type)")
            print("   Context: \(context.debugDescription)")
            print("   CodingPath: \(context.codingPath)")
            clearCorruptedData(forKey: key)
            return nil
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ DECODE ERROR: Value not found for type \(type)")
            print("   Context: \(context.debugDescription)")
            print("   CodingPath: \(context.codingPath)")
            clearCorruptedData(forKey: key)
            return nil
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ DECODE ERROR: Data corrupted")
            print("   Context: \(context.debugDescription)")
            print("   CodingPath: \(context.codingPath)")
            clearCorruptedData(forKey: key)
            return nil
        } catch {
            print("❌ DECODE ERROR: Unknown error: \(error)")
            print("   Error details: \(error.localizedDescription)")
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
        print("🗑️ Clearing potentially corrupted data for key: \(key)")
        print("⚠️ WARNING: About to delete data that couldn't be loaded!")
        userDefaults.removeObject(forKey: key)
        print("🗑️ Data cleared for key: \(key)")
    }
    
    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
        print("All app data has been reset")
    }

    private func dumpUserDefaultsState() {
        print("🔍 === USERDEFAULTS DIAGNOSTIC ===")
        print("📱 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")

        // Get all keys in UserDefaults
        let allKeys = userDefaults.dictionaryRepresentation().keys.sorted()
        print("📋 Total keys in UserDefaults: \(allKeys.count)")

        // Show our app's keys
        let appKeys = allKeys.filter { $0.contains("current_user") || $0.contains("data_version") || $0.contains("water") }
        print("🔑 App-related keys: \(appKeys)")

        // Check specific keys
        if let userData = userDefaults.data(forKey: "current_user") {
            print("💾 'current_user' exists: \(userData.count) bytes")
        } else {
            print("❌ 'current_user' is nil")
        }

        if let version = userDefaults.string(forKey: "data_version") {
            print("🔖 'data_version' exists: \(version)")
        } else {
            print("❌ 'data_version' is nil")
        }

        // Check UserDefaults health
        testUserDefaultsWritability()

        print("🔍 === END DIAGNOSTIC ===")
    }

    private func testUserDefaultsWritability() {
        print("🧪 Testing UserDefaults writability...")
        let testKey = "test_write_\(UUID().uuidString)"
        let testData = "test_value_\(Date().timeIntervalSince1970)".data(using: .utf8)!

        userDefaults.set(testData, forKey: testKey)
        userDefaults.synchronize()

        if let readBack = userDefaults.data(forKey: testKey), readBack == testData {
            print("✅ UserDefaults is writable and working correctly")
            userDefaults.removeObject(forKey: testKey)
        } else {
            print("❌ CRITICAL: UserDefaults write test FAILED!")
            print("   UserDefaults may be corrupted or readonly")
        }
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