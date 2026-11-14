//
//  BankTransaction.swift
//  Werks
//
//

/// Why money moved.
public enum BankReason: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    case development(locomotiveID: Int)
    case productionCapacity(locomotiveID: Int, units: Int)
    case shiftCapacity(from: Int, to: Int, units: Int)
    case sale(locomotiveID: Int, units: Int)
    case tax

    public var description: String {
        func loco(_ id: Int) -> String { Catalogue.definition(for: id)?.name ?? "#\(id)" }
        switch self {
        case let .development(id): return "developed \(loco(id))"
        case let .productionCapacity(id, units): return "\(units) unit(s) on \(loco(id))"
        case let .shiftCapacity(from, to, units): return "shifted \(units) unit(s) \(loco(from)) → \(loco(to))"
        case let .sale(id, units): return "sell \(units) × \(loco(id))"
        case .tax: return "tax"
        }
    }
}

/// A receipt for one movement of money between a player and the Bank.
public struct BankTransaction: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let playerID: Int
    /// Positive: Bank pays the player. Negative: the player pays the Bank.
    public let amount: Int
    public let reason: BankReason
    /// The player's balance after this transaction.
    public let balanceAfter: Int

    public var description: String {
        let verb = amount >= 0 ? "receives" : "pays"
        return "Player \(playerID) \(verb) $\(abs(amount)) (\(reason)); balance $\(balanceAfter)"
    }
}
