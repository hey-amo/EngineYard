//
//  Player.swift
//  Werks
//
//

/// Whether a player is the one expected to act.
public enum PlayerStatus: Int, Codable, Sendable {
    case idle, onTurn
}

/// the idea of this protocol is that it could be used on views; but is it is read-only, how do changes get pushed?
/// it needs to pull in their coins from the bank
/// it needs to pull in their hand of cards
/// needs to be codable, hashable, equatable, thread-safe
public protocol PlayerProfileCard {
    var id: Int { get }
    var name: String { get }
    var avatar: String { get }
    var isAI: Bool { get }
    var turnOrder: Int { get } // their relative turn order index integer
    var isOnTurn: Bool { get } // is the player currently on turn
    var coins: Int { get } // cash on hand
    var hand: String { get } // to be: a list of their locomotive cards
}


/// Who a player is, plus their hand.
///
/// A player holds no logic of their own:
/// - cards and units belong to `hand`, changed only through `Hand` and `ProductionManager`;
/// - coins live in the `Bank` (`GameState.coins(of:)`), changed only by the `Bank`.
public struct Player: Codable, Equatable, Sendable, Identifiable {
    /// Stable identifier: index into `GameState.players`, and the Bank account number.
    public let id: Int
    public let name: String
    public let avatar: String /// resourceName
    /// Carried for the app layer; the engine treats all players the same.
    public let isAI: Bool
    public internal(set) var hand: Hand

    public init(id: Int, name: String, avatar: String = "", isAI: Bool = false, hand: Hand = Hand()) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.isAI = isAI
        self.hand = hand
    }
}
