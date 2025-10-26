// Werks - Package for Swift
// Game engine, models for an unofficial clone of Locomotive Werks game

/**
 # 🚂  Werks
 - 3 to 5 players
 - Most money wins
 
 # Components:
 - 1 game board
    - 14 board spaces (linear sequence)
        - Green
        - Red
        - Yellow
 -
 - 43 locomotive cards
    - 20 Passenger locomotives (green)
        - (4 First Generation, 4 Second Generation, 4 Third Generation, 4 Fourth Generation, 4 Fifth Generation)
    - 13 Fast locomotives (red)
        - (3 First Generation, 3 Second Generation, 3 Third Generation, 4 Fourth Generation)
    - 7 Freight locomotives (yellow)
        - (2 First Generation, 2 Second Generation, 3 Third Generation)
    - 3 Special locomotives (blue)
        - 1 First Generation, 2 Second Generation)
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

 ---
 
 # 🚂 Train Unit Data Table

 | **ID** | **Name** | **Colour** | **Cost** | **Colour Code** | **Gen** | **Pool** | **Dice** |
 |:------:|:----------------------------|:-----------|:--------:|:----------------:|:-------:|:--------:|:--------:|
 | 1  | General I (4-2-1)          | Green  | 4  | 1 | 1 | 4 | 3 |
 | 2  | Fast Freight I (8-4-2)     | Red    | 8  | 2 | 1 | 3 | 3 |
 | 3  | Heavy I (12-6-3)           | Yellow | 12 | 3 | 1 | 2 | 2 |
 | 4  | Special I (16-8-4)         | Blue   | 16 | 4 | 1 | 1 | 2 |
 | 5  | General II (20-10-5)       | Green  | 20 | 1 | 2 | 4 | 4 |
 | 6  | Fast Freight II (24-12-6)  | Red    | 24 | 2 | 2 | 3 | 3 |
 | 7  | Heavy II (28-14-7)         | Yellow | 28 | 3 | 2 | 2 | 3 |
 | 8  | General III (32-16-8)      | Green  | 32 | 1 | 3 | 4 | 4 |
 | 9  | Special II (36-18-9)       | Blue   | 36 | 4 | 2 | 2 | 2 |
 | 10 | Fast Freight III (40-20-10)| Red    | 40 | 2 | 3 | 3 | 4 |
 | 11 | General IV (44-22-11)      | Green  | 44 | 1 | 4 | 4 | 4 |
 | 12 | Heavy III (48-24-12)       | Yellow | 48 | 3 | 3 | 3 | 3 |
 | 13 | Fast Freight IV (52-26-13) | Red    | 52 | 2 | 4 | 4 | 4 |
 | 14 | General V (56-28-14)       | Green  | 56 | 1 | 5 | 4 | 5 |

 
 ------------------------------------
 */

import Foundation

// ------------------------------------

// MARK: Locomotive Color

public enum Livery: Int, CaseIterable, Equatable {
    case green = 1, red, yellow, blue
}

extension Livery: CustomStringConvertible {
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

public enum Generation: Int, CaseIterable {
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

// ------------------------------------

/**
Game stages:
 
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
 */
public enum GameStage: Int, CaseIterable {
    case idle
    case gameSetup
    case locomotiveDevelopment
    case expandProductionCapacity
    case produceAndSellLocomotives
    case payTaxes
    case marketDemands
    case updateTurnOrder
    case gameOver
}

// ------------------------------------

public class GameBoard: Equatable {
    public var id: UUID
    public var spaces: [Locomotive]
    
    init(spaces: [Locomotive]) {
        self.id = UUID()
        self.spaces = spaces
    }
    
    public static func == (left: GameBoard, right: GameBoard) -> Bool {
        return left.id == right.id
    }
}

// ------------------------------------

// MARK: Locomotive Data

public enum LocomotiveStatus: Int, CaseIterable {
    case inactive, new, rusting, obsolete
}


public protocol LocomotiveData {
    var name: String { get } // Name of the locomotive
    var color: Livery { get } // Locomotive.color
    var generation: Generation { get } // Locomotive.generation
    var cost: Int { get } // Cost to design the locomotive
    var productionCost: Int { get }
    var income: Int { get }
    var status: LocomotiveStatus { get }
}

public struct Train: LocomotiveData {
    public var name: String
    public var cost: Int
    public var color: Livery
    public var generation: Generation
    public var productionCost: Int {
        get {
            return Int(round(Double(self.cost) / 2))
        }
    }
      
    public var income: Int {
      get {
          return Int(round(Double(self.productionCost) / 2))
      }
    }
    public var status: LocomotiveStatus // Set as inactive as default

    
    
    public static func makeTrains() {
        let _ = [
            Train.init(name: "Green.1", cost: 4, color: .green, generation: .first, status: .inactive)
        ]
    }
}

public struct Locomotive: Hashable, Equatable, Identifiable {
    public var id: Int // Game board position
    
    public let existingOrders: [Int]
    public let filledOrders: [Int]
    public let initialOrder: Int // Set as -1 as default to show no orders defined
    public let diceCapacity: Int // What the max dice the existingOrders, filledOrders can hold
    public let trainPool: Int // How many cards to create for this space
    
        
    public static func == (left: Locomotive, right: Locomotive) -> Bool  {
        return (left.id == right.id)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/*
extension Locomotive {
    public static func buildLocomotives() -> [Locomotive] {
        let locos: [Locomotive] = [
            Locomotive(id: 1, name: "Green.1", cost: 4, color: .green, generation: .first, existingOrders: [Int](), filledOrders: [Int](), initialOrder: -1, diceCapacity: 3, trainPool: <#T##Int#>, status: <#T##LocomotiveStatus#>)
        ]
        
        return locos
    }
}
*/

// ------------------------------------


/*


// ------------------------------------

extension Locomotive {
    public static func buildLocomotives() -> [Locomotive] {
        // An array of all locomotives in the game (immutable)
        
        let locos: [Locomotive] = [
            Locomotive(id: 1, name: "General I (4-2-1)", color: .green, generation: .first, cost: 4, trainPool: 4, maxDice: 3),
            Locomotive(id: 2, name: "Fast Freight I (8-4-2)", color: .red, generation: .first, cost: 8, trainPool: 3, maxDice: 3),
            Locomotive(id: 3, name: "Heavy I (12-6-3)", color: .yellow, generation: .first, cost: 12, trainPool: 2, maxDice: 2),
            Locomotive(id: 4, name: "Special I (16-8-4)", color: .blue, generation: .first, cost: 16, trainPool: 1, maxDice: 2),
            Locomotive(id: 5, name: "General II (20-10-5)", color: .green, generation: .second, cost: 20, trainPool: 4, maxDice: 4),
            Locomotive(id: 6, name: "Fast Freight II (24-12-6)", color: .red, generation: .second, cost: 24, trainPool: 3, maxDice: 3),
            Locomotive(id: 7, name: "Heavy II (28-14-7)", color: .yellow, generation: .second, cost: 28, trainPool: 2, maxDice: 3),
            Locomotive(id: 8, name: "General III (32-16-8)", color: .green, generation: .third, cost: 32, trainPool: 4, maxDice: 4),
            Locomotive(id: 9, name: "Special II (36-18-9)", color: .blue, generation: .second, cost: 36, trainPool: 2, maxDice: 2),
            Locomotive(id: 10, name: "Fast Freight III (40-20-10)", color: .red, generation: .third, cost: 40, trainPool: 3, maxDice: 4),
            Locomotive(id: 11, name: "General IV (44-22-11)", color: .green, generation: .fourth, cost: 44, trainPool: 4, maxDice: 4),
            Locomotive(id: 12, name: "Heavy III (48-24-12)", color: .yellow, generation: .third, cost: 48, trainPool: 3, maxDice: 3),
            Locomotive(id: 13, name: "Fast Freight IV (52-26-13)", color: .red, generation: .fourth, cost: 52, trainPool: 4, maxDice: 4),
            Locomotive(id: 14, name: "General V (56-28-14)", color: .green, generation: .fifth, cost: 56, trainPool: 4, maxDice: 5)
        ].sorted { $0.cost < $1.cost }
        
        return locos
    }
}

// ------------------------------------
*/
