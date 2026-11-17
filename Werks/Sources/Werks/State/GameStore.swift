//
//  GameStore.swift
//  Werks
//
//  Created by AD on 13/11/2026.
//

//  The single owner of a LIVE game. This is where locking belongs.
//
//  The engine itself is value types: every action works on a private copy,
//  so the rules can never race. Races only appear when several callers
//  (UI, bots, timers) share one mutable game. `GameStore` is an actor, so
//  actions run strictly one at a time: two cash changes can never interleave,
//  and a validate-then-charge can never be split by another action.
//
//  Listeners subscribe with `updates()` and receive each new state together
//  with the events (including every Bank transaction) that produced it.
//  Not @MainActor: the UI layer hops to the main actor itself.
//

/// One accepted action and its consequences.
public struct GameUpdate: Sendable, Equatable {
    /// `nil` for the initial snapshot sent on subscription.
    public let action: GameAction?
    public let events: [GameEvent]
    public let state: GameState
}

public actor GameStore {
    public private(set) var game: Werks
    private var subscribers: [Int: AsyncStream<GameUpdate>.Continuation] = [:]
    private var nextSubscriberID = 0

    public init(game: Werks) {
        self.game = game
    }

    public init(players: [PlayerSetup], seed: UInt64, rules: GameRules = .standard) throws {
        self.game = try Werks(players: players, seed: seed, rules: rules)
    }

    public var state: GameState { game.state }
    public var legalActions: [GameAction] { game.legalActions }

    /// Applies an action atomically and notifies every subscriber.
    /// Throws (and notifies nobody) if the action is illegal.
    @discardableResult
    public func send(_ action: GameAction) throws -> [GameEvent] {
        let events = try game.apply(action)
        broadcast(GameUpdate(action: action, events: events, state: game.state))
        return events
    }

    /// A stream of updates. The current state is delivered immediately.
    /// Cancelling the consuming task unsubscribes automatically.
    public func updates() -> AsyncStream<GameUpdate> {
        let (stream, continuation) = AsyncStream.makeStream(of: GameUpdate.self, bufferingPolicy: .unbounded)
        let id = nextSubscriberID
        nextSubscriberID += 1
        subscribers[id] = continuation
        continuation.onTermination = { [weak self] _ in
            guard let self else { return }
            Task { await self.unsubscribe(id) }
        }
        continuation.yield(GameUpdate(action: nil, events: [], state: game.state))
        return stream
    }

    private func unsubscribe(_ id: Int) {
        subscribers[id] = nil
    }

    private func broadcast(_ update: GameUpdate) {
        for continuation in subscribers.values {
            continuation.yield(update)
        }
    }
}
