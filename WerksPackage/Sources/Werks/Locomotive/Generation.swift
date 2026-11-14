//
//  Generation.swift
//  Werks
//
import Foundation

public enum Generation: Int, CaseIterable, Codable, Sendable, Hashable, Equatable, Comparable {
    case first = 1, second, third, fourth, fifth
    
    public static func < (lhs: Generation, rhs: Generation) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Generation {
    /// The generation `count` steps older, or `nil` if it does not exist.
    public func older(by count: Int) -> Generation? {
        Generation(rawValue: rawValue - count)
    }
}

/// Description
extension Generation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .first: return NSLocalizedString("1st", comment: "1st generation")
            case .second: return NSLocalizedString("2nd", comment: "2nd generation")
            case .third: return NSLocalizedString("3rd", comment: "3rd generation")
            case .fourth: return NSLocalizedString("4th", comment: "4th generation")
            case .fifth: return NSLocalizedString("5th", comment: "5th generation")
        }
    }
}
