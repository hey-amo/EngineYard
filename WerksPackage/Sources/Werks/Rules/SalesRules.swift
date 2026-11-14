//
//  SalesRules.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

//  Phase 3 – Locomotive Production. Fully automatic.
//  Coordinates SalesOrder (dice), ProductionManager (spend / reset) and Bank (income).
//
//  Locomotives are resolved one at a time in board order. For each one,
//  selling rounds run in turn order (each player makes at most one sale per round) until nobody can sell any more. Because each locomotive's dice and  units are independent of every other locomotive's, this gives exactly the
//  same result as the rulebook's "each player sells all types, then the next player" ordering; only the order of log messages differs.
//

extension GameState {
    /// Resolves the whole Production phase, then moves to Pay Taxes.
    mutating func resolveProduction(events: inout [GameEvent]) {
        for locomotiveID in Catalogue.ids {
            resolveSales(of: locomotiveID, events: &events)
        }
        resetProduction(events: &events)
        enter(.taxes, events: &events)
    }

    /// "When all sales have been done, the players put their Production Unit
    /// counters back on their respective locomotive cards."
    mutating func resetProduction(events: inout [GameEvent]) {
        for index in players.indices {
            ProductionManager.resetAll(in: &players[index].hand)
        }
        events.append(.productionReset)
    }

    /// Selling rounds for one locomotive until no further sale is possible.
    mutating func resolveSales(of locomotiveID: Int, events: inout [GameEvent]) {
        let income = board[locomotiveID].definition.income
        var soldThisRound = true
        while soldThisRound {
            soldThisRound = false
            for playerID in turnOrder {
                guard let card = players[playerID].hand.card(locomotiveID) else { continue }
                var order = board[locomotiveID].salesOrder
                guard let sale = order.sell(card.production.units) else { continue }

                board[locomotiveID].update(from: order)
                // Cannot fail: `sell` never sells more than the units offered.
                try? ProductionManager.spendUnits(sale.unitsSold, on: locomotiveID, in: &players[playerID].hand)
                let receipt = bank.pay(sale.unitsSold * income, to: playerID,
                                       for: .sale(locomotiveID: locomotiveID, units: sale.unitsSold))
                events.append(.sold(playerID: playerID, locomotiveID: locomotiveID,
                                    units: sale.unitsSold, saleCase: sale.saleCase))
                events.append(.transaction(receipt))
                soldThisRound = true
            }
        }
    }
}
