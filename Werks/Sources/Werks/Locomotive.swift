//
//  Locomotive.swift
//  Werks
//
//  Created by Amarjit on 19/05/2026.
//

import Foundation

public struct Locomotive: Hashable, Equatable, Codable {
    public let id: UUID
    public let generation: Generation
    public let colour: LocomotiveColor
    public let cost: Int
    public var productionCost: Int {
        return Int(cost / 2)
    }
    public var income: Int {
        return Int(productionCost / 2)
    }
    public let trainPool: Int
    
    static public func == (lhs: Locomotive, rhs:Locomotive) -> Bool {
        return (lhs.id == rhs.id)
    }
}


// --------------------------------
// MARK: Locomotive Generation
// --------------------------------

public enum Generation: Int, CaseIterable, Codable {
    case first = 1, second, third, fourth, fifth
}

extension Generation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .first: return "First"
        case .second: return "Second"
        case .third: return "Third"
        case .fourth: return "Fourth"
        case .fifth: return "Fifth"
        }
    }
}


extension Generation: Equatable {
    static func > (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue > rhs.rawValue)
    }
    static func < (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue < rhs.rawValue)
    }
    public static func == (lhs: Generation, rhs: Generation) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}


// --------------------------------
// MARK: Locomotive Colour (Livery)
// --------------------------------
public enum LocomotiveColor: Int, CaseIterable, Equatable, Codable, Sendable {
    case green = 1, red, yellow, blue
}

extension LocomotiveColor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .green: return "Green"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        }
    }
}

