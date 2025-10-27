// Werks - Package for Swift
// Game engine, models for an unofficial clone of Locomotive Werks game

/**
 # 🚂  Werks
 - 3 to 5 players
 - Most money wins
 
 # Components:
 - 1 game board
    - 14 board spaces (linear sequence)
        1. Green: 1st Gen, Cost: $4, Production: 2, Income: 1, 3 dice boxes
        2. Red: 1st Gen, Cost: $8, Prod: 4, Income: 2, 3 dice boxes)
        3. Yellow: 1st Gen, Cost: $12, Prod: 6, Income: 3, 2 dice boxes
        4. Blue: 1st Gen, Cost: $16, Prod: 8, Income: 4, 1 dice boxes
        5. Green: 2nd Gen, Cost: $20, Prod: 10, Income: 5, 4 dice boxes
        6. Red: 2nd Gen, Cost: $24, Prod: 12, Income: 6, 3 dice boxes
        7. Yellow: 2nd Gen, Cost: $28, Prod: 14, Income: 7, 3 dice boxes
        8. Green: 3rd Gen,  Cost: $32, Prod: 16, Income: 8, 4 dice boxes
        9. Blue: 2nd Gen, Cost: $36, Prod: 18, Income: 9, 2 dice boxes
        10. Red: 3rd Gen, Cost: $40, Prod: 20, Income: 10, 4 dice boxes
        11. Green: 4th Gen, Cost: $44, Prod: 22, Income: 11, 5 dice boxes
        12, Yellow: 3rd Gen, Cost: $48, Prod: 24, Income: 12,  3 dice boxes
        13, Red: 4th Gen, Cost: $52, Prod: 26, Income: 13, 4 dice boxes
        14, Green: 5th Gen, Cost: $56, Prod: 28, Income: 14, 5 dice boxes
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

// MARK: Game Constants

public enum GameConfig {
    
    public enum Player {
        public static let minCount: Int = 3
        public static let maxCount: Int = 5
        
        public static func isValid(count: Int) -> Bool {
            (minCount...maxCount).contains(count)
        }
    }
    
    public enum Economy {
        public static let endGameCoins: Int = 330
        public static let startingCoins: [Int: Int] = [
            3: 12,
            4: 12,
            5: 14
        ]
        
        public static func startingCoins(for playerCount: Int) -> Int {
            startingCoins[playerCount] ?? 0
        }
        
        public static func isGameOver(coins: Int) -> Bool {
            coins >= endGameCoins
        }
    }
    
    public enum Board {
        public static let numberOfSpaces: Int = 14
        public static let totalDiceCapacity: Int = 46
    }

    public enum Cards {        
        public static let totals: [Livery: Int] = [
            .green: 20,
            .red: 13,
            .yellow: 7,
            .blue: 3
        ]
        
        /// Computed total number of cards across all liveries
        public static var total: Int {
            totals.values.reduce(0, +)
        }

        /// Lookup helper for specific livery
        public static func total(for livery: Livery) -> Int {
           totals[livery] ?? 0
        }

        /// Expected breakdown for internal testing reference
        public static let expectedBreakdown: [Livery: [GenerationExpectation]] = GameConfig.Testing.expectedGenerationsForLivery
    }
        
    public enum Testing {
        /// Expected card generations for each livery (used in internal and unit tests)
        public static let expectedGenerationsForLivery: [Livery: [GenerationExpectation]] = [
            .green:  [.init(generation: 1, count: 4),
                      .init(generation: 2, count: 4),
                      .init(generation: 3, count: 4),
                      .init(generation: 4, count: 4),
                      .init(generation: 5, count: 4)],
            
                .red:    [.init(generation: 1, count: 3),
                          .init(generation: 2, count: 3),
                          .init(generation: 3, count: 3),
                          .init(generation: 4, count: 4)],
            
                .yellow: [.init(generation: 1, count: 2),
                          .init(generation: 2, count: 2),
                          .init(generation: 3, count: 3)],
            
                .blue:   [.init(generation: 1, count: 1),
                          .init(generation: 2, count: 2)]
        ]
        
        /// Convenience lookup
        public static func count(for livery: Livery, generation: Int) -> Int? {
            expectedGenerationsForLivery[livery]?.first { $0.generation == generation }?.count
        }
    }
}

/// Struct to model expectations more clearly
public struct GenerationExpectation : Sendable {
    public let generation: Int
    public let count: Int
}



// ------------------------------------

// MARK: Locomotive Color

public enum Livery: Int, CaseIterable, Equatable, Sendable {
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

// Needs: Ordinal Format and Roman Numeral Format
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

public class GameBoard {
    public var spaces: [Int]
    
    init(spaces: [Int]) {
        self.spaces = spaces
    }
}

// ---

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
}

// ie: General I, etc.
public struct Train: LocomotiveData, Identifiable, Hashable, Equatable {
    public var id: Int
    //public var name: String
    public var color: Livery
    public var generation: Generation
    public var cost: Int
    public var existingOrders: [Int]
    public var filledOrders: [Int]
    public var initialOrders: Int
    //public var trainPool: Int
    public var diceCapacity: Int // diceBoxes
    public var status: LocomotiveStatus
    
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
        
    init(id: Int, color: Livery, generation: Generation, cost: Int, existingOrders: [Int] = [Int](), filledOrders: [Int] = [Int](), initialOrders: Int = -1, diceCapacity: Int, status: LocomotiveStatus = .inactive) {
        self.id = id
        self.color = color
        self.generation = generation
        self.cost = cost
        self.existingOrders = existingOrders
        self.filledOrders = filledOrders
        self.initialOrders = initialOrders
        //self.trainPool = trainPool
        self.diceCapacity = diceCapacity
        self.status = status
    }
    
    public var name: String {
        get {
            var trainName: String = ""
            switch color {
            case .green: trainName.append("General")
            case .red: trainName.append("Fast Freight")
            case .yellow: trainName.append("Heavy")
            case .blue: trainName.append("Special")
            }
            trainName.append(" ")
            switch generation {
            case .first: trainName.append("I")
            case .second: trainName.append("II")
            case .third: trainName.append("III")
            case .fourth: trainName.append("IV")
            case .fifth: trainName.append("V")
            }
            return trainName
        }
    }
    
    public static func == (left: Train, right: Train) -> Bool  {
        return (left.id == right.id)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func makeTrains() -> [Train] {
        /*
         1. Green: 1st Gen, Cost: $4, Production: 2, Income: 1, 3 dice boxes
         2. Red: 1st Gen, Cost: $8, Prod: 4, Income: 2, 3 dice boxes)
         3. Yellow: 1st Gen, Cost: $12, Prod: 6, Income: 3, 2 dice boxes
         4. Blue: 1st Gen, Cost: $16, Prod: 8, Income: 4, 1 dice boxes
         5. Green: 2nd Gen, Cost: $20, Prod: 10, Income: 5, 4 dice boxes
         6. Red: 2nd Gen, Cost: $24, Prod: 12, Income: 6, 3 dice boxes
         7. Yellow: 2nd Gen, Cost: $28, Prod: 14, Income: 7, 3 dice boxes
         8. Green: 3rd Gen,  Cost: $32, Prod: 16, Income: 8, 4 dice boxes
         9. Blue: 2nd Gen, Cost: $36, Prod: 18, Income: 9, 2 dice boxes
         10. Red: 3rd Gen, Cost: $40, Prod: 20, Income: 10, 4 dice boxes
         11. Green: 4th Gen, Cost: $44, Prod: 22, Income: 11, 5 dice boxes
         12, Yellow: 3rd Gen, Cost: $48, Prod: 24, Income: 12,  3 dice boxes
         13, Red: 4th Gen, Cost: $52, Prod: 26, Income: 13, 4 dice boxes
         14, Green: 5th Gen, Cost: $56, Prod: 28, Income: 14, 5 dice boxes
         */
        let trains = [
            Train(id: 1, color: .green, generation: .first, cost: 4, diceCapacity: 3),
            Train(id: 2, color: .red, generation: .first, cost: 8, diceCapacity: 3),
            Train(id: 3, color: .yellow, generation: .first, cost: 12, diceCapacity: 2),
            Train(id: 4, color: .blue, generation: .first, cost: 16, diceCapacity: 1),
            Train(id: 5, color: .green, generation: .second, cost: 20, diceCapacity: 4),
            Train(id: 6, color: .red, generation: .second, cost: 24, diceCapacity: 3),
            Train(id: 7, color: .yellow, generation: .second, cost: 28, diceCapacity: 3),
            Train(id: 8, color: .green, generation: .third, cost: 32, diceCapacity: 4),
            Train(id: 9, color: .blue, generation: .second, cost: 36, diceCapacity: 2),
            Train(id: 10, color: .red, generation: .third, cost: 40, diceCapacity: 4),
            Train(id: 11, color: .green, generation: .fourth, cost: 44, diceCapacity: 5),
            Train(id: 12, color: .yellow, generation: .third, cost: 48, diceCapacity: 3),
            Train(id: 13, color: .red, generation: .fourth, cost: 52, diceCapacity: 4),
            Train(id: 14, color: .green, generation: .fifth, cost: 56, diceCapacity: 5)
        ]
        
        return trains
    }
}



