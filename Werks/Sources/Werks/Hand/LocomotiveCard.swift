// LocomotiveCard.swift

/// A locomotive card in a hand: which locomotive, and its Production Units.
public struct LocomotiveCard: Codable, Equatable, Hashable, Sendable, Identifiable {
    /// Board ID of the locomotive.
    public let locomotiveID: Int
    /// Only `ProductionManager` / `ProductionUnits` change this.
    public internal(set) var production: ProductionUnits

    public var id: Int { locomotiveID }

    /// A freshly developed card carries one Production Unit.
    public init(locomotiveID: Int, units: Int = 1) {
        self.locomotiveID = locomotiveID
        self.production = ProductionUnits(units: units)
    }

    public var definition: LocomotiveDefinition {
        guard let definition = Catalogue.definition(for: locomotiveID) else {
            preconditionFailure("LocomotiveCard has invalid id \(locomotiveID)")
        }
        return definition
    }
}
