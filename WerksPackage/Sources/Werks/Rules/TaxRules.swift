//
//  TaxRules.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

//
//  Phase 4 – Pay Taxes, end-of-game check, new player order.
//

extension GameState {
    /// Each player pays `rules.taxPercent`% (rounded down) in turn order. If
    /// anyone then has at least `rules.winningCoins` the game ends;
    /// otherwise turn order is recomputed.
    mutating func resolveTaxes(events: inout [GameEvent]) {
        for playerID in turnOrder {
            events.append(.transaction(bank.collectTax(from: playerID, percent: rules.taxPercent)))
        }

        let balances = bank.balances
        if balances.contains(where: { $0 >= rules.winningCoins }) {
            let best = balances.max() ?? 0
            winners = players.indices.filter { balances[$0] == best }
            phase = .gameOver
            events.append(.gameEnded(winners: winners))
            return
        }

        turnOrder = Self.turnOrder(after: turnOrder, coins: balances)
        events.append(.turnOrderChanged(turnOrder))
        enter(.marketDemand, events: &events)
    }

    /// Least cash goes first; ties keep their previous relative order (stable).
    static func turnOrder(after current: [Int], coins: [Int]) -> [Int] {
        current.enumerated()
            .sorted { lhs, rhs in
                let (l, r) = (coins[lhs.element], coins[rhs.element])
                return l != r ? l < r : lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
