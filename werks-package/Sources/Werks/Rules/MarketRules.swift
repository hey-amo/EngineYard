//
//  MarketRules.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

///
///  Phase 5 – Market Demands. Processes each livery (green, red, yellow, blue).
///  Generations are identified by `Generation` and dice, never by `Rust`.
///

extension GameState {
    /// Resolves Market Demands for every livery and starts the next round.
    mutating func resolveMarketDemand(events: inout [GameEvent]) {
        for livery in Livery.allCases {
            resolveMarket(for: livery, events: &events)
        }
        round += 1
        enter(.development, events: &events)
    }

    /// Applies the 0 / 1 / 2 / 3-generation cases to one livery.
    ///
    /// A generation exists when it has Existing or Filled orders (an
    /// initial die alone does not count). Should more than three exist,
    /// every generation older than the newest two is made obsolete.
    mutating func resolveMarket(for livery: Livery, events: inout [GameEvent]) {
        let existing = board.spaces(of: livery)
            .filter { $0.rust != .obsolete && $0.isInMarket }
            .map(\.id)
        guard let newest = existing.last else { return }   // a) none

        switch existing.count {
        case 1:                                             // b)
            break
        case 2:                                             // c)
            ageOlderGeneration(existing[0], events: &events)
        default:                                            // d)
            for id in existing.dropLast(2) {
                board[id].makeObsolete()
                events.append(.obsolete(locomotiveID: id))
            }
            topUpMiddleGeneration(existing[existing.count - 2], events: &events)
        }
        growNewestGeneration(newest, events: &events)
    }

    /// Newest generation: add one customer die if below max, then roll the Customer Base.
    mutating func growNewestGeneration(_ id: Int, events: inout [GameEvent]) {
        if board[id].diceCount < board[id].definition.maxDice {
            board[id].filledOrders.append(1)
            events.append(.customerDiceAdded(locomotiveID: id, count: 1))
        }
        rollCustomerBase(id, events: &events)
    }

    /// Older of two generations: return one Customer Base die (or, if the
    /// Customer Base is empty, the lowest Existing Orders die — rulebook p.7
    /// note), roll the rest, flag rusting.
    mutating func ageOlderGeneration(_ id: Int, events: inout [GameEvent]) {
        if let die = board[id].returnOneDie() {
            events.append(.dieReturned(locomotiveID: id, die: die))
        }
        rollCustomerBase(id, events: &events)
        if board[id].rust != .rusting {
            board[id].rust = .rusting
            events.append(.rusting(locomotiveID: id))
        }
    }

    /// Middle of three generations: fill the Customer Base up to max dice, then roll.
    mutating func topUpMiddleGeneration(_ id: Int, events: inout [GameEvent]) {
        let missing = board[id].definition.maxDice - board[id].diceCount
        if missing > 0 {
            board[id].filledOrders.append(contentsOf: Array(repeating: 1, count: missing))
            events.append(.customerDiceAdded(locomotiveID: id, count: missing))
        }
        rollCustomerBase(id, events: &events)
    }

    private mutating func rollCustomerBase(_ id: Int, events: inout [GameEvent]) {
        guard !board[id].filledOrders.isEmpty else { return }
        var space = board[id]
        let rolled = space.rollFilledIntoExisting(using: &rng)
        board[id] = space
        events.append(.ordersRolled(locomotiveID: id, dice: rolled))
    }
}
