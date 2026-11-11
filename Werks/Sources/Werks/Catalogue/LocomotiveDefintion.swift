// LocomotiveDefintion.swift

/// The immutable printed data of one board space. These variables never change during a game.
public struct LocomotiveDefinition: Codable, Identifiable, Hashable, Sendable {
    /// Board position, 1...14. Also the "technology order" used for shifting.
    public let id: Int
    public let name: String
    public let livery: Livery
    public let generation: Generation
    /// Development cost (paid once to take the card).
    public let cost: Int
    /// Maximum dice in Existing Orders + Filled Orders (initial die excluded).
    public let maxDice: Int
    /// Number of copies of this locomotive's card in the box.
    public let cardCount: Int

    public init(id: Int, name: String, livery: Livery, generation: Generation,
                cost: Int, maxDice: Int, cardCount: Int) {
        self.id = id
        self.name = name
        self.livery = livery
        self.generation = generation
        self.cost = cost
        self.maxDice = maxDice
        self.cardCount = cardCount
    }

    /// Cost of one Production Unit: `cost / 2`, rounded up.
    public var productionCost: Int { (cost + 1) / 2 }

    /// Income per unit sold: `productionCost / 2`, rounded up.
    public var income: Int { (productionCost + 1) / 2 }
}

extension LocomotiveDefinition: CustomStringConvertible {
    public var description: String {
        "\(name) (\(livery), \(generation))"
    }
}