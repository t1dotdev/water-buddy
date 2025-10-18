import UIKit
import Combine

class AddWaterViewController: UIViewController {
    var viewModel: AddWaterViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var selectedAmount: Double = 250.0

    // MARK: - UI Components
    
    // Main amount display
    private lazy var amountDisplayContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.primaryBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = Constants.Colors.primaryBlue
        label.textAlignment = .center
        label.text = "250"
        return label
    }()
    
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.title2
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = "ml"
        return label
    }()
    
    // Amount slider
    private lazy var amountSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 50
        slider.maximumValue = 1000
        slider.value = 250
        slider.tintColor = Constants.Colors.primaryBlue
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    // Quick amount buttons
    private lazy var quickAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("add_water.quick_select", value: "Quick Select", comment: "")
        return label
    }()
    
    private lazy var quickAmountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    // Container selection (simplified)
    private lazy var containerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        label.text = NSLocalizedString("add_water.container", value: "Container Type", comment: "")
        return label
    }()
    
    private lazy var containerSegmentedControl: UISegmentedControl = {
        let items = ["Glass", "Bottle", "Cup", "Mug"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(containerChanged), for: .valueChanged)
        return control
    }()
    
    // Main add button
    private lazy var addWaterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.Colors.primaryBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(addWaterButtonTapped), for: .touchUpInside)
        button.updateTitle(for: 250)
        
        // Add shadow for depth
        button.layer.shadowColor = Constants.Colors.primaryBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        
        return button
    }()
    
    // Success feedback view
    private lazy var successView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.success
        view.layer.cornerRadius = 20
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = .white
        label.textAlignment = .center
        label.text = "✓ Added Successfully!"
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.backgroundPrimary

        // Add subviews
        view.addSubview(amountDisplayContainer)
        amountDisplayContainer.addSubview(amountLabel)
        amountDisplayContainer.addSubview(unitLabel)
        
        view.addSubview(amountSlider)
        view.addSubview(quickAmountLabel)
        view.addSubview(quickAmountStackView)
        view.addSubview(containerLabel)
        view.addSubview(containerSegmentedControl)
        view.addSubview(addWaterButton)
        
        view.addSubview(successView)
        successView.addSubview(successLabel)

        setupQuickAmountButtons()
        setupConstraints()
    }

    private func setupQuickAmountButtons() {
        let amounts = [100, 250, 500, 750]
        for amount in amounts {
            let button = createQuickAmountButton(amount: Double(amount))
            quickAmountStackView.addArrangedSubview(button)
        }
    }

    private func createQuickAmountButton(amount: Double) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(Int(amount))ml", for: .normal)
        button.backgroundColor = Constants.Colors.backgroundSecondary
        button.setTitleColor(Constants.Colors.primaryBlue, for: .normal)
        button.titleLabel?.font = FontManager.shared.subheadline
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = Constants.Colors.primaryBlue.withAlphaComponent(0.2).cgColor
        button.tag = Int(amount)
        button.addTarget(self, action: #selector(quickAmountTapped(_:)), for: .touchUpInside)
        return button
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Amount display container
            amountDisplayContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            amountDisplayContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            amountDisplayContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            amountDisplayContainer.heightAnchor.constraint(equalToConstant: 150),
            
            // Amount label
            amountLabel.centerXAnchor.constraint(equalTo: amountDisplayContainer.centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: amountDisplayContainer.centerYAnchor, constant: -10),
            
            // Unit label
            unitLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: -5),
            unitLabel.centerXAnchor.constraint(equalTo: amountDisplayContainer.centerXAnchor),
            
            // Slider
            amountSlider.topAnchor.constraint(equalTo: amountDisplayContainer.bottomAnchor, constant: 30),
            amountSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            amountSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Quick amount label
            quickAmountLabel.topAnchor.constraint(equalTo: amountSlider.bottomAnchor, constant: 40),
            quickAmountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Quick amount buttons
            quickAmountStackView.topAnchor.constraint(equalTo: quickAmountLabel.bottomAnchor, constant: 15),
            quickAmountStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quickAmountStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            quickAmountStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Container label
            containerLabel.topAnchor.constraint(equalTo: quickAmountStackView.bottomAnchor, constant: 40),
            containerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Container segmented control
            containerSegmentedControl.topAnchor.constraint(equalTo: containerLabel.bottomAnchor, constant: 15),
            containerSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Add water button
            addWaterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            addWaterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addWaterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addWaterButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Success view
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            successView.widthAnchor.constraint(equalToConstant: 250),
            successView.heightAnchor.constraint(equalToConstant: 60),
            
            // Success label
            successLabel.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            successLabel.centerYAnchor.constraint(equalTo: successView.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("add_water.title", value: "Add Water", comment: "")
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.addWaterButton.isEnabled = !isLoading
                self?.amountSlider.isEnabled = !isLoading
                self?.containerSegmentedControl.isEnabled = !isLoading
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(title: NSLocalizedString("alert.error", value: "Error", comment: ""), message: error)
                self?.viewModel.clearError()
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showSuccessAnimation()
                self?.viewModel.clearSuccess()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func sliderValueChanged() {
        let value = round(amountSlider.value / 10) * 10 // Round to nearest 10
        selectedAmount = Double(value)
        amountLabel.text = "\(Int(value))"
        addWaterButton.updateTitle(for: value)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    @objc private func quickAmountTapped(_ sender: UIButton) {
        let amount = Double(sender.tag)
        selectedAmount = amount
        amountSlider.value = Float(amount)
        amountLabel.text = "\(Int(amount))"
        addWaterButton.updateTitle(for: Float(amount))
        
        // Animate button selection
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        // Haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    @objc private func containerChanged() {
        let containers: [ContainerType] = [.glass, .bottle, .cup, .mug]
        viewModel.selectedContainer = containers[containerSegmentedControl.selectedSegmentIndex]
    }

    @objc private func addWaterButtonTapped() {
        viewModel.addWater(amount: selectedAmount)
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.addWaterButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addWaterButton.transform = .identity
            }
        }
        
        // Strong haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Private Methods

    private func showSuccessAnimation() {
        successView.isHidden = false
        successView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.successView.alpha = 1
            self.successView.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                self.successView.alpha = 0
                self.successView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.successView.isHidden = true
                // Navigate back to previous screen or switch to home tab
                self.navigateBack()
            }
        }
        
        // Success haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func navigateBack() {
        // Since Add Water is a tab, switch to Home tab after adding water
        if let tabBarController = self.tabBarController {
            // Switch to Home tab (index 0)
            tabBarController.selectedIndex = 0
            
            // Reset the form for next use
            DispatchQueue.main.async { [weak self] in
                self?.resetForm()
            }
        }
        // If presented modally (future use case), dismiss
        else if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        // If in navigation stack (future use case), pop
        else if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    private func resetForm() {
        // Reset to default values for next time user opens the Add Water tab
        selectedAmount = 250
        amountSlider.value = 250
        amountLabel.text = "250"
        addWaterButton.updateTitle(for: 250)
        containerSegmentedControl.selectedSegmentIndex = 0
        viewModel.selectedContainer = .glass
    }
}

// MARK: - UIButton Extension

extension UIButton {
    func updateTitle(for amount: Float) {
        let title = NSLocalizedString("add_water.add_button", value: "Add %d ml", comment: "")
        self.setTitle(String(format: title, Int(amount)), for: .normal)
    }
    
    func animatePress() {
        UIView.animate(
            withDuration: Constants.Animation.fastDuration,
            animations: {
                self.transform = CGAffineTransform(scaleX: Constants.Animation.pressedScale, y: Constants.Animation.pressedScale)
            },
            completion: { _ in
                UIView.animate(withDuration: Constants.Animation.fastDuration) {
                    self.transform = .identity
                }
            }
        )
    }
}