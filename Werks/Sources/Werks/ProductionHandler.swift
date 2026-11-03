//
//  ProductionHandler.swift
//  Werks

import Foundation

public protocol ProductionHandlerDelegate: Sendable {
    func addUnits(_ units: UInt) async
    func spendUnits(_ units: UInt) async
    func resetUnits() async
    func shiftUnits() async // from 1 card to another TBC
}

public actor ProductionHandler: ProductionHandlerDelegate {
    private var units: UInt = 0
    private var spentUnits: UInt = 0

    public func addUnits(_ units: UInt) {
        // Implementation for adding units
        guard units > 0 else { return }
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
        // Implementation for shifting units
    }
}
