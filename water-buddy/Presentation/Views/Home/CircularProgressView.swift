import UIKit

class CircularProgressView: UIView {

    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    private let glowLayer = CAShapeLayer()

    private lazy var intakeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.waterAmount
        label.textColor = Constants.Colors.primaryBlue
        label.textAlignment = .center
        label.text = "0ml"
        return label
    }()

    private lazy var goalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.subheadline
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = "of 2000ml"
        return label
    }()

    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textTertiary
        label.textAlignment = .center
        label.text = "0%"
        return label
    }()

    private var currentProgress: Double = 0.0

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabels()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    // MARK: - Setup Methods

    private func setupLayers() {
        // Background circle
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = Constants.Colors.lightBlue.cgColor
        backgroundLayer.lineWidth = 12
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)

        // Glow effect layer
        glowLayer.fillColor = UIColor.clear.cgColor
        glowLayer.lineWidth = 16
        glowLayer.lineCap = .round
        glowLayer.strokeEnd = 0
        glowLayer.shadowColor = Constants.Colors.primaryBlue.cgColor
        glowLayer.shadowRadius = 8
        glowLayer.shadowOpacity = 0.3
        glowLayer.shadowOffset = .zero
        layer.addSublayer(glowLayer)

        // Gradient layer setup
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        layer.addSublayer(gradientLayer)

        // Progress circle
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 12
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        gradientLayer.mask = progressLayer


    }

    private func setupLabels() {
        addSubview(intakeLabel)
        addSubview(goalLabel)
        addSubview(percentageLabel)

        NSLayoutConstraint.activate([
            intakeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            intakeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),

            goalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            goalLabel.topAnchor.constraint(equalTo: intakeLabel.bottomAnchor, constant: 4),

            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 8)
        ])
    }

    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 8

        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )

        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        glowLayer.path = circularPath.cgPath

        // Update gradient frame and ensure it stays in the right position
        gradientLayer.frame = bounds
        
        // Ensure gradient layer stays behind progress layer
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, below: progressLayer)
        }
    }



    // MARK: - Public Methods

    func setProgress(_ progress: Double, animated: Bool = true) {
        let clampedProgress = max(0, min(1, progress))
        currentProgress = clampedProgress

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.duration = Constants.Animation.defaultDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
            glowLayer.add(animation, forKey: "glowAnimation")


        }

        progressLayer.strokeEnd = CGFloat(clampedProgress)
        glowLayer.strokeEnd = CGFloat(clampedProgress)

        // Update percentage label
        let percentage = Int(clampedProgress * 100)
        percentageLabel.text = "\(percentage)%"

        // Update layer appearance based on progress
        updateAppearanceForProgress(clampedProgress)


    }

    func setIntake(_ intake: String, goal: String) {
        intakeLabel.text = intake
        goalLabel.text = String(format: NSLocalizedString("progress.of_goal", value: "of %@", comment: ""), goal)
    }

    func setGoals(intake: String, baseGoal: String, recommendedGoal: String?, showRecommendation: Bool) {
        intakeLabel.text = intake

        if showRecommendation, let recommended = recommendedGoal {
            // Format: "of 2000ml → 2400ml"
            let goalText = String(format: NSLocalizedString("progress.of_goal_with_recommendation", value: "of %@ → %@", comment: ""), baseGoal, recommended)
            goalLabel.text = goalText
        } else {
            // Format: "of 2000ml"
            goalLabel.text = String(format: NSLocalizedString("progress.of_goal", value: "of %@", comment: ""), baseGoal)
        }
    }

    private func updateAppearanceForProgress(_ progress: Double) {
        let (startColor, endColor): (UIColor, UIColor)

        switch progress {
        case 0..<0.25:
            startColor = Constants.Colors.error
            endColor = Constants.Colors.warning
        case 0.25..<0.5:
            startColor = Constants.Colors.warning
            endColor = Constants.Colors.primaryBlue
        case 0.5..<0.75:
            startColor = Constants.Colors.primaryBlue
            endColor = Constants.Colors.success
        case 0.75..<1.0:
            startColor = Constants.Colors.primaryBlue
            endColor = Constants.Colors.success
        default:
            startColor = Constants.Colors.success
            endColor = UIColor.systemGreen.withAlphaComponent(0.8)
        }

        // Update gradient colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // Update glow color
        glowLayer.strokeColor = endColor.cgColor
        
        intakeLabel.textColor = endColor

    }
}