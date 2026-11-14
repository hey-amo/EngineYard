//
//  GameRules.swift
//  Werks
//
//  Created by AD on 12/11/2026.
//

/// From the rulebook, stored with the game.
public struct GameRules: Codable, Equatable, Sendable {
    /// Coins needed AFTER taxes to end the game. Rulebook: 300 Coins (Talers).
    public var winningCoins: Int
    /// Tax rate in percent, rounded down. Rulebook: 10.
    public var taxPercent: Int
    /// Starting cash for 3–4 players. Rulebook: 12.
    public var startingCoins: Int
    /// Starting cash for 5 players. Rulebook: 14.
    public var startingCoinsFivePlayers: Int

    public init(winningCoins: Int = 300, taxPercent: Int = 10,
                startingCoins: Int = 12, startingCoinsFivePlayers: Int = 14) {
        self.winningCoins = winningCoins
        self.taxPercent = taxPercent
        self.startingCoins = startingCoins
        self.startingCoinsFivePlayers = startingCoinsFivePlayers
    }

    /// The rules exactly as printed in the rulebook.
    public static let standard = GameRules()

    public func startingCoins(playerCount: Int) -> Int {
        playerCount == 5 ? startingCoinsFivePlayers : startingCoins
    }
}
