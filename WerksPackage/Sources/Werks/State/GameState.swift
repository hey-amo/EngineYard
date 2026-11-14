//
//  GameState.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

/// WERKS: GameState

/// The complete, Codable snapshot of a game. Encoding this is a save game;
/// replaying the same actions from the same seed reproduces it exactly.
///
/// Ownership of each part:
/// - `board`   – dice and card supply (`LocomotiveState`, `SalesOrder`)
/// - `players` – identity and `Hand` (cards via `Hand`, units via `ProductionManager`)
/// - `bank`    – every coin (`Bank`)
/// - `rng`     – every die roll
public struct GameState: Codable, Equatable, Sendable {
    public internal(set) var rules: GameRules
    /// Players indexed by `Player.id`.
    public internal(set) var players: [Player]
    public internal(set) var bank: Bank
    /// Player IDs in current turn order (index 0 holds the "1" card).
    public internal(set) var turnOrder: [Int]
    public internal(set) var board: GameBoard
    public internal(set) var phase: GamePhase
    /// Position in `turnOrder` of the acting player (player-driven phases only).
    public internal(set) var turnIndex: Int
    /// 1-based round counter.
    public internal(set) var round: Int
    /// Winners once `phase == .gameOver` (several on a tie).
    public internal(set) var winners: [Int]
    /// Source of every die roll; part of the state for reproducibility.
    public internal(set) var rng: SeededRandomNumberGenerator

    init(rules: GameRules, players: [Player], bank: Bank, turnOrder: [Int],
         board: GameBoard, rng: SeededRandomNumberGenerator) {
        precondition(bank.balances.count == players.count, "One bank account per player")
        self.rules = rules
        self.players = players
        self.bank = bank
        self.turnOrder = turnOrder
        self.board = board
        self.phase = .development
        self.turnIndex = 0
        self.round = 1
        self.winners = []
        self.rng = rng
    }

    /// The player expected to act, or `nil` during automatic phases / game over.
    public var currentPlayerID: Int? {
        guard phase.isPlayerDriven, turnOrder.indices.contains(turnIndex) else { return nil }
        return turnOrder[turnIndex]
    }

    public func player(_ id: Int) -> Player? {
        players.indices.contains(id) ? players[id] : nil
    }

    /// A player's cash (read from the Bank).
    public func coins(of playerID: Int) -> Int { bank.balance(of: playerID) }

    public func status(of playerID: Int) -> PlayerStatus {
        currentPlayerID == playerID ? .onTurn : .idle
    }

    public func isOnTurn(_ playerID: Int) -> Bool { status(of: playerID) == .onTurn }

    public var isGameOver: Bool { phase == .gameOver }

    // MARK: - Turn flow (engine only)

    /// Ends the current player's turn; moves on to the next phase after the last player.
    mutating func endTurn(events: inout [GameEvent]) {
        turnIndex += 1
        guard turnIndex >= turnOrder.count else { return }
        switch phase {
        case .development: enter(.capacity, events: &events)
        case .capacity: enter(.production, events: &events)
        default: turnIndex = 0
        }
    }

    mutating func enter(_ newPhase: GamePhase, events: inout [GameEvent]) {
        phase = newPhase
        turnIndex = 0
        events.append(.phaseStarted(newPhase, round: round))
    }
}
