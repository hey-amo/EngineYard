//
//  ProductionManager.swift
//  Werks
//
//  Created by AD on 12/11/2026.
//

//
//  Production Unit operations that span the cards of a hand.
//  Knows about `Hand` and `ProductionUnits`; knows nothing about players, money or game state.
//

public enum ProductionManager {
    /// Adds bought units to one card.
    public static func addUnits(_ count: Int, to locomotiveID: Int, in hand: inout Hand) throws {
        try hand.modify(locomotiveID) { try $0.production.add(count) }
    }

    /// Marks units on one card as sold this phase.
    public static func spendUnits(_ count: Int, on locomotiveID: Int, in hand: inout Hand) throws {
        try hand.modify(locomotiveID) { try $0.production.spend(count) }
    }

    /// Moves units from one card to another. Both cards must be in the hand.
    /// Validates everything before mutating, so a failure changes nothing.
    /// - Returns: `true` if the source card is now empty.
    @discardableResult
    public static func transfer(_ count: Int, from source: Int, to target: Int, in hand: inout Hand) throws -> Bool {
        guard count > 0 else { throw GameError.invalidUnitCount(count) }
        guard let sourceCard = hand.card(source) else { throw GameError.locomotiveNotOwned(source) }
        guard hand.contains(target) else { throw GameError.locomotiveNotOwned(target) }
        guard sourceCard.production.units >= count else {
            throw GameError.notEnoughUnits(requested: count, available: sourceCard.production.units)
        }
        try hand.modify(source) { try $0.production.remove(count) }
        try hand.modify(target) { try $0.production.add(count) }
        return hand.card(source)?.production.isEmpty ?? true
    }

    /// End of the Production phase: every card's spent units go back on the card.
    public static func resetAll(in hand: inout Hand) {
        for id in hand.ids {
            try? hand.modify(id) { $0.production.reset() }
        }
    }
}
