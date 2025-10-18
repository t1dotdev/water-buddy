import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        NSLog("🔧 SceneDelegate: scene willConnectTo called")
        print("🔧 SceneDelegate: scene willConnectTo called")

        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ Failed to get windowScene")
            return
        }

        print("✅ WindowScene obtained successfully")

        window = UIWindow(windowScene: windowScene)
        print("✅ Window created successfully")

        appCoordinator = AppCoordinator(window: window!)
        print("✅ AppCoordinator created successfully")

        appCoordinator?.start()
        print("✅ AppCoordinator start called")

        // Handle quick actions from launch
        if let shortcutItem = connectionOptions.shortcutItem {
            handleQuickAction(shortcutItem)
        }

        print("🔧 SceneDelegate setup completed")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        configureQuickActions()
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // MARK: - Quick Actions

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let success = handleQuickAction(shortcutItem)
        completionHandler(success)
    }

    private func configureQuickActions() {
        let addSmallAction = UIApplicationShortcutItem(
            type: QuickActionType.addSmallWater.rawValue,
            localizedTitle: NSLocalizedString("quickaction.add_small.title", value: "Add 250ml", comment: ""),
            localizedSubtitle: NSLocalizedString("quickaction.add_small.subtitle", value: "Quick log small glass", comment: ""),
            icon: UIApplicationShortcutIcon(systemImageName: "drop.fill"),
            userInfo: ["amount": NSNumber(value: 250)]
        )

        let addMediumAction = UIApplicationShortcutItem(
            type: QuickActionType.addMediumWater.rawValue,
            localizedTitle: NSLocalizedString("quickaction.add_medium.title", value: "Add 500ml", comment: ""),
            localizedSubtitle: NSLocalizedString("quickaction.add_medium.subtitle", value: "Quick log bottle", comment: ""),
            icon: UIApplicationShortcutIcon(systemImageName: "drop.fill"),
            userInfo: ["amount": NSNumber(value: 500)]
        )

        let viewProgressAction = UIApplicationShortcutItem(
            type: QuickActionType.viewProgress.rawValue,
            localizedTitle: NSLocalizedString("quickaction.view_progress.title", value: "View Progress", comment: ""),
            localizedSubtitle: NSLocalizedString("quickaction.view_progress.subtitle", value: "Check today's intake", comment: ""),
            icon: UIApplicationShortcutIcon(systemImageName: "chart.pie.fill")
        )

        let reminderAction = UIApplicationShortcutItem(
            type: QuickActionType.quickReminder.rawValue,
            localizedTitle: NSLocalizedString("quickaction.reminder.title", value: "Set Quick Reminder", comment: ""),
            localizedSubtitle: NSLocalizedString("quickaction.reminder.subtitle", value: "Remind in 1 hour", comment: ""),
            icon: UIApplicationShortcutIcon(systemImageName: "bell.fill")
        )

        UIApplication.shared.shortcutItems = [addSmallAction, addMediumAction, viewProgressAction, reminderAction]
    }

    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            return false
        }

        switch actionType {
        case .addSmallWater:
            appCoordinator?.handleQuickAddWater(amount: 250)
        case .addMediumWater:
            appCoordinator?.handleQuickAddWater(amount: 500)
        case .viewProgress:
            appCoordinator?.showStatistics()
        case .quickReminder:
            appCoordinator?.setQuickReminder()
        }

        return true
    }
}

enum QuickActionType: String, CaseIterable {
    case addSmallWater = "com.t1dotdev.water-buddy.addSmall"
    case addMediumWater = "com.t1dotdev.water-buddy.addMedium"
    case viewProgress = "com.t1dotdev.water-buddy.viewProgress"
    case quickReminder = "com.t1dotdev.water-buddy.reminder"
}