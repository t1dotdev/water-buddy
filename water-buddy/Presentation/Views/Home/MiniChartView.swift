import UIKit
import DGCharts

class MiniChartView: UIView {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("chart.weekly_progress", value: "Weekly Progress", comment: "")
        return label
    }()

    private lazy var barChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        
        // Configure chart appearance
        chartView.backgroundColor = .clear
        chartView.gridBackgroundColor = UIColor.clear
        chartView.drawBordersEnabled = false
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        
        // Configure X-axis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelTextColor = Constants.Colors.textSecondary
        xAxis.labelFont = FontManager.shared.caption1
        xAxis.valueFormatter = WeekDayFormatter()
        
        // Configure left Y-axis
        let leftAxis = chartView.leftAxis
        leftAxis.enabled = false
        
        // Configure right Y-axis
        chartView.rightAxis.enabled = false
        
        return chartView
    }()

    private var data: [Double] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(barChartView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            barChartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            barChartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            barChartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            barChartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium),
            barChartView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func setData(_ weeklyData: [Double]) {
        data = weeklyData
        
        var entries: [BarChartDataEntry] = []
        
        for (index, value) in weeklyData.enumerated() {
            let entry = BarChartDataEntry(x: Double(index), y: value)
            entries.append(entry)
        }
        
        let dataSet = BarChartDataSet(entries: entries, label: "Water Intake")
        dataSet.colors = weeklyData.map { getColorForValue($0) }
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false
        
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.7
        
        barChartView.data = chartData
        barChartView.animate(yAxisDuration: Constants.Animation.defaultDuration)
    }

    private func getColorForValue(_ value: Double) -> UIColor {
        let goalProgress = value / 2000.0
        
        switch goalProgress {
        case 0..<0.5:
            return Constants.Colors.error
        case 0.5..<0.8:
            return Constants.Colors.warning
        case 0.8..<1.0:
            return Constants.Colors.primaryBlue
        default:
            return Constants.Colors.success
        }
    }
}

// MARK: - ChartViewDelegate

extension MiniChartView: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Handle tap on chart if needed
    }
}

// MARK: - Custom Formatter

class WeekDayFormatter: AxisValueFormatter {
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if index >= 0 && index < weekdays.count {
            return weekdays[index]
        }
        return ""
    }
}