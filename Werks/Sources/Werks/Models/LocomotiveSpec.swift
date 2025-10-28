//
//  LocomotiveSpec
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

// MARK: Locomotive Color

public enum Livery: Int, CaseIterable, Equatable, Sendable, Codable {
    case green = 1, red, yellow, blue
}

extension Livery: CustomStringConvertible {
    public var description: String {
        switch self {
        case .green: return "Green"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        }
    }
}

// MARK: Locomotive Generation

public enum Generation: Int, CaseIterable, Codable, Sendable {
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

// Immutable prototype loaded from CSV
public struct LocomotiveSpec: Codable {
    public let id: Int                 // matches CSV ID
    public let name: String
    public let colour: Livery
    public let generation: Generation
    public let cost: Int
    public let trainPool: Int
    public let maxDice: Int

    public var productionCost: Int {
        get {
            return Int(round(Double(self.cost) / 2))
        }
    }

    public var income: Int {
      get {
          return Int(round(Double(self.productionCost) / 2))
      }
    }

    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<LocomotiveSpec.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.colour = try container.decode(Livery.self, forKey: .colour)
        self.generation = try container.decode(Generation.self, forKey: .generation)
        self.cost = try container.decode(Int.self, forKey: .cost)
        self.trainPool = try container.decode(Int.self, forKey: .trainPool)
        self.maxDice = try container.decode(Int.self, forKey: .maxDice)
    }
}


