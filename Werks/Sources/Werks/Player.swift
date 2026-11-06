//
//  Player.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

public actor Player: Identifiable, Hashable {
    public nonisolated let id: UUID

    public private(set) var coins: UInt32

    public init(id: UUID = UUID(), coins: UInt32) {
        self.id = id
        self.coins = coins
    }

    public nonisolated static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
