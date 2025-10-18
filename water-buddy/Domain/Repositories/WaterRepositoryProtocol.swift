import Foundation

protocol WaterRepositoryProtocol {
    func addEntry(_ entry: WaterEntry) async throws
    func getEntries(for date: Date) async throws -> [WaterEntry]
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WaterEntry]
    func deleteEntry(id: UUID) async throws
    func updateEntry(_ entry: WaterEntry) async throws
    func getStatistics(for date: Date) async throws -> HydrationStatistics
    func getWeeklyStatistics(from startDate: Date, to endDate: Date) async throws -> WeeklyStatistics
    func getTotalIntakeForDate(_ date: Date) async throws -> Double
    func getLastSevenDaysIntake() async throws -> [Double]
    func getAllEntries() async throws -> [WaterEntry]
    func clearAllData() async throws
}