//
//  Player.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import Foundation
import GameplayKit

public class Player: NSObject, GKGameModelPlayer {
    public var playerId: Int
    public var avatar: String
    public var cash: Int
    public var hand: [Locomotive]
    
    init(playerId: Int, avatar: String, cash: Int = 0, hand: [Locomotive] = [Locomotive]()) {
        self.playerId = playerId
        self.avatar = avatar
        self.cash = cash
        self.hand = hand
    }
}
