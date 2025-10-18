import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔧 MainTabBarController: viewDidLoad called")

        setupTabBar()
        print("✅ TabBar setup completed")

        createTabBarControllers()
        print("✅ TabBar controllers created")
    }

    private func setupTabBar() {
        tabBar.backgroundColor = Constants.Colors.backgroundPrimary
        tabBar.tintColor = Constants.Colors.primaryBlue
        tabBar.unselectedItemTintColor = Constants.Colors.textSecondary

        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.Colors.backgroundPrimary

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func createTabBarControllers() {
        print("🔧 MainTabBarController: Creating tab bar controllers")

        // Home Tab
        let homeViewController = HomeViewController()
        homeViewController.viewModel = DependencyContainer.shared.homeViewModel()
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.home", value: "Home", comment: ""),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Statistics Tab
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.viewModel = DependencyContainer.shared.makeStatisticsViewModel()
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.statistics", value: "Statistics", comment: ""),
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        // Add Water Tab (Modal)
        let addWaterViewController = AddWaterViewController()
        addWaterViewController.viewModel = DependencyContainer.shared.makeAddWaterViewModel()
        addWaterViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.add", value: "Add Water", comment: ""),
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )

        // History Tab
        let historyViewController = HistoryViewController()
        historyViewController.viewModel = DependencyContainer.shared.makeHistoryViewModel()
        let historyNavController = UINavigationController(rootViewController: historyViewController)
        historyNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.history", value: "History", comment: ""),
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )

        // Settings Tab
        let settingsViewController = SettingsViewController()
        settingsViewController.viewModel = DependencyContainer.shared.makeSettingsViewModel()
        let settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.settings", value: "Settings", comment: ""),
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )

        // Set all view controllers
        viewControllers = [
            homeNavController,
            statisticsNavController,
            addWaterViewController,
            historyNavController,
            settingsNavController
        ]

        // Set delegate to handle Add Water tab special behavior
        delegate = self

        print("✅ MainTabBarController: All controllers set successfully")
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Handle Add Water tab (index 2) - present as modal
        if let index = viewControllers?.firstIndex(of: viewController), index == 2 {
            let addWaterViewController = AddWaterViewController()
            addWaterViewController.viewModel = DependencyContainer.shared.makeAddWaterViewModel()
            let navController = UINavigationController(rootViewController: addWaterViewController)
            navController.modalPresentationStyle = .pageSheet

            present(navController, animated: true)
            return false // Don't select the tab, just present modal
        }
        return true
    }
}