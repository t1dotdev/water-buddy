import Foundation

protocol LocalDataSource {
    func save(_ entry: WaterEntry) async throws
    func getEntries(for date: Date) async throws -> [WaterEntry]
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WaterEntry]
    func deleteEntry(id: UUID) async throws
    func updateEntry(_ entry: WaterEntry) async throws
    func getAllEntries() async throws -> [WaterEntry]
    func clearAllEntries() async throws
}

class LocalDataSourceImpl: LocalDataSource {
    private let userDefaultsDataSource: UserDefaultsDataSource
    private let entriesKey = "water_entries"

    init(userDefaults: UserDefaultsDataSource) {
        self.userDefaultsDataSource = userDefaults
    }

    func save(_ entry: WaterEntry) async throws {
        var entries = try await getAllEntries()
        entries.append(entry)
        try userDefaultsDataSource.save(entries, forKey: entriesKey)
    }

    func getEntries(for date: Date) async throws -> [WaterEntry] {
        let allEntries = try await getAllEntries()
        let calendar = Calendar.current

        return allEntries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }.sorted { $0.timestamp > $1.timestamp } // Sort in descending order (most recent first)
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WaterEntry] {
        let allEntries = try await getAllEntries()

        return allEntries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }.sorted { $0.timestamp > $1.timestamp } // Sort in descending order (most recent first)
    }

    func deleteEntry(id: UUID) async throws {
        var entries = try await getAllEntries()
        entries.removeAll { $0.id == id }
        try userDefaultsDataSource.save(entries, forKey: entriesKey)
    }

    func updateEntry(_ entry: WaterEntry) async throws {
        var entries = try await getAllEntries()

        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            try userDefaultsDataSource.save(entries, forKey: entriesKey)
        } else {
            throw DataSourceError.dataNotFound
        }
    }

    func getAllEntries() async throws -> [WaterEntry] {
        // Use safe loading to handle corrupted data
        if let entries = userDefaultsDataSource.loadSafely([WaterEntry].self, forKey: entriesKey) {
            return entries
        }
        return []
    }

    func clearAllEntries() async throws {
        userDefaultsDataSource.delete(forKey: entriesKey)
    }
}