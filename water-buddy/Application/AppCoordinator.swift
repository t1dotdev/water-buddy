import UIKit

class AppCoordinator {
    private let window: UIWindow
    private var tabBarController: UITabBarController?
    private let dependencyContainer = DependencyContainer.shared
    private var languageObserver: NSObjectProtocol?

    init(window: UIWindow) {
        self.window = window
        setupLanguageObserver()
    }

    deinit {
        if let observer = languageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start() {
        print("🔧 AppCoordinator: start() called")

        // Set up language bundle to make NSLocalizedString use LanguageManager
        Bundle.setupLanguageBundle()
        print("✅ Language bundle setup complete")

        // Initialize language from user's saved preference
        initializeLanguage()

        do {
            let tabBarController = MainTabBarController()
            print("✅ MainTabBarController created successfully")

            self.tabBarController = tabBarController
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()

            print("✅ App started successfully")
        } catch {
            print("❌ Error creating MainTabBarController: \(error)")

            // Fallback to simple view controller
            let fallbackVC = UIViewController()
            fallbackVC.view.backgroundColor = .systemRed

            let errorLabel = UILabel()
            errorLabel.text = "Error loading app: \(error.localizedDescription)"
            errorLabel.textColor = .white
            errorLabel.font = UIFont.systemFont(ofSize: 16)
            errorLabel.textAlignment = .center
            errorLabel.numberOfLines = 0
            errorLabel.translatesAutoresizingMaskIntoConstraints = false

            fallbackVC.view.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorLabel.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor),
                errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: fallbackVC.view.leadingAnchor, constant: 20),
                errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: fallbackVC.view.trailingAnchor, constant: -20)
            ])

            window.rootViewController = fallbackVC
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Language Management

    private func setupLanguageObserver() {
        languageObserver = NotificationCenter.default.addObserver(
            forName: LanguageManager.languageDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🌐 Language changed notification received, reloading UI...")
            self?.reloadRootViewController()
        }
    }

    private func initializeLanguage() {
        Task { @MainActor in
            do {
                let getUserDataUseCase = dependencyContainer.getUserDataUseCase
                let user = try await getUserDataUseCase.execute()

                LanguageManager.shared.initializeWithUserLanguage(user.language)
                print("🌐 Language initialized from user preference: \(user.language)")
            } catch {
                print("⚠️ Could not load user language preference: \(error.localizedDescription)")
                print("🌐 Using default language: \(LanguageManager.shared.currentLanguage)")
            }
        }
    }

    private func reloadRootViewController() {
        print("🔄 Reloading root view controller for language change...")

        // Create new tab bar controller with updated language
        let newTabBarController = MainTabBarController()

        // Preserve the selected tab
        if let currentIndex = tabBarController?.selectedIndex {
            newTabBarController.selectedIndex = currentIndex
        }

        self.tabBarController = newTabBarController

        // Animate the transition
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.window.rootViewController = newTabBarController
            },
            completion: { _ in
                print("✅ Root view controller reloaded successfully")
            }
        )
    }

    // MARK: - Quick Actions

    func handleQuickAddWater(amount: Double) {
        // Add water entry quickly
        Task { @MainActor in
            let addWaterUseCase = dependencyContainer.addWaterUseCase

            do {
                let entry = try await addWaterUseCase.execute(amount: amount, container: .glass)
                showSuccessAlert(message: NSLocalizedString("quickaction.success.added", value: "Added \(Int(amount))ml successfully!", comment: ""))
                // Navigate to home tab to show updated progress
                tabBarController?.selectedIndex = 0
            } catch {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func showStatistics() {
        // Navigate to statistics tab
        tabBarController?.selectedIndex = 1
    }

    func setQuickReminder() {
        let notificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.reminder.title", value: "Time to Hydrate!", comment: "")
        content.body = NSLocalizedString("notification.reminder.body", value: "Don't forget to drink some water!", comment: "")
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour

        let request = UNNotificationRequest(identifier: "quick-reminder", content: content, trigger: trigger)

        notificationCenter.add(request) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.showSuccessAlert(message: NSLocalizedString("quickaction.reminder.set", value: "Reminder set for 1 hour!", comment: ""))
                } else {
                    self?.showErrorAlert(message: NSLocalizedString("quickaction.reminder.failed", value: "Failed to set reminder", comment: ""))
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func showSuccessAlert(message: String) {
        showAlert(title: NSLocalizedString("alert.success", value: "Success", comment: ""), message: message)
    }

    private func showErrorAlert(message: String) {
        showAlert(title: NSLocalizedString("alert.error", value: "Error", comment: ""), message: message)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", value: "OK", comment: ""), style: .default))

        if let topViewController = window.rootViewController?.topMostViewController() {
            topViewController.present(alert, animated: true)
        }
    }
}