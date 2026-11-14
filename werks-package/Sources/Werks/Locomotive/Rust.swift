//
//  Rust.swift
//  Werks
//
//

/// Lifecycle flag of a board space.
///
/// - Important: `rusting` is informational only (logging / UI strings).
///   Rules logic always decides on `Generation` and dice, never on `rusting`.
public enum Rust: Int, CaseIterable, Codable, Sendable, CustomStringConvertible {
    /// Exists in the game world but nothing has happened yet; cannot be bought.
    case unavailable
    /// Has (or has had) dice: initial, existing or filled orders.
    case available
    /// Was the older generation in the 2-generation market case.
    case rusting
    /// Dice returned to the pool; can never be bought or sold again.
    case obsolete

    public var description: String {
        switch self {
        case .unavailable: "unavailable"
        case .available: "available"
        case .rusting: "rusting"
        case .obsolete: "obsolete"
        }
    }
}
