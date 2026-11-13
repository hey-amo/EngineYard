//
//  GameEngine.swift
//  Werks
//

//  The public, stateless entry point. All functions are pure: they take a
//  state and return a new one, so they are safe to call from any actor or
//  thread (no @MainActor, no shared mutable state).
//
//  Every action is a transaction: it runs on a private copy of the state,
//  and the copy is returned only if every step succeeded. A failure halfway
//  (e.g. the Bank refuses a charge) can never leave a half-applied action.
//

/// A new state plus the events produced getting there.
public struct ActionResult: Equatable, Sendable {
    public let state: GameState
    public let events: [GameEvent]
}

public enum GameEngine {
    /// Starts a game for 3–5 players from a seed.
    public static func newGame(players: [PlayerSetup], seed: UInt64,
                               rules: GameRules = .standard) throws -> ActionResult {
        let (state, events) = try GameState.setUp(players, seed: seed, rules: rules)
        return ActionResult(state: state, events: events)
    }

    /// Validates and applies an action. On error the input state is untouched.
    public static func apply(_ action: GameAction, to state: GameState) throws -> ActionResult {
        guard !state.isGameOver else { throw GameError.gameOver }
        var next = state
        var events: [GameEvent] = []

        switch action {
        case let .develop(id):
            try next.develop(id, events: &events)
        case let .buyCapacity(id, units):
            try next.buyCapacity(id, units: units, events: &events)
        case let .shiftCapacity(from, to, units):
            try next.shiftCapacity(from: from, to: to, units: units, events: &events)
        case .pass:
            guard let playerID = next.currentPlayerID else { throw GameError.wrongPhase(next.phase) }
            events.append(.passed(playerID: playerID))
            next.endTurn(events: &events)
        case .resolvePhase:
            switch next.phase {
            case .production: next.resolveProduction(events: &events)
            case .taxes: next.resolveTaxes(events: &events)
            case .marketDemand: next.resolveMarketDemand(events: &events)
            default: throw GameError.wrongPhase(next.phase)
            }
        }
        return ActionResult(state: next, events: events)
    }

    /// Legal actions for the current position. Capacity actions are listed
    /// one unit at a time; larger amounts are legal if affordable.
    public static func legalActions(in state: GameState) -> [GameAction] {
        switch state.phase {
        case .gameOver:
            return []
        case .production, .taxes, .marketDemand:
            return [.resolvePhase]
        case .development:
            guard let playerID = state.currentPlayerID else { return [] }
            let develops = Catalogue.ids
                .filter { (try? state.validateDevelop($0, by: playerID)) != nil }
                .map { GameAction.develop(locomotiveID: $0) }
            return develops + [.pass]
        case .capacity:
            guard let playerID = state.currentPlayerID else { return [] }
            let owned = state.players[playerID].hand.ids
            var actions: [GameAction] = owned
                .filter { (try? state.validateBuyCapacity($0, units: 1, by: playerID)) != nil }
                .map { .buyCapacity(locomotiveID: $0, units: 1) }
            for source in owned {
                for target in owned where
                    (try? state.validateShiftCapacity(from: source, to: target, units: 1, by: playerID)) != nil {
                    actions.append(.shiftCapacity(from: source, to: target, units: 1))
                }
            }
            return actions + [.pass]
        }
    }

    /// Whether an action would be accepted.
    public static func isLegal(_ action: GameAction, in state: GameState) -> Bool {
        (try? apply(action, to: state)) != nil
    }
}
