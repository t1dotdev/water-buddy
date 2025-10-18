import UIKit
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self
        ])

        // Enable automatic lightweight migration
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ SwiftData ModelContainer created successfully")
            return container
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            print("⚠️ Attempting to recreate container with fresh schema...")

            // If migration fails, try creating a new container (this will reset data)
            do {
                // Delete old store files
                let url = URL.applicationSupportDirectory.appending(path: "default.store")
                try? FileManager.default.removeItem(at: url)

                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ Fresh ModelContainer created successfully")
                return container
            } catch {
                fatalError("Could not create ModelContainer even after cleanup: \(error)")
            }
        }
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSLog("🔧 AppDelegate: didFinishLaunchingWithOptions called")
        print("🔧 AppDelegate: didFinishLaunchingWithOptions called")

        // Initialize SwiftData
        _ = AppDelegate.sharedModelContainer
        print("✅ SwiftData initialized")

        // Configure appearance
        configureAppAppearance()

        // Register for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        NSLog("🔧 AppDelegate: configurationForConnecting called")
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Private Methods

    private func configureAppAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}