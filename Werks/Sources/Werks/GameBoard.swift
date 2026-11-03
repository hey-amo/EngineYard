//
//  GameBoard.swift
//  Werks
//

public struct GameBoard: Sendable {
    public private(set) var spaces: [BoardSpace]

    public init() {
        spaces = LocomotiveDefinition.buildAll().map(BoardSpace.init(definition:))
    }

    public mutating func setInitialOrder(_ value: Int, for locomotiveID: UInt) throws {
        let index = try index(for: locomotiveID)
        guard (1...6).contains(value) else {
            throw GameBoardError.invalidDieValue
        }
        guard spaces[index].state.rust != .obsolete else {
            throw GameBoardError.spaceUnavailable
        }
        guard spaces[index].state.initialOrder == nil else {
            throw GameBoardError.initialOrderAlreadySet
        }

        spaces[index].setInitialOrder(value)
    }

    public mutating func addExistingOrder(_ value: Int, for locomotiveID: UInt) throws {
        let index = try index(for: locomotiveID)
        try validateOrder(value, at: index)
        guard spaces[index].state.rust != .obsolete else {
            throw GameBoardError.spaceUnavailable
        }

        spaces[index].addExistingOrder(value)
    }

    public mutating func addFilledOrder(_ value: Int, for locomotiveID: UInt) throws {
        let index = try index(for: locomotiveID)
        try validateOrder(value, at: index)
        guard spaces[index].state.rust != .obsolete else {
            throw GameBoardError.spaceUnavailable
        }

        spaces[index].addFilledOrder(value)
    }

    public mutating func developLocomotive(_ locomotiveID: UInt) throws -> LocomotiveDefinition {
        let index = try index(for: locomotiveID)
        var space = spaces[index]
        try space.developCard()
        spaces[index] = space
        return space.definition
    }

    public mutating func markRusting(_ locomotiveID: UInt) throws {
        let index = try index(for: locomotiveID)
        guard spaces[index].state.rust == .active else {
            throw GameBoardError.spaceUnavailable
        }
        spaces[index].markRusting()
    }

    public mutating func markObsolete(_ locomotiveID: UInt) throws {
        let index = try index(for: locomotiveID)
        spaces[index].markObsolete()
    }

    private func index(for locomotiveID: UInt) throws -> Int {
        guard let index = spaces.firstIndex(where: { $0.id == locomotiveID }) else {
            throw GameBoardError.spaceNotFound
        }
        return index
    }

    private func validateOrder(_ value: Int, at index: Int) throws {
        guard (1...6).contains(value) else {
            throw GameBoardError.invalidDieValue
        }
        guard spaces[index].state.orderCount < spaces[index].definition.dicePool else {
            throw GameBoardError.orderCapacityExceeded
        }
    }
}
