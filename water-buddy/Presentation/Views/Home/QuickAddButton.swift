import UIKit

class QuickAddButton: UIButton {
    let amount: Double // Amount in milliliters (for storage)
    private var displayAmount: Double // Amount to display

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.quickAddButton
        label.textColor = Constants.Colors.primaryBlue
        label.textAlignment = .center
        return label
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "drop.fill")
        imageView.tintColor = Constants.Colors.primaryBlue.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(amount: Double, displayAmount: Double? = nil, unit: WaterUnit = .milliliters) {
        self.amount = amount // Always in ml
        self.displayAmount = displayAmount ?? amount
        super.init(frame: .zero)
        setupButton()
        unitLabel.text = unit.symbol
    }

    func updateUnit(_ unit: WaterUnit, displayAmount: Double) {
        self.displayAmount = displayAmount
        unitLabel.text = unit.symbol
        amountLabel.text = "\(Int(displayAmount))"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = Constants.Colors.backgroundPrimary
        layer.cornerRadius = Constants.Dimensions.cornerRadius
        layer.borderWidth = 1.5
        layer.borderColor = Constants.Colors.primaryBlue.withAlphaComponent(0.3).cgColor

        // Enhanced modern shadow
        layer.shadowColor = Constants.Colors.primaryBlue.withAlphaComponent(0.3).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.2
        
        // Add subtle gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.02).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = Constants.Dimensions.cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(iconImageView)
        addSubview(amountLabel)
        addSubview(unitLabel)

        amountLabel.text = "\(Int(displayAmount))"

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.Dimensions.quickAddButtonSize),

            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            amountLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6),
            amountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            unitLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            unitLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            unitLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])

        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Add long press gesture for alternative interaction
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
        
        // Add initial subtle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addSubtleEntryAnimation()
        }
    }

    @objc private func buttonTouchDown() {
        animatePress(scale: Constants.Animation.pressedScale)
        // Light haptic feedback on touch down
        let lightImpact = UIImpactFeedbackGenerator(style: .light)
        lightImpact.impactOccurred()
    }

    @objc private func buttonTouchUp() {
        animatePress(scale: 1.0)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Add continuous fill animation
            addContinuousFillAnimation()
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        case .ended, .cancelled:
            removeContinuousFillAnimation()
        default:
            break
        }
    }

    func animatePress(scale: CGFloat = Constants.Animation.bounceScale) {
        UIView.animate(
            withDuration: Constants.Animation.fastDuration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                if scale != 1.0 {
                    UIView.animate(
                        withDuration: Constants.Animation.fastDuration,
                        delay: 0,
                        usingSpringWithDamping: 0.4,
                        initialSpringVelocity: 0.8,
                        options: [.allowUserInteraction],
                        animations: {
                            self.transform = .identity
                        }
                    )
                }
            }
        )
    }

    private func addContinuousFillAnimation() {
        let fillAnimation = CABasicAnimation(keyPath: "backgroundColor")
        fillAnimation.fromValue = backgroundColor?.cgColor
        fillAnimation.toValue = Constants.Colors.primaryBlue.withAlphaComponent(0.1).cgColor
        fillAnimation.duration = 0.3
        fillAnimation.autoreverses = true
        fillAnimation.repeatCount = .infinity
        layer.add(fillAnimation, forKey: "continuousFill")
    }

    private func removeContinuousFillAnimation() {
        layer.removeAnimation(forKey: "continuousFill")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: Constants.Animation.fastDuration) {
                self.alpha = self.isHighlighted ? 0.8 : 1.0
                self.layer.borderColor = self.isHighlighted ?
                    Constants.Colors.primaryBlue.cgColor :
                    Constants.Colors.primaryBlue.withAlphaComponent(0.2).cgColor
                
                // Add subtle scale change
                let scale: CGFloat = self.isHighlighted ? 0.98 : 1.0
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Add ripple effect
        if let touch = touches.first {
            let location = touch.location(in: self)
            addRippleEffect(at: location)
        }
    }

    private func addRippleEffect(at point: CGPoint) {
        let rippleLayer = CAShapeLayer()
        let maxRadius = max(bounds.width, bounds.height)
        
        let startPath = UIBezierPath(arcCenter: point, radius: 0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let endPath = UIBezierPath(arcCenter: point, radius: maxRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        rippleLayer.path = startPath.cgPath
        rippleLayer.fillColor = Constants.Colors.primaryBlue.withAlphaComponent(0.2).cgColor
        layer.addSublayer(rippleLayer)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = startPath.cgPath
        pathAnimation.toValue = endPath.cgPath
        pathAnimation.duration = 0.4
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.5
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.4
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [pathAnimation, opacityAnimation]
        animationGroup.duration = 0.4
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        rippleLayer.add(animationGroup, forKey: "ripple")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            rippleLayer.removeFromSuperlayer()
        }
    }
    
    private func addSubtleEntryAnimation() {
        // Subtle scale-in animation when the button first appears
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0.5
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            }
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient layer frame
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}