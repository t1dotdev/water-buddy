import UIKit
import Combine

class HomeViewController: UIViewController {
    var viewModel: HomeViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var progressCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var progressCardHeader: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.title2
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("home.progress.title", value: "Today's Progress", comment: "")
        return label
    }()
    
    private lazy var progressSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.text = NSLocalizedString("home.progress.subtitle", value: "Stay hydrated, stay healthy", comment: "")
        return label
    }()

    private lazy var progressCircleView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()



    private lazy var statsCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var statsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("home.stats.title", value: "Your Streak", comment: "")
        return label
    }()
    
    private lazy var statsSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.text = NSLocalizedString("home.stats.subtitle", value: "Keep the momentum going", comment: "")
        return label
    }()

    private lazy var streakView: StreakView = {
        let view = StreakView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var quickAddContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var quickAddHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var quickAddTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("home.quick_add.title", value: "Quick Add", comment: "")
        return label
    }()
    
    private lazy var quickAddSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.text = NSLocalizedString("home.quick_add.subtitle", value: "Tap to add water quickly", comment: "")
        return label
    }()

    private lazy var quickAddStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.Dimensions.paddingMedium
        return stackView
    }()

    private lazy var weatherCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var weatherHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var weatherTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("home.weather.title", value: "Weather Insight", comment: "")
        return label
    }()
    
    private lazy var weatherSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.text = NSLocalizedString("home.weather.subtitle", value: "Hydration recommendations", comment: "")
        return label
    }()

    private lazy var weatherView: WeatherView = {
        let view = WeatherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var chartCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var chartHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var chartTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("home.chart.title", value: "Weekly Overview", comment: "")
        return label
    }()
    
    private lazy var chartSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.text = NSLocalizedString("home.chart.subtitle", value: "Your hydration patterns", comment: "")
        return label
    }()

    private lazy var weeklyChartView: MiniChartView = {
        let view = MiniChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var motivationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.callout
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = .clear
        return label
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Always reload data when view appears to ensure we have the latest updates
        viewModel.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Force a refresh of the progress view
        progressCircleView.setProgress(viewModel.percentage / 100.0, animated: false)
        updateProgressView()

        // Add staggered card animations
        animateCardsEntry()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.backgroundPrimary

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(progressCardView)
        contentView.addSubview(statsCardView)
        contentView.addSubview(quickAddContainerView)
        contentView.addSubview(weatherCardView)
        contentView.addSubview(chartCardView)
        contentView.addSubview(motivationLabel)

        progressCardView.addSubview(progressCardHeader)
        progressCardView.addSubview(progressCircleView)
        progressCardHeader.addSubview(progressTitleLabel)
        progressCardHeader.addSubview(progressSubtitleLabel)
        
        statsCardView.addSubview(statsHeaderView)
        statsCardView.addSubview(streakView)
        statsHeaderView.addSubview(statsTitleLabel)
        statsHeaderView.addSubview(statsSubtitleLabel)
        
        weatherCardView.addSubview(weatherHeaderView)
        weatherCardView.addSubview(weatherView)
        weatherHeaderView.addSubview(weatherTitleLabel)
        weatherHeaderView.addSubview(weatherSubtitleLabel)
        
        chartCardView.addSubview(chartHeaderView)
        chartCardView.addSubview(weeklyChartView)
        chartHeaderView.addSubview(chartTitleLabel)
        chartHeaderView.addSubview(chartSubtitleLabel)
        
        quickAddContainerView.addSubview(quickAddHeaderView)
        quickAddContainerView.addSubview(quickAddStackView)
        quickAddHeaderView.addSubview(quickAddTitleLabel)
        quickAddHeaderView.addSubview(quickAddSubtitleLabel)

        setupQuickAddButtons()
        setupConstraints()
        setupRefreshControl()
    }

    private func setupQuickAddButtons() {
        let unit = viewModel.user?.preferredUnit ?? .milliliters
        let mlAmounts = Constants.WaterBuddy.getQuickAddAmounts(for: unit).prefix(3)
        let displayAmounts = Constants.WaterBuddy.getDisplayAmounts(for: unit).prefix(3)

        for (mlAmount, displayAmount) in zip(mlAmounts, displayAmounts) {
            let button = QuickAddButton(amount: mlAmount, displayAmount: displayAmount, unit: unit)
            button.addTarget(self, action: #selector(quickAddButtonTapped), for: .touchUpInside)
            quickAddStackView.addArrangedSubview(button)
        }
    }

    private func updateQuickAddButtonUnits() {
        // Remove old buttons and recreate with new amounts
        quickAddStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setupQuickAddButtons()
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Top spacing since greeting removed
            progressCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.paddingMedium),

            // Progress card
            progressCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            progressCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            progressCardHeader.topAnchor.constraint(equalTo: progressCardView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            progressCardHeader.leadingAnchor.constraint(equalTo: progressCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            progressCardHeader.trailingAnchor.constraint(equalTo: progressCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            
            progressTitleLabel.topAnchor.constraint(equalTo: progressCardHeader.topAnchor),
            progressTitleLabel.leadingAnchor.constraint(equalTo: progressCardHeader.leadingAnchor),
            progressTitleLabel.trailingAnchor.constraint(equalTo: progressCardHeader.trailingAnchor),
            
            progressSubtitleLabel.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 2),
            progressSubtitleLabel.leadingAnchor.constraint(equalTo: progressCardHeader.leadingAnchor),
            progressSubtitleLabel.trailingAnchor.constraint(equalTo: progressCardHeader.trailingAnchor),
            progressSubtitleLabel.bottomAnchor.constraint(equalTo: progressCardHeader.bottomAnchor),

            progressCircleView.topAnchor.constraint(equalTo: progressCardHeader.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            progressCircleView.centerXAnchor.constraint(equalTo: progressCardView.centerXAnchor),
            progressCircleView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.progressCircleSize),
            progressCircleView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.progressCircleSize),
            progressCircleView.bottomAnchor.constraint(equalTo: progressCardView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Quick add section
            quickAddContainerView.topAnchor.constraint(equalTo: progressCardView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            statsHeaderView.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            statsHeaderView.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            statsHeaderView.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            
            statsTitleLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor),
            statsTitleLabel.leadingAnchor.constraint(equalTo: statsHeaderView.leadingAnchor),
            statsTitleLabel.trailingAnchor.constraint(equalTo: statsHeaderView.trailingAnchor),
            
            statsSubtitleLabel.topAnchor.constraint(equalTo: statsTitleLabel.bottomAnchor, constant: 2),
            statsSubtitleLabel.leadingAnchor.constraint(equalTo: statsHeaderView.leadingAnchor),
            statsSubtitleLabel.trailingAnchor.constraint(equalTo: statsHeaderView.trailingAnchor),
            statsSubtitleLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor),

            streakView.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            streakView.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            streakView.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            streakView.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            quickAddHeaderView.topAnchor.constraint(equalTo: quickAddContainerView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddHeaderView.leadingAnchor.constraint(equalTo: quickAddContainerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddHeaderView.trailingAnchor.constraint(equalTo: quickAddContainerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            quickAddTitleLabel.topAnchor.constraint(equalTo: quickAddHeaderView.topAnchor),
            quickAddTitleLabel.leadingAnchor.constraint(equalTo: quickAddHeaderView.leadingAnchor),
            quickAddTitleLabel.trailingAnchor.constraint(equalTo: quickAddHeaderView.trailingAnchor),

            quickAddSubtitleLabel.topAnchor.constraint(equalTo: quickAddTitleLabel.bottomAnchor, constant: 2),
            quickAddSubtitleLabel.leadingAnchor.constraint(equalTo: quickAddHeaderView.leadingAnchor),
            quickAddSubtitleLabel.trailingAnchor.constraint(equalTo: quickAddHeaderView.trailingAnchor),
            quickAddSubtitleLabel.bottomAnchor.constraint(equalTo: quickAddHeaderView.bottomAnchor),

            quickAddStackView.topAnchor.constraint(equalTo: quickAddHeaderView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddStackView.leadingAnchor.constraint(equalTo: quickAddContainerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            quickAddStackView.trailingAnchor.constraint(equalTo: quickAddContainerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            quickAddStackView.bottomAnchor.constraint(equalTo: quickAddContainerView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Weather card
            weatherCardView.topAnchor.constraint(equalTo: quickAddContainerView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Stats card
            statsCardView.topAnchor.constraint(equalTo: weatherCardView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            statsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            statsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            weatherHeaderView.topAnchor.constraint(equalTo: weatherCardView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherHeaderView.leadingAnchor.constraint(equalTo: weatherCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherHeaderView.trailingAnchor.constraint(equalTo: weatherCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            
            weatherTitleLabel.topAnchor.constraint(equalTo: weatherHeaderView.topAnchor),
            weatherTitleLabel.leadingAnchor.constraint(equalTo: weatherHeaderView.leadingAnchor),
            weatherTitleLabel.trailingAnchor.constraint(equalTo: weatherHeaderView.trailingAnchor),
            
            weatherSubtitleLabel.topAnchor.constraint(equalTo: weatherTitleLabel.bottomAnchor, constant: 2),
            weatherSubtitleLabel.leadingAnchor.constraint(equalTo: weatherHeaderView.leadingAnchor),
            weatherSubtitleLabel.trailingAnchor.constraint(equalTo: weatherHeaderView.trailingAnchor),
            weatherSubtitleLabel.bottomAnchor.constraint(equalTo: weatherHeaderView.bottomAnchor),

            weatherView.topAnchor.constraint(equalTo: weatherHeaderView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherView.leadingAnchor.constraint(equalTo: weatherCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherView.trailingAnchor.constraint(equalTo: weatherCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            weatherView.bottomAnchor.constraint(equalTo: weatherCardView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Chart card
            chartCardView.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            chartCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            chartCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            chartHeaderView.topAnchor.constraint(equalTo: chartCardView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            chartHeaderView.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            chartHeaderView.trailingAnchor.constraint(equalTo: chartCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            
            chartTitleLabel.topAnchor.constraint(equalTo: chartHeaderView.topAnchor),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartHeaderView.leadingAnchor),
            chartTitleLabel.trailingAnchor.constraint(equalTo: chartHeaderView.trailingAnchor),
            
            chartSubtitleLabel.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 2),
            chartSubtitleLabel.leadingAnchor.constraint(equalTo: chartHeaderView.leadingAnchor),
            chartSubtitleLabel.trailingAnchor.constraint(equalTo: chartHeaderView.trailingAnchor),
            chartSubtitleLabel.bottomAnchor.constraint(equalTo: chartHeaderView.bottomAnchor),

            weeklyChartView.topAnchor.constraint(equalTo: chartHeaderView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            weeklyChartView.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            weeklyChartView.trailingAnchor.constraint(equalTo: chartCardView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            weeklyChartView.heightAnchor.constraint(equalToConstant: 120),
            weeklyChartView.bottomAnchor.constraint(equalTo: chartCardView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Motivation label
            motivationLabel.topAnchor.constraint(equalTo: chartCardView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            motivationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            motivationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            motivationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            motivationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = "Water Buddy"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(waterIntakeUpdated),
            name: Notification.Name("WaterIntakeUpdated"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dailyGoalUpdated),
            name: Notification.Name("DailyGoalUpdated"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferredUnitUpdated),
            name: Notification.Name("PreferredUnitUpdated"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goalCompleted),
            name: Notification.Name("GoalCompletedNotification"),
            object: nil
        )
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)


        viewModel.$percentage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] percentage in
                self?.progressCircleView.setProgress(percentage / 100.0, animated: true)
            }
            .store(in: &cancellables)

        viewModel.$dailyIntake
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProgressView()
            }
            .store(in: &cancellables)

        viewModel.$dailyGoal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProgressView()
            }
            .store(in: &cancellables)

        viewModel.$hydrationRecommendation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProgressView()
            }
            .store(in: &cancellables)

        viewModel.$streakCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] streak in
                self?.streakView.setStreak(streak)
            }
            .store(in: &cancellables)

        viewModel.$weatherRecommendation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recommendation in
                self?.weatherView.setRecommendation(recommendation)
            }
            .store(in: &cancellables)

        viewModel.$currentTemperature
            .receive(on: DispatchQueue.main)
            .sink { [weak self] temperature in
                if temperature > 0 {
                    self?.weatherView.setTemperature(temperature)
                }
            }
            .store(in: &cancellables)

        viewModel.$lastSevenDays
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.weeklyChartView.setData(data)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(viewModel.$dailyIntake, viewModel.$dailyGoal)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.motivationLabel.text = self?.viewModel.motivationalMessage

            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(title: NSLocalizedString("alert.error", value: "Error", comment: ""), message: error)
            }
            .store(in: &cancellables)

        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateQuickAddButtonUnits()
            }
            .store(in: &cancellables)
    }

    // MARK: - Helper Methods

    private func updateProgressView() {
        let intake = viewModel.formattedDailyIntake
        let baseGoal = viewModel.formattedDailyGoal
        let recommendedGoal = viewModel.formattedRecommendedGoal

        progressCircleView.setGoals(
            intake: intake,
            baseGoal: baseGoal,
            recommendedGoal: recommendedGoal,
            showRecommendation: viewModel.shouldShowRecommendation
        )
    }

    // MARK: - Actions

    @objc private func quickAddButtonTapped(_ sender: QuickAddButton) {
        let amount = sender.amount
        viewModel.addWater(amount: amount, container: .glass)

        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Button animation
        sender.animatePress()

        // Add subtle card animation
        UIView.animate(withDuration: 0.1, animations: {
            self.progressCardView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.progressCardView.transform = .identity
            }
        }
    }

    @objc private func profileButtonTapped() {
        // Navigate to profile/settings
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = Constants.TabBar.Tab.settings.rawValue
        }
    }

    @objc private func handleRefresh() {
        viewModel.refreshData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func waterIntakeUpdated(_ notification: Notification) {
        // Reload data immediately when water is added
        viewModel.loadData()
        
        // Optional: Show a subtle animation on the progress circle
        UIView.animate(withDuration: 0.3) {
            self.progressCircleView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.progressCircleView.transform = .identity
            }
        }
    }
    
    @objc private func dailyGoalUpdated(_ notification: Notification) {
        // Reload data immediately when daily goal is updated
        viewModel.loadData()

        // Update the goal immediately if provided in notification
        if let userInfo = notification.userInfo,
           let newGoal = userInfo["newGoal"] as? Double {
            viewModel.dailyGoal = newGoal
            viewModel.calculateProgress()

            // Explicitly update the progress view with new goal
            updateProgressView()
            progressCircleView.setProgress(viewModel.percentage / 100.0, animated: true)
        }

        // Show a subtle animation on the progress circle
        UIView.animate(withDuration: 0.3) {
            self.progressCircleView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.progressCircleView.transform = .identity
            }
        }
    }

    @objc private func preferredUnitUpdated(_ notification: Notification) {
        // Reload data to update all unit displays
        viewModel.loadData()

        // Update quick add buttons
        updateQuickAddButtonUnits()

        // Update progress view
        updateProgressView()
    }

    @objc private func goalCompleted(_ notification: Notification) {
        // Extract intake amount from notification
        guard let intake = notification.userInfo?["intake"] as? Double else {
            return
        }

        // Check if we should show confetti for this intake level
        guard ConfettiTracker.shared.shouldShowConfetti(currentIntake: intake) else {
            return
        }

        // Show confetti animation
        showConfetti()

        // Mark confetti as shown with current intake
        ConfettiTracker.shared.markConfettiShown(intake: intake)
    }

    // MARK: - Private Methods

    
    // MARK: - Animation Methods

    private func animateCardsEntry() {
        let cards = [progressCardView, quickAddContainerView, weatherCardView, statsCardView, chartCardView]

        for (index, card) in cards.enumerated() {
            card.transform = CGAffineTransform(translationX: 0, y: 50)
            card.alpha = 0

            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction],
                animations: {
                    card.transform = .identity
                    card.alpha = 1.0
                }
            )
        }
    }

    private func showConfetti() {
        let confettiView = ConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.start {
            // Confetti will auto-remove after animation
        }
    }


}