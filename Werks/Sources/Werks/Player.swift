//
//  Player.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import Foundation
import GameplayKit

// A list of all turn states
public enum PlayerTurnState: Int, CaseIterable, Codable {
    case idle, onTurn, thinking, takingTurn
}

public class Player: NSObject, GKGameModelPlayer {
    public var playerId: Int
    public var avatar: String
    public var cash: Int
    public var isAI: Bool
    public var cards: [LocomotiveCard]
    
    init(playerId: Int, avatar: String, cash: Int = 0, isAI: Bool = false, cards: [LocomotiveCard] = [LocomotiveCard]()) {
        self.playerId = playerId
        self.avatar = avatar
        self.cash = cash
        self.isAI = isAI
        self.cards = cards 
    }
}
