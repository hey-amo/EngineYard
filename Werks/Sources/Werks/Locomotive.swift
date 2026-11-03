//
//  Locomotive.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

public enum Rust: Int, CaseIterable, Codable, Sendable {
    case inactive, active, rusting, rusted
}

public enum LocomotiveLivery: Int, CaseIterable, Codable, Sendable {
    case green, red, yellow, blue
}

public enum LocomotiveGeneration: Int, CaseIterable, Codable, Sendable {
    case first, second, third, fourth, fifth
}

public struct Locomotive: Codable, Identifiable, Hashable, Equatable, Sendable {
    public let id: UInt
    public let name: String
    public let colour: LocomotiveLivery
    public let generation: LocomotiveGeneration
    public let cost: Int // cost to build this locomotive. min: 0
    public var productionCost: Int { // productionCost is always half of cost
        get { return cost.roundedUpHalf() }
    }
    public var income: Int { // income is always half of productionCost
        get { return self.productionCost.roundedUpHalf() }
    }
    public let dicePool: Int // how many dice this locomotive gets. min:0
    public let trainPool: Int // how many cards does this locomotive has. min:0 - modified during game
    public let initialOrders: Int? // defaults to -1 meaning there isn't any  - modified during game
    public let existingOrders: [Int] // array has a max capacity: dicePool  - modified during game
    public let filledOrders: [Int] // array has a max capacity: dicePool  - modified during game
    public let rust: Rust // defaults to `inactive` state  - modified during game

    public var maxDice: UInt { // the dice in existing and filled, defaults to 0
        get {
            let existing = UInt(existingOrders.count)
            let filled = UInt(filledOrders.count)
            let (total, overflow) = existing.addingReportingOverflow(filled)
            return overflow ? .max : total
        }
    }
}

extension Locomotive: CustomStringConvertible {
    public var description: String {
        return "🚂 Locomotive ID: " // display the entire locomotive data nicely in logs
    }
}

extension Locomotive {
    // a list of 14 locomotives in the game hardcoded. it does not generate cards
    public static func buildAll() -> [Locomotive] {
        
        /*
        # 🚂 Train Manifest
        
         | **ID** | **Name** | **Colour** | **Cost** | **Colour Code** | **Generation** | **TrainPool** | **Dice** |
        |:------:|:----------------------------|:-----------|:--------:|:----------------:|:-------:|:--------:|:--------:|
        | 1  | General I (4-2-1)          | Green  | 4  | 1 | 1 | 4 | 3 | green.1st
        | 2  | Fast Freight I (8-4-2)     | Red    | 8  | 2 | 1 | 3 | 3 | red.1st
        | 3  | Heavy I (12-6-3)           | Yellow | 12 | 3 | 1 | 2 | 2 | yellow.1st
        | 4  | Special I (16-8-4)         | Blue   | 16 | 4 | 1 | 1 | 2 | blue.1st
        | 5  | General II (20-10-5)       | Green  | 20 | 1 | 2 | 4 | 4 | green.2nd
        | 6  | Fast Freight II (24-12-6)  | Red    | 24 | 2 | 2 | 3 | 3 | red.2nd
        | 7  | Heavy II (28-14-7)         | Yellow | 28 | 3 | 2 | 2 | 3 | yellow.2nd
        | 8  | General III (32-16-8)      | Green  | 32 | 1 | 3 | 4 | 4 | green.3rd
        | 9  | Special II (36-18-9)       | Blue   | 36 | 4 | 2 | 2 | 2 | blue.2nd
        | 10 | Fast Freight III (40-20-10)| Red    | 40 | 2 | 3 | 3 | 4 | red.3rd
        | 11 | General IV (44-22-11)      | Green  | 44 | 1 | 4 | 4 | 4 | green.4th
        | 12 | Heavy III (48-24-12)       | Yellow | 48 | 3 | 3 | 3 | 3 | yellow.3rd
        | 13 | Fast Freight IV (52-26-13) | Red    | 52 | 2 | 4 | 4 | 4 | red.4th
        | 14 | General V (56-28-14)       | Green  | 56 | 1 | 5 | 4 | 5 | green.5th
        */
        
        return [
            Locomotive.init(id: 1, name: "Green.1st", colour: .green, generation: .first, cost: 4, dicePool: 3, trainPool: 4, initialOrders: -1, existingOrders: [Int](), filledOrders: [Int](), rust: .inactive)
        ]
    }
}
