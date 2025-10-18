import Foundation

struct WaterEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let amount: Double
    let unit: WaterUnit
    let timestamp: Date
    let containerType: ContainerType

    init(
        id: UUID = UUID(),
        amount: Double,
        unit: WaterUnit = .milliliters,
        timestamp: Date = Date(),
        containerType: ContainerType = .glass
    ) {
        self.id = id
        self.amount = amount
        self.unit = unit
        self.timestamp = timestamp
        self.containerType = containerType
    }
}

enum WaterUnit: String, Codable, CaseIterable {
    case milliliters = "ml"
    case ounces = "oz"

    var name: String {
        switch self {
        case .milliliters:
            return NSLocalizedString("unit.milliliters", value: "Milliliters", comment: "")
        case .ounces:
            return NSLocalizedString("unit.ounces", value: "Ounces", comment: "")
        }
    }

    var symbol: String {
        return rawValue
    }

    func convert(from otherUnit: WaterUnit, amount: Double) -> Double {
        if self == otherUnit {
            return amount
        }

        switch (otherUnit, self) {
        case (.milliliters, .ounces):
            return amount * 0.033814 // ml to oz
        case (.ounces, .milliliters):
            return amount * 29.5735 // oz to ml
        case (.milliliters, .milliliters), (.ounces, .ounces):
            return amount // Same unit, no conversion needed
        }
    }
}

enum ContainerType: String, Codable, CaseIterable {
    case glass = "glass"
    case bottle = "bottle"
    case cup = "cup"
    case mug = "mug"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .glass:
            return NSLocalizedString("container.glass", value: "Glass", comment: "")
        case .bottle:
            return NSLocalizedString("container.bottle", value: "Bottle", comment: "")
        case .cup:
            return NSLocalizedString("container.cup", value: "Cup", comment: "")
        case .mug:
            return NSLocalizedString("container.mug", value: "Mug", comment: "")
        case .custom:
            return NSLocalizedString("container.custom", value: "Custom", comment: "")
        }
    }

    var defaultAmount: Double {
        switch self {
        case .glass:
            return 250.0
        case .bottle:
            return 500.0
        case .cup:
            return 200.0
        case .mug:
            return 300.0
        case .custom:
            return 0.0
        }
    }

    var systemImageName: String {
        switch self {
        case .glass:
            return "wineglass"
        case .bottle:
            return "waterbottle"
        case .cup:
            return "cup.and.saucer"
        case .mug:
            return "mug"
        case .custom:
            return "drop.fill"
        }
    }
}