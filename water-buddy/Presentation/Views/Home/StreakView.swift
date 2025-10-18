import UIKit

class StreakView: UIView {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constants.Images.streak)
        imageView.tintColor = Constants.Colors.warning
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = NSLocalizedString("streak.description", value: "day streak", comment: "")
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
        backgroundColor = Constants.Colors.backgroundSecondary
        layer.cornerRadius = Constants.Dimensions.cornerRadius
        
        // Enhanced shadow
        layer.shadowColor = Constants.Colors.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.08

        addSubview(iconImageView)
        addSubview(streakLabel)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            streakLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Dimensions.paddingMedium),
            streakLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Dimensions.paddingMedium),
            streakLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            descriptionLabel.leadingAnchor.constraint(equalTo: streakLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: streakLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Dimensions.paddingMedium),

            heightAnchor.constraint(equalToConstant: 70)
        ])

        setStreak(0)
    }

    func setStreak(_ count: Int) {
        streakLabel.text = "\(count)"

        // Update description based on count
        if count == 0 {
            descriptionLabel.text = NSLocalizedString("streak.start", value: "Start your streak!", comment: "")
            iconImageView.tintColor = Constants.Colors.textTertiary
        } else if count == 1 {
            descriptionLabel.text = NSLocalizedString("streak.one_day", value: "day streak", comment: "")
            iconImageView.tintColor = Constants.Colors.warning
        } else {
            descriptionLabel.text = NSLocalizedString("streak.multiple_days", value: "days streak", comment: "")
            iconImageView.tintColor = Constants.Colors.warning
        }

        // Enhanced celebration animation for milestones
        if count > 0 && count % 7 == 0 {
            addMilestoneAnimation()
        } else if count > 0 {
            addStreakAnimation()
        }
    }

    private func addStreakAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.2
        scaleAnimation.autoreverses = true
        iconImageView.layer.add(scaleAnimation, forKey: "streakAnimation")
    }

    private func addMilestoneAnimation() {
        // More elaborate animation for weekly milestones
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 0.6
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = 0.3
        scaleAnimation.autoreverses = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rotationAnimation, scaleAnimation]
        animationGroup.duration = 0.6
        
        iconImageView.layer.add(animationGroup, forKey: "milestoneAnimation")
        
        // Add glow effect
        iconImageView.layer.shadowColor = Constants.Colors.warning.cgColor
        iconImageView.layer.shadowRadius = 8
        iconImageView.layer.shadowOpacity = 0.8
        iconImageView.layer.shadowOffset = .zero
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.iconImageView.layer.shadowOpacity = 0
        }
    }
}