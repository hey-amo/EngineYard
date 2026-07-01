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

public enum ProductionShiftError: Error {
    case sameLocomotiveCard
    case insufficientUnits
    case invalidTargetCard 
    case invalidSourceCard
}

extension ProductionShiftError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .sameLocomotiveCard:
            return NSLocalizedString("Cannot shift units to the same locomotive card.", comment: "")
        case .insufficientUnits:
            return NSLocalizedString("Insufficient production units to shift.", comment: "")
        case .invalidTargetCard:
            return NSLocalizedString("Invalid target locomotive card.", comment: "")
        case .invalidSourceCard:
            return NSLocalizedString("Invalid source locomotive card.", comment: "")
        }
    }
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

    public func spendUnits(_ units: Int, from target: ProductionUnitReadable) throws {
        guard let mutableTarget: any ProductionUnitMutable = target as? ProductionUnitMutable else {
            return
        }
        try mutableTarget.spendProductionUnits(units)
    }
    public func resetUnits() {
        guard let mutableTarget: any ProductionUnitMutable = target as? ProductionUnitMutable else {
            return
        }
        mutableTarget.resetProductionUnits()
    }

    // needs validation
    public func shiftUnits(from: LocomotiveCard, to: LocomotiveCard, unitsToShift: Int) throws {
        // the player needs to own both cards, and the cost must be higher and the card has to be active?
        // can't be the same card, 
        guard from.locomotiveID != to.locomotiveID else {
            return
        }
    }

}
