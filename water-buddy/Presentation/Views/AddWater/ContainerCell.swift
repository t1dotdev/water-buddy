import UIKit

class ContainerCell: UICollectionViewCell {
    static let identifier = "ContainerCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Colors.primaryBlue
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption2
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),

            amountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -4)
        ])
    }

    func configure(with container: ContainerType, isSelected: Bool) {
        iconImageView.image = UIImage(systemName: container.systemImageName)
        nameLabel.text = container.displayName

        let amount = container.defaultAmount
        amountLabel.text = amount > 0 ? "\(Int(amount))ml" : ""

        // Update appearance based on selection
        updateSelectionAppearance(isSelected: isSelected)
    }

    private func updateSelectionAppearance(isSelected: Bool) {
        UIView.animate(withDuration: Constants.Animation.fastDuration) {
            if isSelected {
                self.containerView.backgroundColor = Constants.Colors.primaryBlue.withAlphaComponent(0.1)
                self.containerView.layer.borderColor = Constants.Colors.primaryBlue.cgColor
                self.iconImageView.tintColor = Constants.Colors.primaryBlue
                self.nameLabel.textColor = Constants.Colors.primaryBlue
            } else {
                self.containerView.backgroundColor = Constants.Colors.backgroundSecondary
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.iconImageView.tintColor = Constants.Colors.textSecondary
                self.nameLabel.textColor = Constants.Colors.textPrimary
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = nil
        amountLabel.text = nil
        updateSelectionAppearance(isSelected: false)
    }
}