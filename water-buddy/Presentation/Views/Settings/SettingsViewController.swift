import UIKit
import Combine

class SettingsViewController: UIViewController {
    var viewModel: SettingsViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Constants.Colors.backgroundPrimary
        return tableView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // Settings sections
    private let sections: [SettingsSection] = [
        SettingsSection(title: NSLocalizedString("settings.profile", value: "Profile", comment: ""), items: [
            SettingsItem(title: NSLocalizedString("settings.daily_goal", value: "Daily Goal", comment: ""), type: .dailyGoal),
            SettingsItem(title: NSLocalizedString("settings.units", value: "Units", comment: ""), type: .units)
        ]),
        SettingsSection(title: NSLocalizedString("settings.reminders", value: "Reminders", comment: ""), items: [
            SettingsItem(title: NSLocalizedString("settings.reminders", value: "Enable Reminders", comment: ""), type: .reminders)
        ]),
        SettingsSection(title: NSLocalizedString("settings.language", value: "Language", comment: ""), items: [
            SettingsItem(title: NSLocalizedString("settings.language", value: "Language", comment: ""), type: .language)
        ]),
        SettingsSection(title: NSLocalizedString("settings.about", value: "About", comment: ""), items: [
            SettingsItem(title: NSLocalizedString("settings.privacy", value: "Privacy Policy", comment: ""), type: .privacy),
            SettingsItem(title: NSLocalizedString("settings.terms", value: "Terms of Service", comment: ""), type: .terms),
            SettingsItem(title: NSLocalizedString("settings.support", value: "Support", comment: ""), type: .support)
        ])
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadUserData()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.backgroundPrimary

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("settings.title", value: "Settings", comment: "")
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
            .sink { [weak self] _ in
                self?.tableView.reloadData()
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
            .sink { [weak self] success in
                self?.showAlert(title: NSLocalizedString("alert.success", value: "Success", comment: ""), message: success)
                self?.viewModel.clearSuccess()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func handleSettingsItem(_ item: SettingsItem) {
        switch item.type {
        case .dailyGoal:
            showDailyGoalPicker()
        case .units:
            showUnitPicker()
        case .reminders:
            // Toggle reminders or show reminder settings
            break
        case .language:
            showLanguagePicker()
        case .privacy:
            openURL(Constants.URLs.privacyPolicy)
        case .terms:
            openURL(Constants.URLs.termsOfService)
        case .support:
            openURL(Constants.URLs.support)
        }
    }

    private func showDailyGoalPicker() {
        let currentGoal = viewModel.user?.dailyGoal ?? 2000.0

        showTextInputAlert(
            title: NSLocalizedString("settings.daily_goal", value: "Daily Goal", comment: ""),
            message: NSLocalizedString("settings.enter_goal", value: "Enter your daily water goal (ml)", comment: ""),
            placeholder: "2000",
            currentText: "\(Int(currentGoal))"
        ) { [weak self] text in
            if let goal = Double(text), goal > 0 && goal <= 10000 {
                self?.viewModel.updateDailyGoal(goal)
            }
        }
    }

    private func showUnitPicker() {
        let alert = UIAlertController(title: NSLocalizedString("settings.units", value: "Units", comment: ""), message: nil, preferredStyle: .actionSheet)

        for unit in WaterUnit.allCases {
            let action = UIAlertAction(title: unit.name, style: .default) { [weak self] _ in
                // Update preferred unit
                print("Selected unit: \(unit)")
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
    }

    private func showLanguagePicker() {
        let alert = UIAlertController(title: NSLocalizedString("settings.language", value: "Language", comment: ""), message: nil, preferredStyle: .actionSheet)

        let languages = [
            ("en", "English"),
            ("th", "ภาษาไทย")
        ]

        for (code, name) in languages {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.viewModel.updateLanguage(code)
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        cell.textLabel?.text = item.title
        cell.textLabel?.font = FontManager.shared.body
        cell.accessoryType = .disclosureIndicator

        // Set detail text based on item type
        switch item.type {
        case .dailyGoal:
            let goal = viewModel.user?.dailyGoal ?? 2000.0
            cell.detailTextLabel?.text = "\(Int(goal))ml"
        case .units:
            let unit = viewModel.user?.preferredUnit ?? .milliliters
            cell.detailTextLabel?.text = unit.name
        case .language:
            let language = viewModel.user?.language ?? "en"
            cell.detailTextLabel?.text = language == "en" ? "English" : "ภาษาไทย"
        case .reminders:
            let enabled = viewModel.user?.reminderEnabled ?? true
            cell.detailTextLabel?.text = enabled ? NSLocalizedString("settings.on", value: "On", comment: "") : NSLocalizedString("settings.off", value: "Off", comment: "")
        default:
            cell.detailTextLabel?.text = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        handleSettingsItem(item)
    }
}

// MARK: - Settings Models

struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let type: SettingsItemType
}

enum SettingsItemType {
    case dailyGoal
    case units
    case reminders
    case language
    case privacy
    case terms
    case support
}