//
//  TurnOrderManager.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

import Foundation

public protocol TurnTaking {
    associatedtype PlayerType

    var players: [PlayerType] { get }
    var currentPlayerIndex: Int { get }
    var currentPlayer: PlayerType? { get }

    func nextPlayer() -> PlayerType?
    func moveToNextPlayer()
}

public class TurnOrderManager: TurnTaking {
    public typealias PlayerType = Player

    public private(set) var players: [Player]
    public private(set) var currentPlayerIndex: Int

    public var currentPlayer: Player? {
        guard !players.isEmpty, players.indices.contains(currentPlayerIndex) else { return nil }
        return players[currentPlayerIndex]
    }

    public init(players: [Player], startingIndex: Int = 0) {
        self.players = players
        self.currentPlayerIndex = players.isEmpty ? 0 : min(max(startingIndex, 0), players.count - 1)
    }

    public func nextPlayer() -> Player? {
        guard !players.isEmpty else { return nil }
        let nextIndex = (currentPlayerIndex + 1) % players.count
        return players[nextIndex]
    }

    public func moveToNextPlayer() {
        guard !players.isEmpty else { return }
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
}