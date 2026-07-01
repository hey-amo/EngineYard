//
//  ProductionHandler.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

import Foundation

public protocol ProductionUnitReadable {
    var productionUnits: Int { get }
    var productionUnitsSpent: Int { get }
}

internal protocol ProductionUnitMutable {
    func addProductionUnits(_ units: Int) throws
}

public class ProductionHandler {

    public init() {}

    /// Use cases:
    /// (1) Add Units to a LocomotiveCard
    /// (2) Exhaust Units from a LocomotiveCard by moving units to SpentUnits
    /// (3) Reset SpentUnits back to Units, and reset SpentUnits to 0
    /// (4) Shift production units from 1 LocomotiveCard to another LocomotiveCard (the player must own both cards, and the cost must be higher)
    
    public func addUnits(_ units: Int, to target: ProductionUnitReadable) throws {
        guard let mutableTarget = target as? ProductionUnitMutable else {
            return
        }
        try mutableTarget.addProductionUnits(units)
    }

    public func spendUnits() {

    }
    public func resetUnits() {
    }

    // needs validation
    public func shiftUnits(from: LocomotiveCard, to: LocomotiveCard, unitsToShift: Int) {
    }

}
