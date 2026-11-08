//
//  SalesOrder.swift
//  Werks
//
//  Pure order-dice logic. Knows nothing about locomotives, players or money.
//  Based on the original EngineYard `SalesOrder`: the same three queries
//  (`match`, `lower`, `higher`), plus `decide` (enforces the rulebook's
//  priority order) and `sell` (applies the decision to the dice).
//

/// Which sale case applies, and which die it uses.
public enum SaleDecision: Equatable, Sendable {
    /// a) Units equal a die. That die moves to the Customer Base.
    case sameNumber(index: Int)
    /// b) Fewer units than the highest die. The highest die is reduced.
    case lowerNumber(index: Int)
    /// c) More units than the highest die. Sell that many; the die moves to the Customer Base.
    case largerNumber(index: Int)

    public var saleCase: SaleCase {
        switch self {
        case .sameNumber: .sameNumber
        case .lowerNumber: .lowerNumber
        case .largerNumber: .largerNumber
        }
    }
}

/// How a sale matched the Existing Orders.
public enum SaleCase: String, Codable, Sendable {
    case sameNumber, lowerNumber, largerNumber
}

/// The result of one sale.
public struct SaleResult: Equatable, Sendable {
    public let unitsSold: Int
    public let saleCase: SaleCase
}

/// Existing Orders and Customer Base dice for one locomotive.
public struct SalesOrder: Equatable, Sendable {
    public private(set) var existing: [Int]
    public private(set) var filled: [Int]

    public init(existing: [Int], filled: [Int] = []) {
        self.existing = existing
        self.filled = filled
    }

    // MARK: - Queries (no mutation)

    /// Index of the first die equal to `units`.
    public func match(_ units: Int) -> Int? {
        existing.firstIndex(of: units)
    }

    /// Index of the first highest die, if `units` is below it.
    public func lower(_ units: Int) -> Int? {
        guard let index = highestIndex, units < existing[index] else { return nil }
        return index
    }

    /// Index of the first highest die, if `units` is above it.
    public func higher(_ units: Int) -> Int? {
        guard let index = highestIndex, units > existing[index] else { return nil }
        return index
    }

    /// Applies the rulebook priority: a) same, then b) lower, then c) larger.
    /// `nil` when there is no demand or no units.
    public func decide(_ units: Int) -> SaleDecision? {
        guard units > 0 else { return nil }
        if let index = match(units) { return .sameNumber(index: index) }
        if let index = lower(units) { return .lowerNumber(index: index) }
        if let index = higher(units) { return .largerNumber(index: index) }
        return nil
    }

    private var highestIndex: Int? {
        guard let highest = existing.max() else { return nil }
        return existing.firstIndex(of: highest)
    }

    // MARK: - Mutation

    /// Decides and applies a sale of up to `units`.
    @discardableResult
    public mutating func sell(_ units: Int) -> SaleResult? {
        guard let decision = decide(units) else { return nil }
        switch decision {
        case let .sameNumber(index):
            filled.append(existing.remove(at: index))
            return SaleResult(unitsSold: units, saleCase: .sameNumber)
        case let .lowerNumber(index):
            existing[index] -= units
            return SaleResult(unitsSold: units, saleCase: .lowerNumber)
        case let .largerNumber(index):
            let sold = existing.remove(at: index)
            filled.append(sold)
            return SaleResult(unitsSold: sold, saleCase: .largerNumber)
        }
    }
}
