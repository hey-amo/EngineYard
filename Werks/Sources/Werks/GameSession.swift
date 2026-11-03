//
//  GameSession.swift
//  Werks
//

import Foundation

public actor GameSession {
    private var board: GameBoard
    private var players: [Player]
    private var playerHands: [UUID: PlayerHand]

    public init(board: GameBoard = GameBoard()) {
        self.board = board
        self.players = []
        self.playerHands = [:]
    }

    public func boardSnapshot() -> [BoardSpace] {
        board.spaces
    }

    public func playerIDs() -> [UUID] {
        players.map(\.id)
    }

    public func addPlayer(_ player: Player) throws {
        guard !players.contains(where: { $0.id == player.id }) else {
            throw GameSessionError.duplicatePlayer
        }
        players.append(player)
        playerHands[player.id] = PlayerHand()
    }

    public func playerHand(for playerID: UUID) throws -> [LocomotiveCard] {
        guard let hand = playerHands[playerID] else {
            throw GameSessionError.playerNotFound
        }
        return hand.cards
    }

    public func setInitialOrder(_ value: Int, for locomotiveID: UInt) throws {
        try board.setInitialOrder(value, for: locomotiveID)
    }

    public func addExistingOrder(_ value: Int, for locomotiveID: UInt) throws {
        try board.addExistingOrder(value, for: locomotiveID)
    }

    public func addFilledOrder(_ value: Int, for locomotiveID: UInt) throws {
        try board.addFilledOrder(value, for: locomotiveID)
    }

    @discardableResult
    public func developLocomotive(
        _ locomotiveID: UInt,
        for playerID: UUID
    ) throws -> LocomotiveCard {
        guard var hand = playerHands[playerID] else {
            throw GameSessionError.playerNotFound
        }
        guard !hand.locomotiveIDs.contains(locomotiveID) else {
            throw GameSessionError.alreadyOwnsLocomotive
        }

        let definition = try board.developLocomotive(locomotiveID)
        let card = LocomotiveCard(
            id: UUID(),
            locomotiveID: Int(definition.id),
            productionUnits: 1,
            state: .owned
        )
        hand.cards.append(card)
        hand.locomotiveIDs.insert(locomotiveID)
        playerHands[playerID] = hand
        return card
    }

    public func markRusting(_ locomotiveID: UInt) throws {
        try board.markRusting(locomotiveID)
    }

    public func markObsolete(_ locomotiveID: UInt) throws {
        try board.markObsolete(locomotiveID)
    }
}

public enum GameSessionError: Error, Equatable, Sendable {
    case duplicatePlayer
    case playerNotFound
    case alreadyOwnsLocomotive
}

private struct PlayerHand {
    var cards: [LocomotiveCard] = []
    var locomotiveIDs: Set<UInt> = []
}
