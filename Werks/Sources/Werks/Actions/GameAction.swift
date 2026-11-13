//
//  GameAction.swift
//  Werks
//

/// Every way the game can be advanced. Player actions always apply to
/// `GameState.currentPlayerID`.
public enum GameAction: Codable, Equatable, Hashable, Sendable {
    /// Development phase: take a card of this locomotive (ends the turn).
    case develop(locomotiveID: Int)
    /// Capacity phase: buy new Production Units for an owned card.
    case buyCapacity(locomotiveID: Int, units: Int)
    /// Capacity phase: move units to a card with a higher board ID, paying the difference.
    case shiftCapacity(from: Int, to: Int, units: Int)
    /// Development / Capacity: end this player's turn.
    case pass
    /// Production / Taxes / Market Demands: resolve the automatic phase.
    case resolvePhase
}
