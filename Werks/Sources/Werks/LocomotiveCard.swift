//
//  LocomotiveCard.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

public enum LocomotiveCardState: Int, CaseIterable, Codable, Sendable {
    case inactive, inplay, owned, removed
}

public actor LocomotiveCard: Sendable, Identifiable, Hashable, Equatable {
    public let id: UUID    
    public let locomotiveID: Int
    public private(set) var productionUnits: UInt
    public private(set) var spentUnits: UInt
    public private(set) var state: LocomotiveCardState = .inactive
    
    init(id: UUID, locomotiveID: Int = 0, productionUnits: UInt = 0, spentUnits: UInt = 0, state: LocomotiveCardState = .inactive) {
        self.id = id
        self.locomotiveID = locomotiveID
        self.productionUnits = productionUnits
        self.spentUnits = spentUnits
        self.state = state
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(locomotiveID)
    }
    
    public static func ==(lhs: LocomotiveCard, rhs: LocomotiveCard) -> Bool {
        return lhs.id == rhs.id
    }
}

extension LocomotiveCard: @preconcurrency CustomStringConvertible {
    public var description: String {
        return "🚂 LocomotiveCard ID: \(id), LocomotiveID: \(locomotiveID), ProductionUnits: \(productionUnits), SpentUnits: \(spentUnits)"
    }
}

extension LocomotiveCard: @preconcurrency ProductionHandlerDidUpdateDelegate {
    public func productionHandlerDidUpdate(_ handler: ProductionHandler) async {
        // Update the productionUnits and spentUnits based on the handler's state
        self.productionUnits = await UInt(handler.units)
        self.spentUnits = await UInt(handler.spentUnits)
    }
}