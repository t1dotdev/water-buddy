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

    func loadUserData() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                user = try await getUserDataUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func updateDailyGoal(_ goal: Double) {
        Task {
            do {
                try await updateUserDataUseCase.updateDailyGoal(goal)
                
                // Reload user data to ensure UI is updated
                await loadUserData()
                
                // Post notification to update other screens
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: Notification.Name("DailyGoalUpdated"),
                        object: nil,
                        userInfo: ["newGoal": goal]
                    )
                    
                    successMessage = NSLocalizedString("settings.goal_updated", value: "Daily goal updated successfully", comment: "")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateLanguage(_ language: String) {
        Task {
            do {
                try await updateUserDataUseCase.updateLanguage(language)
                successMessage = NSLocalizedString("settings.language_updated", value: "Language updated successfully", comment: "")
                await loadUserData()
            } catch {
                errorMessage = error.localizedDescription
            }
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

                successMessage = NSLocalizedString("settings.reminders_updated", value: "Reminder settings updated", comment: "")
                await loadUserData()
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