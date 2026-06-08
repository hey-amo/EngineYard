//
//  Locomotive.swift
//  Werks
//
//  Created by Amarjit on 19/05/2026.
//

import Foundation

public struct Locomotive: Hashable, Equatable, Codable {
    public let id: Int
    public let name: String
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
    public let dicePool: Int
    
    // Equatable conformance
    public static func == (lhs: Locomotive, rhs:Locomotive) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Locomotive {
    // FIX THIS: This should be for a specific generation and colour
    public var avatar: String {
        switch self.colour {
        case .green: return "train-green.png"
        case .yellow: return "train-yellow.png"
        case .red: return "train-red.png"
        case .blue: return "train-blue.png"
        }
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

// MARK: Build Trains

extension Locomotive {
    /// Build 14 trains
    public static func buildTrains() -> [Locomotive] {
        let locos: [Locomotive] = [
            Locomotive(id: 1, name: "General I", generation: .first, colour: .green, cost: 4, trainPool: 4, dicePool: 3),
            Locomotive(id: 2, name: "Fast Freight I", generation: .first, colour: .red, cost: 8, trainPool: 3, dicePool: 3),
            Locomotive(id: 3, name: "Heavy I", generation: .first, colour: .yellow, cost: 12, trainPool: 2, dicePool: 2),
            Locomotive(id: 4, name: "Special I", generation: .first, colour: .blue, cost: 16, trainPool: 1, dicePool: 2),
            Locomotive(id: 5, name: "General II", generation: .second, colour: .green, cost: 20, trainPool: 4, dicePool: 4),
            Locomotive(id: 6, name: "Fast Freight II", generation: .second, colour: .red, cost: 24, trainPool: 3, dicePool: 3),
            Locomotive(id: 7, name: "Heavy II", generation: .second, colour: .yellow, cost: 28, trainPool: 2, dicePool: 3),
            Locomotive(id: 8, name: "General III", generation: .third, colour: .green, cost: 32, trainPool: 4, dicePool: 4),
            Locomotive(id: 9, name: "Special II", generation: .second, colour: .blue, cost: 36, trainPool: 2, dicePool: 2),
            Locomotive(id: 10, name: "Fast Freight III", generation: .third, colour: .red, cost: 40, trainPool: 3, dicePool: 4),
            Locomotive(id: 11, name: "General IV", generation: .fourth, colour: .green, cost: 44, trainPool: 4, dicePool: 4),
            Locomotive(id: 12, name: "Heavy III", generation: .third, colour: .yellow, cost: 48, trainPool: 3, dicePool: 3),
            Locomotive(id: 13, name: "Fast Freight IV", generation: .fourth, colour: .red, cost: 52, trainPool: 4, dicePool: 4),
            Locomotive(id: 14, name: "General V", generation: .fifth, colour: .green, cost: 56, trainPool: 4, dicePool: 5),
        ]
        
        return locos
    }
}


/*
 # 🚂 Trains

 | **ID** | **Name** | **Colour** | **Cost** | **Colour Int** | **Generation** | **Pool** | **Dice** |
 |:------:|:----------------------------|:-----------|:--------:|:----------------:|:-------:|:--------:|:--------:|
 | 1  | General I (4-2-1)          | Green  | 4  | 1 | 1 | 4 | 3 |
 | 2  | Fast Freight I (8-4-2)     | Red    | 8  | 2 | 1 | 3 | 3 |
 | 3  | Heavy I (12-6-3)           | Yellow | 12 | 3 | 1 | 2 | 2 |
 | 4  | Special I (16-8-4)         | Blue   | 16 | 4 | 1 | 1 | 2 |
 | 5  | General II (20-10-5)       | Green  | 20 | 1 | 2 | 4 | 4 |
 | 6  | Fast Freight II (24-12-6)  | Red    | 24 | 2 | 2 | 3 | 3 |
 | 7  | Heavy II (28-14-7)         | Yellow | 28 | 3 | 2 | 2 | 3 |
 | 8  | General III (32-16-8)      | Green  | 32 | 1 | 3 | 4 | 4 |
 | 9  | Special II (36-18-9)       | Blue   | 36 | 4 | 2 | 2 | 2 |
 | 10 | Fast Freight III (40-20-10)| Red    | 40 | 2 | 3 | 3 | 4 |
 | 11 | General IV (44-22-11)      | Green  | 44 | 1 | 4 | 4 | 4 |
 | 12 | Heavy III (48-24-12)       | Yellow | 48 | 3 | 3 | 3 | 3 |
 | 13 | Fast Freight IV (52-26-13) | Red    | 52 | 2 | 4 | 4 | 4 |
 | 14 | General V (56-28-14)       | Green  | 56 | 1 | 5 | 4 | 5 |
 ------------------------------------
 */
