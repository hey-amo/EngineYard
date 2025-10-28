//
//  BoardSpace
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

// Mutable board space
public struct BoardSpace: Codable {
    public let index: Int              // fixed board order (1..14)
    public let locomotiveID: Int        // link to LocomotiveSpec.id
    public var status: SpaceStatus
    public var existingOrders: [Int]
    public var filledOrders: [Int]
    public var initialOrders: Int?     // nullable
}

public enum SpaceStatus: Int, Codable {
    case unavailable, active, rusting, obsolete
}
