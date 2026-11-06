//
//  Locomotive.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

public enum Rust: Int, CaseIterable, Codable, Sendable {
    case unavailable, active, rusting, obsolete
}

public enum LocomotiveLivery: Int, CaseIterable, Codable, Sendable {
    case green, red, yellow, blue
}

public enum LocomotiveGeneration: Int, CaseIterable, Codable, Sendable {
    case first, second, third, fourth, fifth
}

public struct LocomotiveDefinition: Codable, Identifiable, Hashable, Sendable {
    public let id: UInt
    public let name: String
    public let colour: LocomotiveLivery
    public let generation: LocomotiveGeneration
    public let cost: Int
    public let dicePool: Int
    public let totalCardCount: Int

    public var productionCost: Int { cost.roundedUpHalf() }
    public var income: Int { productionCost.roundedUpHalf() }

    public static func buildAll() -> [LocomotiveDefinition] {
        [
            .init(id: 1, name: "Green.1st", colour: .green, generation: .first, cost: 4, dicePool: 3, totalCardCount: 4),
            .init(id: 2, name: "Red.1st", colour: .red, generation: .first, cost: 8, dicePool: 3, totalCardCount: 3),
            .init(id: 3, name: "Yellow.1st", colour: .yellow, generation: .first, cost: 12, dicePool: 2, totalCardCount: 2),
            .init(id: 4, name: "Blue.1st", colour: .blue, generation: .first, cost: 16, dicePool: 1, totalCardCount: 1),
            .init(id: 5, name: "Green.2nd", colour: .green, generation: .second, cost: 20, dicePool: 4, totalCardCount: 4),
            .init(id: 6, name: "Red.2nd", colour: .red, generation: .second, cost: 24, dicePool: 3, totalCardCount: 3),
            .init(id: 7, name: "Yellow.2nd", colour: .yellow, generation: .second, cost: 28, dicePool: 3, totalCardCount: 2),
            .init(id: 8, name: "Green.3rd", colour: .green, generation: .third, cost: 32, dicePool: 4, totalCardCount: 4),
            .init(id: 9, name: "Blue.2nd", colour: .blue, generation: .second, cost: 36, dicePool: 2, totalCardCount: 2),
            .init(id: 10, name: "Red.3rd", colour: .red, generation: .third, cost: 40, dicePool: 4, totalCardCount: 3),
            .init(id: 11, name: "Green.4th", colour: .green, generation: .fourth, cost: 44, dicePool: 5, totalCardCount: 4),
            .init(id: 12, name: "Yellow.3rd", colour: .yellow, generation: .third, cost: 48, dicePool: 3, totalCardCount: 3),
            .init(id: 13, name: "Red.4th", colour: .red, generation: .fourth, cost: 52, dicePool: 4, totalCardCount: 4),
            .init(id: 14, name: "Green.5th", colour: .green, generation: .fifth, cost: 56, dicePool: 5, totalCardCount: 4)
        ]
    }
}

public struct LocomotiveState: Codable, Equatable, Sendable {
    public private(set) var availableCardCount: Int
    public private(set) var initialOrder: Int?
    public private(set) var existingOrders: [Int]
    public private(set) var filledOrders: [Int]
    public private(set) var rust: Rust

    init(cardCount: Int) {
        self.availableCardCount = cardCount
        self.initialOrder = nil
        self.existingOrders = []
        self.filledOrders = []
        self.rust = .unavailable
    }

    var orderCount: Int {
        existingOrders.count + filledOrders.count
    }

    mutating func setInitialOrder(_ value: Int) {
        initialOrder = value
        activateIfUnavailable()
    }

    mutating func addExistingOrder(_ value: Int) {
        existingOrders.append(value)
        activateIfUnavailable()
    }

    mutating func addFilledOrder(_ value: Int) {
        filledOrders.append(value)
        activateIfUnavailable()
    }

    mutating func developCard(dicePool: Int) throws {
        guard rust != .obsolete else {
            throw GameBoardError.spaceUnavailable
        }
        guard initialOrder != nil || !existingOrders.isEmpty else {
            throw GameBoardError.noMarketDemand
        }
        guard rust != .unavailable else {
            throw GameBoardError.spaceUnavailable
        }
        guard availableCardCount > 0 else {
            throw GameBoardError.noCardsAvailable
        }
        if let order = initialOrder {
            guard orderCount < dicePool else {
                throw GameBoardError.orderCapacityExceeded
            }
            existingOrders.append(order)
            initialOrder = nil
        }
        availableCardCount -= 1
    }

    mutating func markObsolete() {
        availableCardCount = 0
        initialOrder = nil
        existingOrders.removeAll()
        filledOrders.removeAll()
        rust = .obsolete
    }

    mutating func markRusting() {
        rust = .rusting
    }

    private mutating func activateIfUnavailable() {
        if rust == .unavailable {
            rust = .active
        }
    }
}

public struct BoardSpace: Codable, Identifiable, Equatable, Sendable {
    public let definition: LocomotiveDefinition
    public private(set) var state: LocomotiveState

    public var id: UInt { definition.id }

    init(definition: LocomotiveDefinition) {
        self.definition = definition
        self.state = LocomotiveState(cardCount: definition.totalCardCount)
    }

    mutating func setInitialOrder(_ value: Int) {
        state.setInitialOrder(value)
    }

    mutating func addExistingOrder(_ value: Int) {
        state.addExistingOrder(value)
    }

    mutating func addFilledOrder(_ value: Int) {
        state.addFilledOrder(value)
    }

    mutating func developCard() throws {
        try state.developCard(dicePool: definition.dicePool)
    }

    mutating func markRusting() {
        state.markRusting()
    }

    mutating func markObsolete() {
        state.markObsolete()
    }
}

public enum GameBoardError: Error, Equatable, Sendable {
    case spaceNotFound
    case invalidDieValue
    case initialOrderAlreadySet
    case orderCapacityExceeded
    case noCardsAvailable
    case noMarketDemand
    case spaceUnavailable
}
