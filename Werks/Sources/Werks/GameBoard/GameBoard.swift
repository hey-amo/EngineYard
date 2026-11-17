//
//  Board.swift
//  Werks
//
//

import Foundation

/// The 14 board spaces' mutable state, in fixed board order.
public struct GameBoard: Codable, Equatable, Sendable {
    /// Index `i` holds board ID `i + 1`.
    public internal(set) var spaces: [LocomotiveState]

    /// A fresh board with every space unavailable.
    public init() {
        spaces = Catalogue.all.map(LocomotiveState.init(definition:))
    }

    /// Access a space by board ID (1...14). Traps on an invalid ID;
    /// validate with `Catalogue.definition(for:)` first.
    public internal(set) subscript(id: Int) -> LocomotiveState {
        get { spaces[id - 1] }
        set { spaces[id - 1] = newValue }
    }

    /// All spaces of a livery, oldest generation first.
    public func spaces(of livery: Livery) -> [LocomotiveState] {
        spaces
            .filter { $0.definition.livery == livery }
            .sorted { $0.definition.generation < $1.definition.generation }
    }
}
