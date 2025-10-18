import UIKit
import Combine
import DGCharts

class StatisticsViewController: UIViewController {
    var viewModel: StatisticsViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var periodSegmentedControl: UISegmentedControl = {
        let periods = TimePeriod.allCases.map { $0.displayName }
        let segmentedControl = UISegmentedControl(items: periods)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        segmentedControl.backgroundColor = Constants.Colors.backgroundSecondary
        segmentedControl.selectedSegmentTintColor = Constants.Colors.primaryBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: Constants.Colors.textPrimary], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentedControl
    }()

    // Main Stats Card
    private lazy var mainStatsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var totalIntakeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.largeTitle
        label.textColor = Constants.Colors.primaryBlue
        label.textAlignment = .center
        label.text = "0ml"
        return label
    }()

    private lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.subheadline
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = NSLocalizedString("period.today", value: "Today", comment: "")
        return label
    }()
    
    private lazy var goalProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = Constants.Colors.primaryBlue
        progress.trackTintColor = Constants.Colors.textTertiary.withAlphaComponent(0.3)
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    private lazy var goalAchievementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = "0% of daily goal"
        return label
    }()
    
    // Summary Cards Container
    private lazy var summaryCardsContainer: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.Dimensions.paddingMedium
        return stack
    }()
    
    private lazy var streakCard: UIView = {
        return createSummaryCard(
            icon: Constants.Images.streak,
            title: "0",
            subtitle: NSLocalizedString("stats.streak_days", value: "Day Streak", comment: ""),
            iconColor: Constants.Colors.warning
        )
    }()
    
    private lazy var averageCard: UIView = {
        return createSummaryCard(
            icon: Constants.Images.waterDrop,
            title: "0ml",
            subtitle: NSLocalizedString("stats.average", value: "Average", comment: ""),
            iconColor: Constants.Colors.primaryBlue
        )
    }()
    
    private lazy var peakHourCard: UIView = {
        return createSummaryCard(
            icon: "clock.fill",
            title: "--:--",
            subtitle: NSLocalizedString("stats.peak_hour", value: "Peak Hour", comment: ""),
            iconColor: Constants.Colors.success
        )
    }()

    // Chart Cards
    private lazy var trendChartCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var containerChartCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.shadowColor = Constants.Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        
        // Configure chart appearance
        chartView.backgroundColor = UIColor.clear
        chartView.gridBackgroundColor = UIColor.clear
        chartView.drawBordersEnabled = false
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = true
        chartView.doubleTapToZoomEnabled = false
        
        // Configure X-axis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = Constants.Colors.textTertiary.withAlphaComponent(0.2)
        xAxis.drawAxisLineEnabled = false
        xAxis.labelTextColor = Constants.Colors.textSecondary
        xAxis.labelFont = FontManager.shared.caption1
        
        // Configure left Y-axis
        let leftAxis = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = Constants.Colors.textTertiary.withAlphaComponent(0.2)
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = Constants.Colors.textSecondary
        leftAxis.labelFont = FontManager.shared.caption1
        leftAxis.axisMinimum = 0
        
        // Configure right Y-axis
        chartView.rightAxis.enabled = false
        
        return chartView
    }()

    private lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        
        // Configure chart appearance
        chartView.backgroundColor = UIColor.clear
        chartView.chartDescription.enabled = false
        chartView.drawHoleEnabled = true
        chartView.holeRadiusPercent = 0.5
        chartView.holeColor = UIColor.clear
        chartView.transparentCircleRadiusPercent = 0.55
        chartView.rotationEnabled = false
        
        // Configure legend
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .center
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.orientation = .horizontal
        chartView.legend.textColor = Constants.Colors.textSecondary
        chartView.legend.font = FontManager.shared.caption1
        
        return chartView
    }()

    private lazy var chartTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("stats.weekly_trend", value: "Weekly Trend", comment: "")
        return label
    }()

    private lazy var containerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("stats.container_usage", value: "Container Usage", comment: "")
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
        viewModel.loadStatistics()
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
        scrollView.refreshControl = refreshControl

        contentView.addSubview(periodSegmentedControl)
        contentView.addSubview(mainStatsCard)
        contentView.addSubview(summaryCardsContainer)
        contentView.addSubview(trendChartCard)
        contentView.addSubview(containerChartCard)

        // Main stats card subviews
        mainStatsCard.addSubview(totalIntakeLabel)
        mainStatsCard.addSubview(periodLabel)
        mainStatsCard.addSubview(goalProgressView)
        mainStatsCard.addSubview(goalAchievementLabel)

        // Summary cards
        summaryCardsContainer.addArrangedSubview(streakCard)
        summaryCardsContainer.addArrangedSubview(averageCard)
        summaryCardsContainer.addArrangedSubview(peakHourCard)
        
        // Chart cards
        trendChartCard.addSubview(chartTitleLabel)
        trendChartCard.addSubview(lineChartView)
        
        containerChartCard.addSubview(containerTitleLabel)
        containerChartCard.addSubview(pieChartView)

        setupConstraints()
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

            // Period selector
            periodSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.paddingLarge),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            periodSegmentedControl.heightAnchor.constraint(equalToConstant: 36),

            // Main stats card
            mainStatsCard.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            mainStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            mainStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            totalIntakeLabel.topAnchor.constraint(equalTo: mainStatsCard.topAnchor, constant: Constants.Dimensions.paddingLarge),
            totalIntakeLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),

            periodLabel.topAnchor.constraint(equalTo: totalIntakeLabel.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            periodLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            
            goalProgressView.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            goalProgressView.leadingAnchor.constraint(equalTo: mainStatsCard.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            goalProgressView.trailingAnchor.constraint(equalTo: mainStatsCard.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            goalProgressView.heightAnchor.constraint(equalToConstant: 4),
            
            goalAchievementLabel.topAnchor.constraint(equalTo: goalProgressView.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            goalAchievementLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            goalAchievementLabel.bottomAnchor.constraint(equalTo: mainStatsCard.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),

            // Summary cards
            summaryCardsContainer.topAnchor.constraint(equalTo: mainStatsCard.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            summaryCardsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            summaryCardsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            summaryCardsContainer.heightAnchor.constraint(equalToConstant: 100),

            // Trend chart card
            trendChartCard.topAnchor.constraint(equalTo: summaryCardsContainer.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            trendChartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            trendChartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            chartTitleLabel.topAnchor.constraint(equalTo: trendChartCard.topAnchor, constant: Constants.Dimensions.paddingLarge),
            chartTitleLabel.leadingAnchor.constraint(equalTo: trendChartCard.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            chartTitleLabel.trailingAnchor.constraint(equalTo: trendChartCard.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            lineChartView.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            lineChartView.leadingAnchor.constraint(equalTo: trendChartCard.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            lineChartView.trailingAnchor.constraint(equalTo: trendChartCard.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            lineChartView.heightAnchor.constraint(equalToConstant: 220),
            lineChartView.bottomAnchor.constraint(equalTo: trendChartCard.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),

            // Container chart card
            containerChartCard.topAnchor.constraint(equalTo: trendChartCard.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            containerChartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            containerChartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            containerTitleLabel.topAnchor.constraint(equalTo: containerChartCard.topAnchor, constant: Constants.Dimensions.paddingLarge),
            containerTitleLabel.leadingAnchor.constraint(equalTo: containerChartCard.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            containerTitleLabel.trailingAnchor.constraint(equalTo: containerChartCard.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            pieChartView.topAnchor.constraint(equalTo: containerTitleLabel.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            pieChartView.leadingAnchor.constraint(equalTo: containerChartCard.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            pieChartView.trailingAnchor.constraint(equalTo: containerChartCard.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),
            pieChartView.heightAnchor.constraint(equalToConstant: 220),
            pieChartView.bottomAnchor.constraint(equalTo: containerChartCard.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),
            
            containerChartCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("stats.title", value: "Statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(waterIntakeUpdated),
            name: Notification.Name("WaterIntakeUpdated"),
            object: nil
        )
    }
    
    @objc private func waterIntakeUpdated(_ notification: Notification) {
        viewModel.loadStatistics()
    }
    
    @objc private func refreshData() {
        viewModel.refreshData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSummaryCard(icon: String, title: String, subtitle: String, iconColor: UIColor) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Constants.Colors.backgroundSecondary
        card.layer.cornerRadius = Constants.Dimensions.cornerRadius
        card.layer.shadowColor = Constants.Colors.shadow.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.layer.shadowOpacity = 0.1
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = FontManager.shared.title3
        titleLabel.textColor = Constants.Colors.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = FontManager.shared.caption1
        subtitleLabel.textColor = Constants.Colors.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0
        
        card.addSubview(iconImageView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: Constants.Dimensions.paddingMedium),
            iconImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Constants.Dimensions.paddingSmall),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Constants.Dimensions.paddingSmall),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Constants.Dimensions.paddingSmall),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Constants.Dimensions.paddingSmall),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -Constants.Dimensions.paddingSmall)
        ])
        
        return card
    }
    
    private func updateSummaryCard(_ card: UIView, title: String) {
        if let titleLabel = card.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.font == FontManager.shared.title3 }) {
            titleLabel.text = title
        }
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

        viewModel.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statistics in
                self?.updateUI(with: statistics)
            }
            .store(in: &cancellables)

        viewModel.$currentPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] period in
                self?.periodLabel.text = period.displayName
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

    @objc private func periodChanged() {
        let selectedPeriod = TimePeriod.allCases[periodSegmentedControl.selectedSegmentIndex]
        viewModel.loadStatistics(for: selectedPeriod)
    }

    // MARK: - Private Methods

    private func updateUI(with statistics: HydrationStatistics?) {
        guard let stats = statistics else {
            totalIntakeLabel.text = "0ml"
            goalProgressView.progress = 0
            goalAchievementLabel.text = "0% of daily goal"
            updateSummaryCard(streakCard, title: "0")
            updateSummaryCard(averageCard, title: "0ml")
            updateSummaryCard(peakHourCard, title: "--:--")
            lineChartView.clear()
            pieChartView.clear()
            return
        }

        // Update main stats
        totalIntakeLabel.text = stats.formattedTotalIntake
        let progress = Float(stats.completionPercentage / 100.0)
        goalProgressView.progress = progress
        goalAchievementLabel.text = String(format: "%.0f%% of daily goal", stats.completionPercentage)
        
        // Update goal achievement color
        if stats.goalAchieved {
            goalProgressView.progressTintColor = Constants.Colors.success
            goalAchievementLabel.textColor = Constants.Colors.success
        } else {
            goalProgressView.progressTintColor = Constants.Colors.primaryBlue
            goalAchievementLabel.textColor = Constants.Colors.textSecondary
        }
        
        // Update summary cards
        updateSummaryCard(streakCard, title: "\(stats.streakCount)")
        updateSummaryCard(averageCard, title: String(format: "%.0fml", stats.averageIntake))
        
        if let peakHour = stats.peakHour {
            updateSummaryCard(peakHourCard, title: String(format: "%02d:00", peakHour))
        } else {
            updateSummaryCard(peakHourCard, title: "--:--")
        }
        
        // Update charts
        updateLineChart(with: stats.weeklyTrend)
        updatePieChart(with: stats.containerUsage)
    }

    private func updateLineChart(with weeklyData: [Double]) {
        var entries: [ChartDataEntry] = []
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        for (index, value) in weeklyData.enumerated() {
            let entry = ChartDataEntry(x: Double(index), y: value)
            entries.append(entry)
        }
        
        guard !entries.isEmpty else {
            lineChartView.clear()
            return
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Daily Intake")
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 6
        dataSet.circleHoleRadius = 3
        dataSet.circleColors = [Constants.Colors.primaryBlue]
        dataSet.lineWidth = 3
        dataSet.colors = [Constants.Colors.primaryBlue]
        dataSet.drawValuesEnabled = false
        dataSet.mode = .cubicBezier
        dataSet.fillAlpha = 0.15
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = Constants.Colors.primaryBlue
        dataSet.highlightColor = Constants.Colors.primaryBlue
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let chartData = LineChartData(dataSet: dataSet)
        lineChartView.data = chartData
        
        // Configure X-axis labels
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayNames)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = dayNames.count
        
        lineChartView.animate(xAxisDuration: Constants.Animation.defaultDuration)
    }

    private func updatePieChart(with containerUsage: [ContainerType: Int]) {
        var entries: [PieChartDataEntry] = []
        var colors: [UIColor] = []
        
        for (container, count) in containerUsage.sorted(by: { $0.value > $1.value }) {
            let entry = PieChartDataEntry(value: Double(count), label: container.displayName)
            entries.append(entry)
            colors.append(getColorForContainer(container))
        }
        
        guard !entries.isEmpty else {
            pieChartView.clear()
            return
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors
        dataSet.drawValuesEnabled = true
        dataSet.valueTextColor = Constants.Colors.textPrimary
        dataSet.valueFont = FontManager.shared.caption1
        dataSet.sliceSpace = 2
        dataSet.selectionShift = 8
        
        let chartData = PieChartData(dataSet: dataSet)
        chartData.setValueFormatter(DefaultValueFormatter(formatter: NumberFormatter()))
        
        pieChartView.data = chartData
        pieChartView.animate(yAxisDuration: Constants.Animation.defaultDuration, easingOption: .easeOutBack)
    }

    private func getColorForContainer(_ container: ContainerType) -> UIColor {
        switch container {
        case .glass:
            return Constants.Colors.primaryBlue
        case .bottle:
            return Constants.Colors.success
        case .cup:
            return Constants.Colors.warning
        case .mug:
            return Constants.Colors.error
        case .custom:
            return Constants.Colors.textSecondary
        }
    }
}

// MARK: - ChartViewDelegate

extension StatisticsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Handle chart value selection if needed
    }
}