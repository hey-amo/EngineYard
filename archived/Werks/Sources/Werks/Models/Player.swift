//
//  Player
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

final public class Player: Identifiable, Equatable, Hashable, TurnTaking {
    public var playerId: Int
    public var name: String
    public var coins: Int
    
    init(id: Int, name: String, coins: Int = 0) {
        self.id = id
        self.name = name
        self.coins = coins
    }

    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}