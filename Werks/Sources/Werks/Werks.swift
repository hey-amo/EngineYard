// Werks - Package for Swift
// Game engine, models for an unofficial clone of Locomotive Werks game

/**
 # 🚂  Werks
 - 3 to 5 players
 - Most money wins
 
 # Components:
 - 1 game board
    - 14 board spaces (linear sequence)
 - 43 locomotive cards
    - 20 Passenger locomotives (green)
        - (4 First Generation, 4 Second Generation, 4 Third Generation, 4 Fourth Generation, 4 Fifth Generation)
    - 13 Fast locomotives (red)
        - (3 First Generation, 3 Second Generation, 3 Third Generation, 4 Fourth Generation)
    - 7 Freight locomotives (yellow)
        - (2 First Generation, 2 Second Generation, 3 Third Generation)
    - 3 Special locomotives (blue)
        - 1 First Generation, 2 Second Gene- ration)
 - 5 Turn order cards (1-5)
 - 80 Production counters (Value: 1 or 2)
 - Money/Coins
 
 # Objective of the game

 Players assume the role of engineers, constructing and producing more and more advanced locomotives.
 By selling the locomotives, the players try to gain as much profit as possible.
 
 When the game ends the player with the most money wins.
 
 Werks is played in rounds.
 
 Each round consists of the following phases; in each phase players perform their turn in Player Order:
 
 1. Locomotive Development
 Each player may develop 1 new locomotive.
 
 2. Production Capacity
 Each player may expand his production capacities.
 
 3. Locomotive Production
 Each player may produce and sell locomotives.
 
 4. Pay Taxes
 Each player must pay taxes.
 If at least one player has 300 coins or more after paying taxes, then the game ends; otherwise determine the new Player
 Order.
 
 5. Market Demands
 Players determine Market Demands. Subsequently the next game round starts.

 ------------------------------------
 */

// MARK: Locomotive Color

public enum LocomotiveColor: Int, CaseIterable, Equatable, Codable {
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


// ------------------------------------

// MARK: Locomotive Generation

public typealias Generation = LocomotiveGeneration

public enum LocomotiveGeneration: Int, CaseIterable, Codable {
    case first = 1, second, third, fourth, fifth
}

extension LocomotiveGeneration: CustomStringConvertible {
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

extension LocomotiveGeneration: Equatable {
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
