import UIKit

class WeatherView: UIView {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constants.Images.weather)
        imageView.tintColor = Constants.Colors.primaryBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("weather.hydration_tip", value: "Hydration Tip", comment: "")
        return label
    }()

    private lazy var recommendationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.subheadline
        label.textColor = Constants.Colors.textSecondary
        label.numberOfLines = 0
        label.text = NSLocalizedString("weather.loading", value: "Loading weather data...", comment: "")
        return label
    }()

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

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(recommendationLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.Dimensions.paddingMedium),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Dimensions.paddingSmall),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            recommendationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            recommendationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            recommendationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            recommendationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.Dimensions.paddingMedium)
        ])
    }

    func setRecommendation(_ recommendation: String) {
        UIView.transition(with: recommendationLabel, duration: Constants.Animation.fastDuration, options: .transitionCrossDissolve, animations: {
            self.recommendationLabel.text = recommendation
        })

        // Update icon based on recommendation content
        updateIcon(for: recommendation)
    }

    private func updateIcon(for recommendation: String) {
        let lowercased = recommendation.lowercased()
        var systemImageName = Constants.Images.weather
        var tintColor = Constants.Colors.primaryBlue

        if lowercased.contains("hot") || lowercased.contains("increase") {
            systemImageName = "thermometer.sun.fill"
            tintColor = Constants.Colors.error
        } else if lowercased.contains("humid") {
            systemImageName = "humidity.fill"
            tintColor = Constants.Colors.warning
        } else if lowercased.contains("dry") {
            systemImageName = "sun.max.fill"
            tintColor = Constants.Colors.warning
        }

        UIView.transition(with: iconImageView, duration: Constants.Animation.fastDuration, options: .transitionCrossDissolve, animations: {
            self.iconImageView.image = UIImage(systemName: systemImageName)
            self.iconImageView.tintColor = tintColor
        })
    }
}