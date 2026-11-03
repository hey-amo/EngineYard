//
//  GameRules.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

public enum GameRules {
    public static let minimumPlayers: Int = 3
    public static let maximumPlayers: Int = 5

    public enum Economy {
        public static let minCoins: Int = 0
        public static let maxCoins: Int = 1000
        
        public static let seedCapitalThreePlayers: Int = 14
    
        /// The game ends when any player has more than this many coins.
        public static let endGameCoinThreshold: Int = 330

        /// Store the tax rate as an integer percentage
        public static let taxPercent: Int = 10
    }
    
    public static func hasReachedEndCondition(coins: [Int]) -> Bool {
        coins.contains { $0 >= GameRules.Economy.endGameCoinThreshold }
    }

    // MARK: - Locomotive inventory

    public struct CardInventoryRule: Sendable, Equatable {
        public let livery: LocomotiveLivery
        public let generation: LocomotiveGeneration
        public let count: Int

        public init(
            livery: LocomotiveLivery,
            generation: LocomotiveGeneration,
            count: Int
        ) {
            self.livery = livery
            self.generation = generation
            self.count = count
        }
    }

    public static let locomotiveCardInventory: [CardInventoryRule] = [
        .init(livery: .green, generation: .first, count: 4),
        .init(livery: .green, generation: .second, count: 4),
        .init(livery: .green, generation: .third, count: 4),
        .init(livery: .green, generation: .fourth, count: 4),
        .init(livery: .green, generation: .fifth, count: 4),

        .init(livery: .red, generation: .first, count: 3),
        .init(livery: .red, generation: .second, count: 3),
        .init(livery: .red, generation: .third, count: 3),
        .init(livery: .red, generation: .fourth, count: 4),

        .init(livery: .yellow, generation: .first, count: 2),
        .init(livery: .yellow, generation: .second, count: 2),
        .init(livery: .yellow, generation: .third, count: 3),

        .init(livery: .blue, generation: .first, count: 1),
        .init(livery: .blue, generation: .second, count: 2)
    ]

    public static let locomotiveCardCount =
        locomotiveCardInventory.reduce(0) { $0 + $1.count }

    public static func locomotiveCardCount(for livery: LocomotiveLivery) -> Int {
        locomotiveCardInventory
            .filter { $0.livery == livery }
            .reduce(0) { $0 + $1.count }
    }

}


