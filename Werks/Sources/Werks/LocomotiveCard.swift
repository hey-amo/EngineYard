//
//  File.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

import Foundation

typealias LocoCard = LocomotiveCard

// Every locomotive has a collection of cards assigned to it
// Every locomotiveCard has production units
// A single LocomotiveCard from each locomotive can be owned by a player (max: 14)

public struct LocomotiveCard: Hashable, Equatable, Codable {
    public let id: Int
    public let locomotiveID: Int // which locomotive does this card belong to
    
    // QUERY: is there a better way to write this?
    // QUERY: Should this be a tuple?
    public struct ProductionUnits {
        public let units: Int
        public let unitsSpent: Int
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

extension LocomotiveCard.ProductionUnits {
    public func addUnits(_ amount: Int = 0) {
        // use a handler to do this
    }
    public func spendUnits(_ amount: Int = 0) {
        // use a handler to do this
    }
    public func resetProduction() {
        // use a handler to do this
    }
}
