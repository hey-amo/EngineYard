// Generation.swift
import Foundation

/// Technology generation of a locomotive. Raw values are 1-based so that
/// "two generations older" is simple arithmetic on `rawValue`.
public enum Generation: Int, CaseIterable, Codable, Sendable, Comparable, CustomStringConvertible {
    case first = 1, second, third, fourth, fifth

    public static func < (lhs: Generation, rhs: Generation) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// The generation `count` steps older, or `nil` if it does not exist.
    public func older(by count: Int) -> Generation? {
        Generation(rawValue: rawValue - count)
    }

    public var description: String {
        switch self {
        case .first: return "1st"
        case .second: return "2nd"
        case .third: return "3rd"
        case .fourth: return "4th"
        case .fifth: return "5th"
        }
    }
}
