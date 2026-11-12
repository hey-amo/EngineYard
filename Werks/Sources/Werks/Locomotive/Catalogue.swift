//
//  Catalogue.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

/// The 14 board spaces in their fixed, linear board order.
/// The sequence is never shuffled; "next locomotive" means `id + 1`.
public enum Catalogue {
    public static let all: [LocomotiveDefinition] = [
        .init(id: 1, name: "Green.1st", livery: .green, generation: .first, cost: 4, maxDice: 3, cardCount: 4),
        .init(id: 2, name: "Red.1st", livery: .red, generation: .first, cost: 8, maxDice: 3, cardCount: 3),
        .init(id: 3, name: "Yellow.1st", livery: .yellow, generation: .first, cost: 12, maxDice: 2, cardCount: 2),
        .init(id: 4, name: "Blue.1st", livery: .blue, generation: .first, cost: 16, maxDice: 1, cardCount: 1),
        .init(id: 5, name: "Green.2nd", livery: .green, generation: .second, cost: 20, maxDice: 4, cardCount: 4),
        .init(id: 6, name: "Red.2nd", livery: .red, generation: .second, cost: 24, maxDice: 3, cardCount: 3),
        .init(id: 7, name: "Yellow.2nd", livery: .yellow, generation: .second, cost: 28, maxDice: 3, cardCount: 2),
        .init(id: 8, name: "Green.3rd", livery: .green, generation: .third, cost: 32, maxDice: 4, cardCount: 4),
        .init(id: 9, name: "Blue.2nd", livery: .blue, generation: .second, cost: 36, maxDice: 2, cardCount: 2),
        .init(id: 10, name: "Red.3rd", livery: .red, generation: .third, cost: 40, maxDice: 4, cardCount: 3),
        .init(id: 11, name: "Green.4th", livery: .green, generation: .fourth, cost: 44, maxDice: 5, cardCount: 4),
        .init(id: 12, name: "Yellow.3rd", livery: .yellow, generation: .third, cost: 48, maxDice: 3, cardCount: 3),
        .init(id: 13, name: "Red.4th", livery: .red, generation: .fourth, cost: 52, maxDice: 4, cardCount: 4),
        .init(id: 14, name: "Green.5th", livery: .green, generation: .fifth, cost: 56, maxDice: 5, cardCount: 4)
    ]

    /// Valid board IDs.
    public static var ids: ClosedRange<Int> { 1...all.count }

    /// Definition for a board ID, or `nil` if out of range.
    public static func definition(for id: Int) -> LocomotiveDefinition? {
        ids.contains(id) ? all[id - 1] : nil
    }

    /// The next space on the board, or `nil` after space 14.
    public static func nextID(after id: Int) -> Int? {
        ids.contains(id + 1) ? id + 1 : nil
    }

    /// The space of a given livery and generation, if printed on the board.
    public static func definition(livery: Livery, generation: Generation) -> LocomotiveDefinition? {
        all.first { $0.livery == livery && $0.generation == generation }
    }
}
