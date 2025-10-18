import Foundation
import UserNotifications

protocol ManageRemindersUseCase {
    func scheduleReminders(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws
    func scheduleDailyReminder(enabled: Bool, time: Date) async throws
    func cancelAllReminders() async throws
    func scheduleQuickReminder(in timeInterval: TimeInterval) async throws
    func checkNotificationPermission() async throws -> Bool
    func requestNotificationPermission() async throws -> Bool
}

class ManageRemindersUseCaseImpl: ManageRemindersUseCase {
    private let notificationCenter = UNUserNotificationCenter.current()

    func scheduleReminders(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) async throws {
        // Cancel existing reminders
        try await cancelAllReminders()

        guard enabled else { return }

        // Ensure we have permission
        let hasPermission = try await checkNotificationPermission()
        guard hasPermission else {
            throw NotificationError.permissionDenied
        }

        // Schedule recurring reminders
        try await scheduleRecurringReminders(interval: interval, startTime: startTime, endTime: endTime)
    }

    func scheduleDailyReminder(enabled: Bool, time: Date) async throws {
        // Cancel existing reminders
        try await cancelAllReminders()

        guard enabled else { return }

        // Ensure we have permission
        let hasPermission = try await checkNotificationPermission()
        guard hasPermission else {
            throw NotificationError.permissionDenied
        }

        // Schedule single daily reminder
        try await scheduleDailyReminderNotification(time: time)
    }

    func cancelAllReminders() async throws {
        await notificationCenter.removeAllPendingNotificationRequests()
    }

    func scheduleQuickReminder(in timeInterval: TimeInterval) async throws {
        let hasPermission = try await checkNotificationPermission()
        guard hasPermission else {
            throw NotificationError.permissionDenied
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.reminder.title", value: "Time to Hydrate!", comment: "")
        content.body = NSLocalizedString("notification.reminder.body", value: "Don't forget to drink some water!", comment: "")
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "quick-reminder-\(UUID().uuidString)", content: content, trigger: trigger)

        try await notificationCenter.add(request)
    }

    func checkNotificationPermission() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func requestNotificationPermission() async throws -> Bool {
        return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    }

    // MARK: - Private Methods

    private func scheduleRecurringReminders(interval: TimeInterval, startTime: Date, endTime: Date) async throws {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)

        let intervalHours = Int(interval / 3600) // Convert to hours

        for hour in stride(from: startHour, through: endHour, by: intervalHours) {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification.reminder.title", value: "Time to Hydrate!", comment: "")
            content.body = generateReminderMessage()
            content.sound = UNNotificationSound.default
            content.badge = 1

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = startMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "hydration-reminder-\(hour)",
                content: content,
                trigger: trigger
            )

            try await notificationCenter.add(request)
        }
    }

    private func scheduleDailyReminderNotification(time: Date) async throws {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.reminder.title", value: "Time to Hydrate!", comment: "")
        content.body = generateReminderMessage()
        content.sound = UNNotificationSound.default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-hydration-reminder",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    private func generateReminderMessage() -> String {
        let messages = [
            NSLocalizedString("notification.message.1", value: "Stay hydrated! Time for some water 💧", comment: ""),
            NSLocalizedString("notification.message.2", value: "Your body is calling for water! 🥤", comment: ""),
            NSLocalizedString("notification.message.3", value: "Hydration time! Keep up the good work! 👍", comment: ""),
            NSLocalizedString("notification.message.4", value: "Don't forget to drink water and stay healthy! 💪", comment: ""),
            NSLocalizedString("notification.message.5", value: "Time to refuel with some refreshing water! ⚡", comment: "")
        ]

        return messages.randomElement() ?? messages[0]
    }
}

enum NotificationError: Error, LocalizedError {
    case permissionDenied
    case schedulingFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("error.notification.denied", value: "Notification permission denied", comment: "")
        case .schedulingFailed:
            return NSLocalizedString("error.notification.scheduling", value: "Failed to schedule notification", comment: "")
        case .unknown:
            return NSLocalizedString("error.notification.unknown", value: "Unknown notification error", comment: "")
        }
    }
}