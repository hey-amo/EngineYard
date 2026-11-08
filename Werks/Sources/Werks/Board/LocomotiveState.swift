// LocomotiveState.swift
// Werks

/// The mutable part of a board space. The printed data lives in
/// `LocomotiveDefinition`; only these fields change during play.
public struct LocomotiveState: Codable, Equatable, Sendable, Identifiable {
    /// Board ID; links to `Catalogue.definition(for:)`.
    public let id: Int
    /// Unbought card copies remaining on the board.
    public internal(set) var availableCardCount: Int
    /// The single initial die. Set at most once per game, never repopulated.
    public internal(set) var initialOrder: Int?
    /// Market demand dice (die faces 1...6).
    public internal(set) var existingOrders: [Int]
    /// Customer Base dice (orders that were completely filled).
    public internal(set) var filledOrders: [Int]
    public internal(set) var rust: Rust

    /// A fresh space: no orders, all cards present, `unavailable`.
    public init(definition: LocomotiveDefinition) {
        self.id = definition.id
        self.availableCardCount = definition.cardCount
        self.initialOrder = nil
        self.existingOrders = []
        self.filledOrders = []
        self.rust = .unavailable
    }

    /// The printed data for this space.
    public var definition: LocomotiveDefinition {
        guard let definition = Catalogue.definition(for: id) else {
            preconditionFailure("LocomotiveState has invalid id \(id)")
        }
        return definition
    }

    /// Dice in Existing + Filled orders (the initial die never counts).
    public var diceCount: Int { existingOrders.count + filledOrders.count }

    /// A generation "exists" for Market Demands when it has existing or filled dice.
    public var isInMarket: Bool { !existingOrders.isEmpty || !filledOrders.isEmpty }

    /// Units can be sold here only while Existing Orders exist.
    public var hasDemand: Bool { !existingOrders.isEmpty }

    /// Board-side purchase condition (ignores the buyer's cash and holdings).
    public var isPurchasable: Bool {
        rust != .obsolete && availableCardCount > 0 && (initialOrder != nil || isInMarket)
    }

    // MARK: - Mutations (engine only)

    /// Places the one-and-only initial die and makes the space available.
    mutating func placeInitialOrder(_ die: Int) {
        initialOrder = die
        if rust == .unavailable { rust = .available }
    }

    /// Moves the initial die -> Existing Orders unchanged. Returns the die moved.
    @discardableResult
    mutating func promoteInitialOrder() -> Int? {
        guard let die = initialOrder else { return nil }
        existingOrders.append(die)
        initialOrder = nil
        return die
    }

    /// Re-rolls every Customer Base die into Existing Orders.
    mutating func rollFilledIntoExisting(using rng: inout SeededRandomNumberGenerator) -> [Int] {
        let rolled = filledOrders.map { _ in rng.rollDie() }
        existingOrders.append(contentsOf: rolled)
        filledOrders.removeAll()
        return rolled
    }

    /// The order dice as a `SalesOrder` for the sales logic.
    public var salesOrder: SalesOrder {
        SalesOrder(existing: existingOrders, filled: filledOrders)
    }

    /// Writes back the dice after sales.
    mutating func update(from order: SalesOrder) {
        existingOrders = order.existing
        filledOrders = order.filled
    }

    /// Market case c (older generation): return one Customer Base die to the
    /// pool, or, if the Customer Base is empty, the lowest Existing Orders die.
    /// - Returns: the die returned, or `nil` if the space had no dice.
    mutating func returnOneDie() -> Int? {
        if !filledOrders.isEmpty { return filledOrders.removeLast() }
        guard let lowest = existingOrders.min(), let index = existingOrders.firstIndex(of: lowest) else { return nil }
        return existingOrders.remove(at: index)
    }

    /// Clears all dice and cards; the space can never be bought or sold again.
    mutating func makeObsolete() {
        availableCardCount = 0
        initialOrder = nil
        existingOrders.removeAll()
        filledOrders.removeAll()
        rust = .obsolete
    }
}
