import UIKit

class ConfettiView: UIView {

    private var emitterLayer: CAEmitterLayer!
    private let duration: TimeInterval = 2.5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfetti()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfetti()
    }

    private func setupConfetti() {
        isUserInteractionEnabled = false

        emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: -10)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: 1)
        emitterLayer.renderMode = .additive

        var cells: [CAEmitterCell] = []
        let colors: [UIColor] = [
            .systemBlue,
            .systemGreen,
            .systemYellow,
            .systemOrange,
            .systemPink,
            .systemPurple,
            .systemRed,
            .systemTeal
        ]

        for color in colors {
            cells.append(createConfettiCell(color: color, shape: .circle))
            cells.append(createConfettiCell(color: color, shape: .square))
            cells.append(createConfettiCell(color: color, shape: .triangle))
        }

        emitterLayer.emitterCells = cells
        layer.addSublayer(emitterLayer)
    }

    private func createConfettiCell(color: UIColor, shape: ConfettiShape) -> CAEmitterCell {
        let cell = CAEmitterCell()

        cell.contents = shape.image(with: color).cgImage
        cell.birthRate = 3
        cell.lifetime = 10.0
        cell.lifetimeRange = 0
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 3
        cell.spinRange = 4
        cell.scale = 0.15
        cell.scaleRange = 0.1
        cell.alphaSpeed = -0.1

        return cell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer?.emitterPosition = CGPoint(x: bounds.width / 2, y: -10)
        emitterLayer?.emitterSize = CGSize(width: bounds.width, height: 1)
    }

    func start(completion: (() -> Void)? = nil) {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Stop emission after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.emitterLayer?.birthRate = 0

            // Remove from superview after particles fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion?()
                self?.removeFromSuperview()
            }
        }
    }
}

// MARK: - Confetti Shape

private enum ConfettiShape {
    case circle
    case square
    case triangle

    func image(with color: UIColor) -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            color.setFill()

            switch self {
            case .circle:
                let rect = CGRect(origin: .zero, size: size)
                context.cgContext.fillEllipse(in: rect)

            case .square:
                let rect = CGRect(origin: .zero, size: size)
                context.cgContext.fill(rect)

            case .triangle:
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.close()
                context.cgContext.addPath(path.cgPath)
                context.cgContext.fillPath()
            }
        }
    }
}
