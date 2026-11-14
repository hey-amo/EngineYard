//
//  Livery.swift
//  Werks
//
/// The four locomotive types. Declaration order is the order in which
/// the Market Demands phase processes them (green → red → yellow → blue).
public enum Livery: Int, CaseIterable, Codable, Sendable, CustomStringConvertible {
    /// Passenger locomotives.
    case green = 1 
    /// Fast locomotives.
    case red
    /// Freight locomotives.
    case yellow
    /// Special locomotives.
    case blue

    public var description: String {
        switch self {
        case .green: "Green"
        case .red: "Red"
        case .yellow: "Yellow"
        case .blue: "Blue"
        }
    }
}
