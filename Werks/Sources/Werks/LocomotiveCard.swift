//
//  LocomotiveCard.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

public actor LocomotiveCard: Sendable, Identifiable, Hashable, Equatable {
    public let id: UUID
    public let locomotiveID: Int
    public private(set) var productionUnits: Int
    
    init(id: UUID, locomotiveID: Int = 0, productionUnits: Int = 0) {
        self.id = id
        self.locomotiveID = locomotiveID
        self.productionUnits = productionUnits
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(locomotiveID)
    }
    
    public static func ==(lhs: LocomotiveCard, rhs: LocomotiveCard) -> Bool {
        return lhs.id == rhs.id
    }
}
