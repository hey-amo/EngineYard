// Player.swift

/// Whether a player is the one expected to act.
public enum PlayerStatus: Int, Codable, Sendable {
    case idle, onTurn
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
    public let avatar: String
    /// Carried for the app layer; the engine treats all players the same.
    public let isAI: Bool
    //public internal(set) var hand: Hand

    public init(id: Int, name: String, avatar: String = "", isAI: Bool = false/*, hand: Hand = Hand()*/) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.isAI = isAI
        //self.hand = hand
    }
}
