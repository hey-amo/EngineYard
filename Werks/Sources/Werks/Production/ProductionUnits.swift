//
//  ProductionUnits.swift
//  Werks
//
//  Created by AD on 12/11/2026.
//

//  The ONLY type that does Production Unit arithmetic.
//

/// The Production Unit counters on one locomotive card.
///
/// Mirrors the physical game:
/// - `units` are the counters **on** the card (available to sell).
/// - `spentUnits` are the counters slid **above** the card after a sale.
/// - `reset()` puts every spent counter back on the card.
///
/// `Units` are never destroyed by selling; they are only `spent` and `reset`.
public struct ProductionUnits: Codable, Equatable, Hashable, Sendable {
    /// Counters on the card, available to sell.
    public private(set) var units: Int
    /// Counters above the card, already sold this Production phase.
    public private(set) var spentUnits: Int

    public init(units: Int = 1, spentUnits: Int = 0) {
        precondition(units >= 0 && spentUnits >= 0, "Production units cannot be negative")
        self.units = units
        self.spentUnits = spentUnits
    }

    /// All counters owned, on or above the card.
    public var total: Int { units + spentUnits }

    /// `true` when the card holds no counters at all.
    public var isEmpty: Bool { total == 0 }

    /// Places new counters on the card (bought capacity, or shifted in).
    public mutating func add(_ count: Int) throws {
        guard count > 0 else { throw GameError.invalidUnitCount(count) }
        units += count
    }

    /// Slides `count` counters above the card after selling them.
    public mutating func spend(_ count: Int) throws {
        guard count > 0 else { throw GameError.invalidUnitCount(count) }
        guard count <= units else { throw GameError.notEnoughUnits(requested: count, available: units) }
        units -= count
        spentUnits += count
    }

    /// Takes counters off the card for good (shifting them to another card).
    public mutating func remove(_ count: Int) throws {
        guard count > 0 else { throw GameError.invalidUnitCount(count) }
        guard count <= units else { throw GameError.notEnoughUnits(requested: count, available: units) }
        units -= count
    }

    /// End of Production: every spent counter goes back on the card.
    public mutating func reset() {
        units += spentUnits
        spentUnits = 0
    }
}
