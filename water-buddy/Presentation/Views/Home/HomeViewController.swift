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
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.12
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.05).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.02).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        label.font = FontManager.shared.title3
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

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.title2
        label.textColor = Constants.Colors.textPrimary
        label.textAlignment = .left
        return label
    }()

    private lazy var timeBasedMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.callout
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private lazy var statsCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        
        // Add gradient border effect
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemOrange.withAlphaComponent(0.3).cgColor,
            UIColor.systemOrange.withAlphaComponent(0.1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        
        // Add subtle gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGreen.withAlphaComponent(0.03).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.03).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        
        // Add weather-themed gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemCyan.withAlphaComponent(0.05).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.02).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        
        // Add chart-themed gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.03).cgColor,
            UIColor.systemIndigo.withAlphaComponent(0.03).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        
        // Add subtle styling
        label.layer.cornerRadius = 8
        label.backgroundColor = Constants.Colors.backgroundSecondary.withAlphaComponent(0.5)
        label.layer.borderWidth = 1
        label.layer.borderColor = Constants.Colors.separator.withAlphaComponent(0.3).cgColor
        
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
        progressCircleView.setIntake(viewModel.formattedDailyIntake, goal: viewModel.formattedDailyGoal)
        
        // Add staggered card animations
        animateCardsEntry()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient layers for all cards
        updateGradientLayers()
    }
    
    private func updateGradientLayers() {
        updateCardGradient(progressCardView)
        updateCardGradient(statsCardView)
        updateCardGradient(quickAddContainerView)
        updateCardGradient(weatherCardView)
        updateCardGradient(chartCardView)
    }
    
    private func updateCardGradient(_ cardView: UIView) {
        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = cardView.bounds
        }
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.backgroundPrimary

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(greetingLabel)
        contentView.addSubview(timeBasedMessageLabel)
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
        
        // Add hover effects to cards
        addCardHoverEffect(to: progressCardView)
        addCardHoverEffect(to: statsCardView)
        addCardHoverEffect(to: weatherCardView)
        addCardHoverEffect(to: chartCardView)
    }

    private func setupQuickAddButtons() {
        let amounts = Constants.WaterBuddy.quickAddAmounts.prefix(3)

        for amount in amounts {
            let button = QuickAddButton(amount: amount)
            button.addTarget(self, action: #selector(quickAddButtonTapped), for: .touchUpInside)
            quickAddStackView.addArrangedSubview(button)
        }
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

            // Greeting section
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.paddingLarge),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            timeBasedMessageLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
            timeBasedMessageLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            timeBasedMessageLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),

            // Progress card
            progressCardView.topAnchor.constraint(equalTo: timeBasedMessageLabel.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            progressCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            progressCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            progressCardHeader.topAnchor.constraint(equalTo: progressCardView.topAnchor, constant: Constants.Dimensions.paddingLarge),
            progressCardHeader.leadingAnchor.constraint(equalTo: progressCardView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            progressCardHeader.trailingAnchor.constraint(equalTo: progressCardView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            
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
            progressCircleView.bottomAnchor.constraint(equalTo: progressCardView.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),

            // Stats card
            statsCardView.topAnchor.constraint(equalTo: progressCardView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            statsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            statsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

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

            // Quick add section
            quickAddContainerView.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            quickAddContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            quickAddContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

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
            weatherCardView.topAnchor.constraint(equalTo: quickAddContainerView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            weatherCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            weatherCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

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
            chartCardView.topAnchor.constraint(equalTo: weatherCardView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            chartCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            chartCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

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
            motivationLabel.topAnchor.constraint(equalTo: chartCardView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            motivationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            motivationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            motivationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            motivationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("home.title", value: "Water Tracker", comment: "")
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

        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateGreeting(for: user)
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
            .sink { [weak self] intake in
                guard let self = self else { return }
                self.progressCircleView.setIntake(self.viewModel.formattedDailyIntake, goal: self.viewModel.formattedDailyGoal)
            }
            .store(in: &cancellables)

        viewModel.$dailyGoal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.progressCircleView.setIntake(self.viewModel.formattedDailyIntake, goal: self.viewModel.formattedDailyGoal)
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
            progressCircleView.setIntake(viewModel.formattedDailyIntake, goal: viewModel.formattedDailyGoal)
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

    // MARK: - Private Methods

    private func updateGreeting(for user: User?) {
        guard let user = user else { return }

        let hour = Calendar.current.component(.hour, from: Date())
        let greetingTime: String
        let contextualMessage: String

        switch hour {
        case 5..<12:
            greetingTime = NSLocalizedString("greeting.morning", value: "Good Morning", comment: "")
            contextualMessage = NSLocalizedString("message.morning", value: "Start your day with hydration", comment: "")
        case 12..<17:
            greetingTime = NSLocalizedString("greeting.afternoon", value: "Good Afternoon", comment: "")
            contextualMessage = NSLocalizedString("message.afternoon", value: "Keep up the great work", comment: "")
        case 17..<22:
            greetingTime = NSLocalizedString("greeting.evening", value: "Good Evening", comment: "")
            contextualMessage = NSLocalizedString("message.evening", value: "Don't forget to hydrate", comment: "")
        default:
            greetingTime = NSLocalizedString("greeting.night", value: "Good Night", comment: "")
            contextualMessage = NSLocalizedString("message.night", value: "Rest well, hydrate tomorrow", comment: "")
        }

        greetingLabel.text = "\(greetingTime), \(user.name)!"
        timeBasedMessageLabel.text = contextualMessage
        
        // Add subtle text animation
        animateGreetingLabels()
    }
    
    // MARK: - Animation Methods
    
    private func animateCardsEntry() {
        let cards = [progressCardView, statsCardView, quickAddContainerView, weatherCardView, chartCardView]
        
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
    
    private func animateGreetingLabels() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.allowUserInteraction],
            animations: {
                self.greetingLabel.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.greetingLabel.transform = .identity
                }
            )
        }
    }
    
    private func addCardHoverEffect(to card: UIView) {
        let hoverGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleCardHover(_:)))
        hoverGesture.minimumPressDuration = 0
        card.addGestureRecognizer(hoverGesture)
    }
    
    @objc private func handleCardHover(_ gesture: UILongPressGestureRecognizer) {
        guard let card = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                card.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                card.layer.shadowOpacity = 0.2
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                card.transform = .identity
                card.layer.shadowOpacity = 0.1
            }
        default:
            break
        }
    }

}