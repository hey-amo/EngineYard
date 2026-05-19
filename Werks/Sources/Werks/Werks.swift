// Werks
// v0.1a

// MARK: Main game area
public class Werks {
}

// MARK: Game Stages
public enum GameStage: Int, CaseIterable, Codable {
    case idle
    case setupNewGame
    case playerSelectScreen
    case buyLocomotive
    case buyProduction
    case sellLocomotives
    case payTaxes
    case marketDemands
    case updateTurnOrder
    case gameOver
}

// --------------------------------
// MARK: Locomotive Generation
// --------------------------------

public enum Generation: Int, CaseIterable, Codable {
    case first = 1, second, third, fourth, fifth
}

extension Generation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .first: return "First"
        case .second: return "Second"
        case .third: return "Third"
        case .fourth: return "Fourth"
        case .fifth: return "Fifth"
        }
    }
}


extension Generation: Equatable {
    static func > (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue > rhs.rawValue)
    }
    static func < (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue < rhs.rawValue)
    }
    public static func == (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}


// --------------------------------
// MARK: Locomotive Colour (Livery)
// --------------------------------
    public enum LocomotiveColor: Int, CaseIterable, Equatable, Codable, Sendable {
    case green = 1, red, yellow, blue
}

extension LocomotiveColor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .green: return "Green"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        }
    }
}

