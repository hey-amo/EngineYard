// Werks
// v0.1a

// MARK: Game Rules
public enum GameRules {
    public enum Player {
        public static let min: Int = 3
        public static let max: Int = 5
        
        public static func isValidPlayerCount( _ count: Int) -> Bool {
            return (min...max).contains(count)
        }
    }
    
    public enum Economy {
        public static let taxRate: Double = 0.10
        public static let endGameCoins: Int = 330
        public static let seedCoins: [Int: Int] = [
            3: 12, 4: 12, 5: 14
        ]
        
        public static func giveStartingCoins(for playerCount: Int) -> Int {
            seedCoins[playerCount] ?? 0
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
        public static let totals: [LocomotiveColor: Int] = [
            .green: 20, .red: 13, .yellow: 7, .blue: 3
        ]
        /// Computed total number of cards across all locomotive liveries
        public static var total: Int {
            totals.values.reduce(0, +)
        }
        
        /// Lookup helper for specific locomotive livery
        public static func total(for color: LocomotiveColor) -> Int {
            totals[color] ?? 0
        }
        
        /// Expected breakdown for internal testing reference
        public static let expectedBreakdown: [LocomotiveColor: [GenerationExpectation]] = GameRules.Testing.expectedGenerationsForLivery
    }
    
    /// Struct to model expectations more clearly
    public struct GenerationExpectation : Sendable {
        public let generation: Int
        public let count: Int
    }

    /// Testing enum
    public enum Testing {
        /// Expected card generations for each livery (used in internal and unit tests)
        public static let expectedGenerationsForLivery: [LocomotiveColor: [GenerationExpectation]] = [
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
            
        /// Convenience lookup to give me an expected count for livery, generation
        public static func count(for livery: LocomotiveColor, generation: Int) -> Int? {
                expectedGenerationsForLivery[livery]?.first { $0.generation == generation }?.count
            }
        }

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

