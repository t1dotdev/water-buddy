import Foundation
import Combine

@MainActor
class AddWaterViewModel: ObservableObject {
    @Published var selectedContainer: ContainerType = .glass
    @Published var customAmount: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var recentAmounts: [Double] = []
    @Published var user: User?

    private let addWaterUseCase: AddWaterUseCase
    private let getUserDataUseCase: GetUserDataUseCase
    private var cancellables = Set<AnyCancellable>()

    // Quick add amounts
    let quickAmounts = Constants.WaterBuddy.quickAddAmounts
    let containers = ContainerType.allCases

    init(addWaterUseCase: AddWaterUseCase, getUserDataUseCase: GetUserDataUseCase) {
        self.addWaterUseCase = addWaterUseCase
        self.getUserDataUseCase = getUserDataUseCase
        loadRecentAmounts()
        setupValidation()
        Task {
            await loadUserData()
        }
    }

    private func loadUserData() async {
        do {
            user = try await getUserDataUseCase.execute()
        } catch {
            print("Failed to load user data: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods

    func addWater(amount: Double) {
        Task {
            isLoading = true
            errorMessage = nil
            successMessage = nil

            do {
                let entry = try await addWaterUseCase.execute(amount: amount, container: selectedContainer)
                let unit = user?.preferredUnit ?? .milliliters
                successMessage = String(format: NSLocalizedString("add_water.success_format",
                    value: "Added \(Int(amount))\(unit.symbol) successfully!", comment: ""), Int(amount), unit.symbol)

                // Add to recent amounts
                addToRecentAmounts(amount)

                // Reset custom amount
                customAmount = ""
                
                // Post notification to update other views
                NotificationCenter.default.post(
                    name: Notification.Name("WaterIntakeUpdated"),
                    object: nil,
                    userInfo: ["amount": amount, "entry": entry]
                )

            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func addCustomAmount() {
        guard let amount = Double(customAmount), isValidAmount(amount) else {
            let unit = user?.preferredUnit ?? .milliliters
            errorMessage = String(format: NSLocalizedString("add_water.invalid_amount_format",
                value: "Please enter a valid amount between 1-5000%@", comment: ""), unit.symbol)
            return
        }

        addWater(amount: amount)
    }

    func selectContainer(_ container: ContainerType) {
        selectedContainer = container
    }

    // MARK: - Private Methods

    private func setupValidation() {
        $customAmount
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] text in
                self?.validateAmount(text) ?? false
            }
            .sink { isValid in
                if !isValid && !self.customAmount.isEmpty {
                    self.errorMessage = NSLocalizedString("add_water.invalid_format",
                        value: "Invalid number format", comment: "")
                } else if isValid {
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }

    private func validateAmount(_ text: String) -> Bool {
        guard let amount = Double(text) else { return false }
        return isValidAmount(amount)
    }

    private func isValidAmount(_ amount: Double) -> Bool {
        return amount >= Constants.WaterBuddy.minAmount &&
               amount <= Constants.WaterBuddy.maxAmount
    }

    private func loadRecentAmounts() {
        // Load from UserDefaults or keep default
        if let data = UserDefaults.standard.data(forKey: "recent_amounts"),
           let amounts = try? JSONDecoder().decode([Double].self, from: data) {
            recentAmounts = amounts
        }
    }

    private func addToRecentAmounts(_ amount: Double) {
        // Add to beginning and keep only unique recent amounts (max 5)
        recentAmounts.removeAll { $0 == amount }
        recentAmounts.insert(amount, at: 0)
        recentAmounts = Array(recentAmounts.prefix(5))

        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(recentAmounts) {
            UserDefaults.standard.set(data, forKey: "recent_amounts")
        }
    }

    // MARK: - Computed Properties

    var customAmountValue: Double? {
        return Double(customAmount)
    }

    var isCustomAmountValid: Bool {
        guard let amount = customAmountValue else { return false }
        return isValidAmount(amount)
    }

    var selectedContainerAmount: Double {
        return selectedContainer.defaultAmount
    }

    var containerAmountText: String {
        let amount = selectedContainerAmount
        let unit = user?.preferredUnit ?? .milliliters
        return amount > 0 ? "\(Int(amount))\(unit.symbol)" : NSLocalizedString("container.custom_amount", value: "Custom", comment: "")
    }

    var hasRecentAmounts: Bool {
        return !recentAmounts.isEmpty
    }

    func formattedAmount(_ amount: Double) -> String {
        let unit = user?.preferredUnit ?? .milliliters
        return "\(Int(amount))\(unit.symbol)"
    }

    // MARK: - Validation Methods

    func clearError() {
        errorMessage = nil
    }

    func clearSuccess() {
        successMessage = nil
    }
}