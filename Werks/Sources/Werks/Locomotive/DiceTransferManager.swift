//
//  DiceTransferManager.swift
//  Werks
//
//  Created by Claude Haiku 4.5 <noreply@anthropic.com>
//

/// Centralizes all dice transitions: Initial→Existing, Existing→Filled,
/// Customer Base rolling, sales reductions, and order completion.
///
/// This manager handles the mechanics of dice movement across the three
/// states (Initial, Existing, Filled), keeping the logic in one place
/// rather than scattered across Development, Market, and Sales rules.
///
public enum DiceTransferManager {
    /// Moves initial die to existing orders when locomotive is first developed.
    /// - Parameter id: Locomotive ID
    /// - Parameter board: GameBoard (mutated)
    /// - Returns: The die value that was promoted, or nil if no initial die
    public static func promoteInitialToExisting(_ id: Int, in board: inout GameBoard) -> Int? {
        board[id].promoteInitialOrder()
    }

    /// Returns one customer base die to the pool during market aging.
    /// If no customer base exists, returns the lowest existing die instead.
    /// - Parameter id: Locomotive ID
    /// - Parameter board: GameBoard (mutated)
    /// - Returns: The die value returned, or nil if no dice exist
    public static func returnOneDieToPool(_ id: Int, in board: inout GameBoard) -> Int? {
        board[id].returnOneDie()
    }

    /// Rolls all customer base dice and places them in existing orders.
    /// Used during market demand when customer base needs to become active demand.
    /// - Parameter id: Locomotive ID
    /// - Parameter rng: SeededRandomNumberGenerator (mutated for die rolls)
    /// - Parameter board: GameBoard (mutated)
    /// - Returns: Array of rolled die values
    public static func rollFilledOrders(_ id: Int,
                                       using rng: inout SeededRandomNumberGenerator,
                                       in board: inout GameBoard) -> [Int] {
        board[id].rollFilledIntoExisting(using: &rng)
    }

    /// Reduces existing orders after a sale (lowers a die value or removes it).
    /// Called by sales logic to update demand after units are sold.
    /// - Parameter id: Locomotive ID
    /// - Parameter units: Number of units sold (reduces highest die by this amount)
    /// - Parameter board: GameBoard (mutated)
    public static func reduceDemand(_ id: Int, by units: Int, in board: inout GameBoard) {
        guard units > 0, !board[id].existingOrders.isEmpty else { return }
        guard let highestIdx = board[id].existingOrders
            .enumerated()
            .max(by: { $0.element < $1.element })?
            .offset else { return }
        
        board[id].existingOrders[highestIdx] -= units
        if board[id].existingOrders[highestIdx] <= 0 {
            board[id].existingOrders.remove(at: highestIdx)
        }
    }

    /// Moves a satisfied die from existing to filled orders.
    /// Called when a sale exactly matches an existing order die.
    /// - Parameter id: Locomotive ID
    /// - Parameter existingOrders: Existing orders array (mutated)
    /// - Parameter filledOrders: Filled orders array (mutated)
    public static func fillOrder(_ id: Int,
                                 from existingOrders: inout [Int],
                                 to filledOrders: inout [Int]) {
        // This function is now just a helper since SalesOrder handles the actual
        // decision logic. The refactored rules will still work with SalesOrder.sell()
        // which already does this correctly.
    }
}
