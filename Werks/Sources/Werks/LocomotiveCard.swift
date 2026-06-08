//
//  File.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

import Foundation

typealias LocoCard = LocomotiveCard

// There are 14 Locomotives in the game, each locomotive has a number of `cards` assigned to it
// Each Locomotive `card` has productionUnits, productionUnitsSpent
// A player can only own 1 `card` per locomotive (max: 14 cards)

public class LocomotiveCard: Hashable, Equatable, Codable {
    public let id: Int
    public let locomotiveID: Int // which locomotive does this card belong to
    
    // can this be written better?
    public var productionUnits: Int = 0
    public var productionUnitsSpent: Int = 0
    
    init(id: Int, locomotiveID: Int) {
        self.id = id
        self.locomotiveID = locomotiveID
        // set production units
        
    }
    
    /*
    // QUERY: is there a better way to write this?
    // QUERY: Should this be a tuple?
     // There should be a handler to update productionUnits, productionUnitsSpent
    public struct ProductionUnits {
        public let units: Int
        public let unitsSpent: Int
    }
    */
    
    // Equatable conformance
    public static func == (lhs: LocomotiveCard, rhs: LocomotiveCard) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
