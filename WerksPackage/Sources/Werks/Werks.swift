//
//  Werks.swift
//  Werks
//
//  Created by Amarjit on 13/11/2026.
//


/// Convenience value type for the app layer: the current state plus the
/// message log and the action history (for replays). A plain value: for a
/// shared, live game use `GameStore`, which serialises access.
public struct Werks: Codable, Equatable, Sendable {
    public let seed: UInt64
    public private(set) var state: GameState
    /// Every event so far, oldest first. Use `log.reversed()` for latest-first.
    public private(set) var log: [GameEvent]
    /// Every accepted action, for replay.
    public private(set) var history: [GameAction]

    public init(players: [PlayerSetup], seed: UInt64, rules: GameRules = .standard) throws {
        let result = try GameEngine.newGame(players: players, seed: seed, rules: rules)
        self.seed = seed
        self.state = result.state
        self.log = result.events
        self.history = []
    }

    /// Applies an action; returns the new events. Throws without changing anything on error.
    @discardableResult
    public mutating func apply(_ action: GameAction) throws -> [GameEvent] {
        let result = try GameEngine.apply(action, to: state)
        state = result.state
        log.append(contentsOf: result.events)
        history.append(action)
        return result.events
    }

    public var legalActions: [GameAction] { GameEngine.legalActions(in: state) }

    /// Rebuilds a game by replaying actions from a seed.
    public static func replay(players: [PlayerSetup], seed: UInt64, rules: GameRules = .standard,
                              actions: [GameAction]) throws -> Werks {
        var game = try Werks(players: players, seed: seed, rules: rules)
        for action in actions { try game.apply(action) }
        return game
    }
}
