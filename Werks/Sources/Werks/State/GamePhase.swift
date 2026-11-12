//
//  GamePhase.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

/// The phases of a round, in order, plus the terminal state.
public enum GamePhase: Int, CaseIterable, Codable, Sendable, CustomStringConvertible {
    /// 1. Optional: each player may develop one locomotive.
    case development
    /// 2. Optional: buy or shift Production Units.
    case capacity
    /// 3. Mandatory, automatic: sell to Existing Orders.
    case production
    /// 4. Mandatory, automatic: 10% tax, end check, new player order.
    case taxes
    /// 5. Mandatory, automatic: new Existing Orders.
    case marketDemand
    /// Terminal.
    case gameOver

    /// Player-driven phases take per-player turns; the rest resolve in one step.
    public var isPlayerDriven: Bool { self == .development || self == .capacity }

    public var description: String {
        switch self {
        case .development: "Locomotive Development"
        case .capacity: "Production Capacity"
        case .production: "Locomotive Production"
        case .taxes: "Pay Taxes"
        case .marketDemand: "Market Demands"
        case .gameOver: "Game Over"
        }
    }
}
