//
//  GameError.swift
//

/// Why an action was rejected. A rejected action never changes the state.
public enum GameError: Error, Equatable, Sendable {
    case invalidPlayerCount(Int)
    case gameOver
    /// The action is not allowed in the current phase.
    case wrongPhase(Phase)
    case unknownLocomotive(Int)
    /// The space has no initial die and no existing/filled orders.
    case locomotiveUnavailable(Int)
    case locomotiveObsolete(Int)
    case noCardsAvailable(Int)
    case alreadyDeveloped(Int)
    case insufficientFunds(required: Int, available: Int)
    case locomotiveNotOwned(Int)
    case invalidUnitCount(Int)
    case notEnoughUnits(requested: Int, available: Int)
    /// Units may only move to a strictly higher board ID.
    case cannotShiftDown(from: Int, to: Int)
}
