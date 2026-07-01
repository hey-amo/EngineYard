//
//  File.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

import Foundation

// There are 14 Locomotives in the game, each locomotive has a number of `cards` assigned to it
// Each Locomotive `card` has productionUnits, productionUnitsSpent
// A player can only own 1 `card` per locomotive (max: 14 cards)

public class LocomotiveCard: Hashable, Equatable, Codable, ProductionUnitReadable, ProductionUnitMutable {
    public let id: Int
    public let locomotiveID: Int // which locomotive does this card belong to
    
    public private(set) var productionUnits: Int = 0
    public private(set) var productionUnitsSpent: Int = 0
    
    init(id: Int, locomotiveID: Int) {
        self.id = id
        self.locomotiveID = locomotiveID
    }

    internal func addProductionUnits(_ units: Int) throws {
        _ = try NumericValidator.validatePositiveAmount(units)
        productionUnits += units
    }
    internal func spendProductionUnits(_ units: Int) throws {
        _ = try NumericValidator.validatePositiveAmount(units)
        _ = try NumericValidator.validateSufficientFunds(productionUnits, required: units)
        productionUnits -= units
        productionUnitsSpent += units
    }
    internal func resetProductionUnits() {
        productionUnits += productionUnitsSpent
        productionUnitsSpent = 0
    }
    
    // Equatable conformance
    public static func == (lhs: LocomotiveCard, rhs: LocomotiveCard) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
