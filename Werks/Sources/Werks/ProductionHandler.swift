//
//  ProductionHandler.swift
//  Werks

import Foundation

public protocol ProductionHandlerDelegate: Sendable {
    func addUnits(_ unitsToAdd: UInt) async
    func spendUnits(_ unitsToSpend: UInt) async
    func resetUnits() async
    func shiftUnits() async // from 1 card to another TBC
}

public protocol ProductionHandlerDidUpdateDelegate: Sendable {
    func productionHandlerDidUpdate(_ handler: ProductionHandler) async
}

public actor ProductionHandler: ProductionHandlerDelegate {
    public private(set) var units: UInt = 0
    public private(set) var spentUnits: UInt = 0

    public func addUnits(_ unitsToAdd: UInt) {
        // Implementation for adding units
        guard unitsToAdd > 0 else { return }
        self.units += unitsToAdd
    }

    public func spendUnits(_ unitsToSpend: UInt) {
        // Implementation for spending units
        guard unitsToSpend > 0, unitsToSpend <= units else { return }
        spentUnits += unitsToSpend
        units -= unitsToSpend
    }

    public func resetUnits() {
        // Implementation for resetting units to spent
        units = spentUnits
        spentUnits = 0
    }

    public func shiftUnits() {
        // Implementation for shifting units from 1 card to another
        // In the game, if the sending card has 0 units, it is removed from play
    }
}
