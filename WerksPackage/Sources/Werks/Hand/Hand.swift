//
//  Hand.swift
//  Werks
//
//

import Foundation

//  The ONLY type that adds, modifies or removes locomotive cards.
//  Knows nothing about players, money or game state.
//

/// A portfolio of locomotive cards: at most one card per locomotive.
///
/// Also remembers every locomotive it has ever held, because a locomotive
/// may be developed only once, even if its card was later removed.
public struct Hand: Codable, Equatable, Sendable {
    /// Cards held, always sorted by board ID (oldest technology first).
    public private(set) var cards: [LocomotiveCard]
    /// Every locomotive ID ever added to this hand.
    public private(set) var history: Set<Int>

    public init(cards: [LocomotiveCard] = []) {
        self.cards = cards.sorted { $0.locomotiveID < $1.locomotiveID }
        self.history = Set(cards.map(\.locomotiveID))
    }

    // MARK: - Queries

    public var ids: [Int] { cards.map(\.locomotiveID) }
    public var isEmpty: Bool { cards.isEmpty }
    public func card(_ locomotiveID: Int) -> LocomotiveCard? { cards.first { $0.locomotiveID == locomotiveID } }
    public func contains(_ locomotiveID: Int) -> Bool { card(locomotiveID) != nil }
    /// `true` if this hand ever held the locomotive (now or in the past).
    public func hasHeld(_ locomotiveID: Int) -> Bool { history.contains(locomotiveID) }
    /// Total Production Units across all cards.
    public var totalUnits: Int { cards.reduce(0) { $0 + $1.production.total } }

    // MARK: - Mutations

    /// Adds a card. Fails if this locomotive was ever held before.
    public mutating func add(_ card: LocomotiveCard) throws {
        guard !hasHeld(card.locomotiveID) else { throw GameError.alreadyDeveloped(card.locomotiveID) }
        cards.append(card)
        cards.sort { $0.locomotiveID < $1.locomotiveID }
        history.insert(card.locomotiveID)
    }

    /// Removes a card from play. It stays in `history`.
    @discardableResult
    public mutating func remove(_ locomotiveID: Int) throws -> LocomotiveCard {
        guard let index = index(of: locomotiveID) else { throw GameError.locomotiveNotOwned(locomotiveID) }
        return cards.remove(at: index)
    }

    /// Edits one card in place. If `body` throws, the card is left unchanged.
    @discardableResult
    public mutating func modify<T>(_ locomotiveID: Int, _ body: (inout LocomotiveCard) throws -> T) throws -> T {
        guard let index = index(of: locomotiveID) else { throw GameError.locomotiveNotOwned(locomotiveID) }
        var card = cards[index]
        let result = try body(&card)
        precondition(card.locomotiveID == locomotiveID)
        cards[index] = card
        return result
    }

    private func index(of locomotiveID: Int) -> Int? {
        cards.firstIndex { $0.locomotiveID == locomotiveID }
    }
}
