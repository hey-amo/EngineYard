//
//  LocomotiveCardSpec
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

// CardInstance represents one of the 43 physical cards
public struct LocomotiveCardInstance: Codable {
    public let id: UUID
    public let locomotiveID: Int        // link to LocomotiveSpec.id
    public var ownerPlayerID: UUID?    // nil => in pool/market
    public var productionUnits: Int
    public var productionSpentUnits: Int

    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<LocomotiveCardInstance.CodingKeys>  = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.locomotiveID = try container.decode(Int.self, forKey: .locomotiveID)
        self.ownerPlayerID = try container.decodeIfPresent(UUID.self, forKey: .ownerPlayerID)
        self.productionUnits = try container.decode(Int.self, forKey: .productionUnits)
        self.productionSpentUnits = try container.decode(Int.self, forKey: .productionSpentUnits)
    }
}