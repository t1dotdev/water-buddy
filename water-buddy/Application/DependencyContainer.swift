import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()

    // MARK: - Data Sources
    lazy var userDefaultsDataSource: UserDefaultsDataSource = {
        UserDefaultsDataSourceImpl()
    }()

    lazy var localDataSource: LocalDataSource = {
        LocalDataSourceImpl(userDefaults: userDefaultsDataSource)
    }()

    lazy var remoteDataSource: RemoteDataSource = {
        RemoteDataSourceImpl(apiClient: apiClient)
    }()

    lazy var apiClient: APIClient = {
        APIClientImpl()
    }()

    // MARK: - Repositories
    lazy var waterRepository: WaterRepositoryProtocol = {
        WaterRepository(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource
        )
    }()

    lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            userDefaultsDataSource: userDefaultsDataSource
        )
    }()

    lazy var weatherRepository: WeatherRepositoryProtocol = {
        WeatherRepository(
            remoteDataSource: remoteDataSource
        )
    }()

    // MARK: - Use Cases
    lazy var addWaterUseCase: AddWaterUseCase = {
        AddWaterUseCaseImpl(
            waterRepository: waterRepository,
            userRepository: userRepository
        )
    }()

    lazy var getStatisticsUseCase: GetStatisticsUseCase = {
        GetStatisticsUseCaseImpl(
            waterRepository: waterRepository
        )
    }()

    lazy var getWeatherUseCase: GetWeatherUseCase = {
        GetWeatherUseCaseImpl(
            weatherRepository: weatherRepository
        )
    }()

    lazy var manageRemindersUseCase: ManageRemindersUseCase = {
        ManageRemindersUseCaseImpl()
    }()

    lazy var getUserDataUseCase: GetUserDataUseCase = {
        GetUserDataUseCaseImpl(
            userRepository: userRepository
        )
    }()

    lazy var updateUserDataUseCase: UpdateUserDataUseCase = {
        UpdateUserDataUseCaseImpl(
            userRepository: userRepository
        )
    }()

    // MARK: - ViewModels Factory
    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            addWaterUseCase: addWaterUseCase,
            getWeatherUseCase: getWeatherUseCase,
            getUserDataUseCase: getUserDataUseCase,
            getStatisticsUseCase: getStatisticsUseCase
        )
    }

    // Backward compatibility method
    @MainActor 
    func homeViewModel() -> HomeViewModel {
        return makeHomeViewModel()
    }

    @MainActor
    func makeStatisticsViewModel() -> StatisticsViewModel {
        return StatisticsViewModel(
            getStatisticsUseCase: getStatisticsUseCase
        )
    }

    @MainActor
    func makeAddWaterViewModel() -> AddWaterViewModel {
        return AddWaterViewModel(
            addWaterUseCase: addWaterUseCase
        )
    }

    @MainActor
    func makeHistoryViewModel() -> HistoryViewModel {
        return HistoryViewModel(
            waterRepository: waterRepository
        )
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            getUserDataUseCase: getUserDataUseCase,
            updateUserDataUseCase: updateUserDataUseCase,
            manageRemindersUseCase: manageRemindersUseCase
        )
    }

    private init() {}
}