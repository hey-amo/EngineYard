//
//  GameConfig.swift
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

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
