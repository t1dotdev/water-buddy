import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let getUserDataUseCase: GetUserDataUseCase
    private let updateUserDataUseCase: UpdateUserDataUseCase
    private let manageRemindersUseCase: ManageRemindersUseCase

    init(
        getUserDataUseCase: GetUserDataUseCase,
        updateUserDataUseCase: UpdateUserDataUseCase,
        manageRemindersUseCase: ManageRemindersUseCase
    ) {
        self.getUserDataUseCase = getUserDataUseCase
        self.updateUserDataUseCase = updateUserDataUseCase
        self.manageRemindersUseCase = manageRemindersUseCase
    }

    func loadUserData() async throws {
        isLoading = true
        errorMessage = nil

        user = try await getUserDataUseCase.execute()
        print("✅ User data loaded successfully. Daily goal: \(user?.dailyGoal ?? 0)")

        isLoading = false
    }

    func updateDailyGoal(_ goal: Double) async {
        do {
            print("📝 Updating daily goal to: \(goal)")
            try await updateUserDataUseCase.updateDailyGoal(goal)
            print("✅ Daily goal saved successfully")

            // Reload user data to ensure UI is updated
            try await loadUserData()
            print("✅ Daily goal update complete. New value: \(user?.dailyGoal ?? 0)")

            // Post notification to update other screens
            NotificationCenter.default.post(
                name: Notification.Name("DailyGoalUpdated"),
                object: nil,
                userInfo: ["newGoal": goal]
            )

            successMessage = NSLocalizedString("settings.goal_updated", value: "Daily goal updated successfully", comment: "")
        } catch {
            print("❌ Failed to update daily goal: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func updateLanguage(_ language: String) async {
        do {
            print("🌐 Updating language to: \(language)")

            // Update in database
            try await updateUserDataUseCase.updateLanguage(language)

            // Update LanguageManager
            LanguageManager.shared.setLanguage(language)

            // Reload user data
            try await loadUserData()

            print("✅ Language update complete")

            // Note: The LanguageManager will post a notification that triggers UI reload
            successMessage = localizedString("settings.language_updated", value: "Language updated successfully", comment: "")
        } catch {
            print("❌ Failed to update language: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func updatePreferredUnit(_ unit: WaterUnit) async {
        do {
            print("📝 Updating preferred unit to: \(unit)")
            try await updateUserDataUseCase.updatePreferredUnit(unit)
            print("✅ Preferred unit saved successfully")

            // Reload user data to ensure UI is updated
            try await loadUserData()
            print("✅ Preferred unit update complete. New value: \(user?.preferredUnit.name ?? "")")

            // Post notification to update other screens
            NotificationCenter.default.post(
                name: Notification.Name("PreferredUnitUpdated"),
                object: nil,
                userInfo: ["newUnit": unit]
            )

            successMessage = NSLocalizedString("settings.unit_updated", value: "Unit updated successfully", comment: "")
        } catch {
            print("❌ Failed to update preferred unit: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func updateReminderSettings(enabled: Bool, interval: TimeInterval, startTime: Date, endTime: Date) {
        Task {
            do {
                try await updateUserDataUseCase.updateReminderSettings(
                    enabled: enabled,
                    interval: interval,
                    startTime: startTime,
                    endTime: endTime
                )

                // Schedule or cancel reminders
                try await manageRemindersUseCase.scheduleReminders(
                    enabled: enabled,
                    interval: interval,
                    startTime: startTime,
                    endTime: endTime
                )

                try await loadUserData()
                successMessage = NSLocalizedString("settings.reminders_updated", value: "Reminder settings updated", comment: "")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func clearSuccess() {
        successMessage = nil
    }
}