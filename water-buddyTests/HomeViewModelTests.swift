import XCTest
@testable import water_buddy

class HomeViewModelTests: XCTestCase {

    var sut: HomeViewModel!
    var mockAddWaterUseCase: MockAddWaterUseCase!
    var mockGetWeatherUseCase: MockGetWeatherUseCase!
    var mockGetUserDataUseCase: MockGetUserDataUseCase!
    var mockGetStatisticsUseCase: MockGetStatisticsUseCase!

    override func setUpWithError() throws {
        mockAddWaterUseCase = MockAddWaterUseCase()
        mockGetWeatherUseCase = MockGetWeatherUseCase()
        mockGetUserDataUseCase = MockGetUserDataUseCase()
        mockGetStatisticsUseCase = MockGetStatisticsUseCase()

        sut = HomeViewModel(
            addWaterUseCase: mockAddWaterUseCase,
            getWeatherUseCase: mockGetWeatherUseCase,
            getUserDataUseCase: mockGetUserDataUseCase,
            getStatisticsUseCase: mockGetStatisticsUseCase
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockAddWaterUseCase = nil
        mockGetWeatherUseCase = nil
        mockGetUserDataUseCase = nil
        mockGetStatisticsUseCase = nil
    }

    func testLoadData_Success() async throws {
        // Given
        let expectedUser = User(name: "Test User", dailyGoal: 2000)
        let expectedStats = HydrationStatistics(totalIntake: 1000)
        let expectedTrend = [500.0, 750.0, 1000.0, 1250.0, 1500.0, 1750.0, 2000.0]

        mockGetUserDataUseCase.result = .success(expectedUser)
        mockGetStatisticsUseCase.todayStatsResult = .success(expectedStats)
        mockGetStatisticsUseCase.trendResult = .success(expectedTrend)

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.user?.name, "Test User")
        XCTAssertEqual(sut.dailyGoal, 2000)
        XCTAssertEqual(sut.dailyIntake, 1000)
        XCTAssertEqual(sut.lastSevenDays, expectedTrend)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testAddWater_Success() async throws {
        // Given
        let expectedEntry = WaterEntry(amount: 250, containerType: .glass)
        mockAddWaterUseCase.result = .success(expectedEntry)
        mockGetStatisticsUseCase.todayStatsResult = .success(HydrationStatistics(totalIntake: 250))

        // When
        await sut.addWater(amount: 250, container: .glass)

        // Then
        XCTAssertEqual(sut.dailyIntake, 250)
        XCTAssertEqual(sut.todayEntries.count, 1)
        XCTAssertEqual(sut.todayEntries.first?.amount, 250)
        XCTAssertNil(sut.errorMessage)
    }

    func testAddWater_Failure() async throws {
        // Given
        mockAddWaterUseCase.result = .failure(WaterBuddyError.invalidAmount)

        // When
        await sut.addWater(amount: -100, container: .glass)

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.todayEntries.isEmpty)
    }

    func testPercentageCalculation() {
        // Given
        sut.dailyGoal = 2000
        sut.dailyIntake = 1000

        // When & Then
        XCTAssertEqual(sut.percentage, 50.0, accuracy: 0.1)
    }

    func testGoalAchievement() {
        // Given
        sut.dailyGoal = 2000
        sut.dailyIntake = 2000

        // When & Then
        XCTAssertTrue(sut.isGoalAchieved)
        XCTAssertEqual(sut.remainingAmount, 0)
    }
}

// MARK: - Mock Objects

class MockAddWaterUseCase: AddWaterUseCase {
    var result: Result<WaterEntry, Error> = .success(WaterEntry(amount: 250))

    func execute(amount: Double, container: ContainerType) async throws -> WaterEntry {
        switch result {
        case .success(let entry):
            return entry
        case .failure(let error):
            throw error
        }
    }
}

class MockGetWeatherUseCase: GetWeatherUseCase {
    var result: Result<HydrationRecommendation, Error> = .success(
        HydrationRecommendation(
            recommendedIntake: 2000,
            reason: "Normal hydration recommended"
        )
    )

    func execute() async throws -> HydrationRecommendation {
        switch result {
        case .success(let recommendation):
            return recommendation
        case .failure(let error):
            throw error
        }
    }

    func getCurrentWeather() async throws -> WeatherData {
        return WeatherData(
            temperature: 25,
            humidity: 60,
            condition: .sunny,
            feelsLike: 27,
            location: "Test Location"
        )
    }
}

class MockGetUserDataUseCase: GetUserDataUseCase {
    var result: Result<User, Error> = .success(User())

    func execute() async throws -> User {
        switch result {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }

    func isFirstLaunch() async throws -> Bool {
        return false
    }
}

class MockGetStatisticsUseCase: GetStatisticsUseCase {
    var todayStatsResult: Result<HydrationStatistics, Error> = .success(HydrationStatistics())
    var trendResult: Result<[Double], Error> = .success([])

    func execute(for period: TimePeriod) async throws -> HydrationStatistics {
        switch todayStatsResult {
        case .success(let stats):
            return stats
        case .failure(let error):
            throw error
        }
    }

    func getWeeklyStatistics() async throws -> WeeklyStatistics {
        return WeeklyStatistics(
            startDate: Date().startOfWeek,
            endDate: Date().endOfWeek,
            dailyStats: []
        )
    }

    func getDailyTrend(days: Int) async throws -> [Double] {
        switch trendResult {
        case .success(let trend):
            return trend
        case .failure(let error):
            throw error
        }
    }
}