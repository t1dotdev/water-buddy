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

    // Settings sections - computed to dynamically show/hide reminder time
    private var sections: [SettingsSection] {
        var reminderItems = [
            SettingsItem(title: NSLocalizedString("settings.enable_reminders", value: "Enable Reminders", comment: ""), type: .reminders)
        ]

        // Add reminder time only if reminders are enabled
        if viewModel.user?.reminderEnabled ?? false {
            reminderItems.append(
                SettingsItem(title: NSLocalizedString("settings.reminder_time", value: "Reminder Time", comment: ""), type: .reminderTime)
            )
        }

        return [
            SettingsSection(title: NSLocalizedString("settings.profile", value: "Profile", comment: ""), items: [
                SettingsItem(title: NSLocalizedString("settings.daily_goal", value: "Daily Goal", comment: ""), type: .dailyGoal),
                SettingsItem(title: NSLocalizedString("settings.units", value: "Units", comment: ""), type: .units)
            ]),
            SettingsSection(title: NSLocalizedString("settings.reminders", value: "Reminders", comment: ""), items: reminderItems),
            SettingsSection(title: NSLocalizedString("settings.language", value: "Language", comment: ""), items: [
                SettingsItem(title: NSLocalizedString("settings.language", value: "Language", comment: ""), type: .language)
            ]),
            SettingsSection(title: NSLocalizedString("settings.app_info", value: "App Info", comment: ""), items: [
                SettingsItem(title: NSLocalizedString("settings.version", value: "Version", comment: ""), type: .appVersion)
            ])
        ]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            do {
                try await viewModel.loadUserData()
            } catch {
                print("⚠️ Failed to load user data in settings: \(error.localizedDescription)")
            }
        }
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
            showReminderToggle()
        case .reminderTime:
            showReminderTimePicker()
        case .language:
            showLanguagePicker()
        case .appVersion:
            // App version is read-only, no action needed
            break
        }
    }

    private func showDailyGoalPicker() {
        let currentGoal = viewModel.user?.dailyGoal ?? 2000.0
        let unit = viewModel.user?.preferredUnit ?? .milliliters
        let message = String(format: NSLocalizedString("settings.enter_goal_format", value: "Enter your daily water goal (%@)", comment: ""), unit.symbol)

        showTextInputAlert(
            title: NSLocalizedString("settings.daily_goal", value: "Daily Goal", comment: ""),
            message: message,
            placeholder: "2000",
            currentText: "\(Int(currentGoal))",
            keyboardType: .numberPad
        ) { [weak self] text in
            if let goal = Double(text), goal > 0 && goal <= 10000 {
                Task {
                    await self?.viewModel.updateDailyGoal(goal)
                }
            }
        }
    }

    private func showUnitPicker() {
        let alert = UIAlertController(title: NSLocalizedString("settings.units", value: "Units", comment: ""), message: nil, preferredStyle: .actionSheet)

        for unit in WaterUnit.allCases {
            let action = UIAlertAction(title: unit.name, style: .default) { [weak self] _ in
                Task {
                    await self?.viewModel.updatePreferredUnit(unit)
                }
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
                Task {
                    await self?.viewModel.updateLanguage(code)
                }
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
    }

    private func showReminderToggle() {
        let currentlyEnabled = viewModel.user?.reminderEnabled ?? false
        let currentTime = viewModel.user?.reminderTime ?? Date()

        let alert = UIAlertController(
            title: NSLocalizedString("settings.enable_reminders", value: "Enable Reminders", comment: ""),
            message: NSLocalizedString("settings.reminder_toggle_message", value: "Would you like to receive daily water reminders?", comment: ""),
            preferredStyle: .actionSheet
        )

        let enableAction = UIAlertAction(
            title: NSLocalizedString("settings.enable", value: "Enable", comment: ""),
            style: .default
        ) { [weak self] _ in
            Task {
                await self?.viewModel.updateDailyReminder(enabled: true, time: currentTime)
            }
        }

        let disableAction = UIAlertAction(
            title: NSLocalizedString("settings.disable", value: "Disable", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            Task {
                await self?.viewModel.updateDailyReminder(enabled: false, time: currentTime)
            }
        }

        alert.addAction(currentlyEnabled ? disableAction : enableAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
    }

    private func showReminderTimePicker() {
        let currentTime = viewModel.user?.reminderTime ?? Date()

        let alert = UIAlertController(
            title: NSLocalizedString("settings.reminder_time", value: "Reminder Time", comment: ""),
            message: "\n\n\n\n\n\n\n\n\n", // Add spacing for the picker
            preferredStyle: .alert
        )

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = currentTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        alert.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 55),
            datePicker.widthAnchor.constraint(equalToConstant: 270),
            datePicker.heightAnchor.constraint(equalToConstant: 162)
        ])

        let confirmAction = UIAlertAction(
            title: NSLocalizedString("alert.confirm", value: "Confirm", comment: ""),
            style: .default
        ) { [weak self] _ in
            Task {
                await self?.viewModel.updateDailyReminder(enabled: true, time: datePicker.date)
            }
        }

        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", value: "Cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
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

        // Set detail text based on item type
        switch item.type {
        case .dailyGoal:
            let goal = viewModel.user?.dailyGoal ?? 2000.0
            let unit = viewModel.user?.preferredUnit ?? .milliliters
            cell.detailTextLabel?.text = "\(Int(goal))\(unit.symbol)"
            cell.accessoryType = .disclosureIndicator
        case .units:
            let unit = viewModel.user?.preferredUnit ?? .milliliters
            cell.detailTextLabel?.text = unit.name
            cell.accessoryType = .disclosureIndicator
        case .language:
            let language = viewModel.user?.language ?? "en"
            cell.detailTextLabel?.text = language == "en" ? "English" : "ภาษาไทย"
            cell.accessoryType = .disclosureIndicator
        case .reminders:
            let enabled = viewModel.user?.reminderEnabled ?? true
            cell.detailTextLabel?.text = enabled ? NSLocalizedString("settings.on", value: "On", comment: "") : NSLocalizedString("settings.off", value: "Off", comment: "")
            cell.accessoryType = .disclosureIndicator
        case .reminderTime:
            let time = viewModel.user?.reminderTime ?? Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            cell.detailTextLabel?.text = formatter.string(from: time)
            cell.accessoryType = .disclosureIndicator
        case .appVersion:
            cell.detailTextLabel?.text = "1.0.0"
            cell.accessoryType = .none
            cell.selectionStyle = .none
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
    case reminderTime
    case language
    case appVersion
}