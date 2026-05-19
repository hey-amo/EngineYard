//
//  WerksGame.swift
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

public enum GameStage: Int, CaseIterable {
    case idle
    case gameSetup
    case locomotiveDevelopment
    case expandProductionCapacity
    case produceAndSellLocomotives
    case payTaxes
    case marketDemands
    case updateTurnOrder
    case gameOver
}


// Game state keeps board spaces and separate card instances
public struct GameState: Codable {
    var board: [BoardSpace]              // fixed order
    var cardInstances: [LocomotiveCardInstance]    // 43 cards (pool + owned)
    // players, turn, etc...
}