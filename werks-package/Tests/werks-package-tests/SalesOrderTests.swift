//
//  SalesOrderTests.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

import XCTest
@testable import Werks

/*
/// The pure order-dice logic (port of the EngineYard SalesOrder).
final class SalesOrderTests: XCTestCase {
    func testQueriesMatchOriginalSalesOrderSemantics() {
        let order = SalesOrder(existing: [6, 4, 3])
        XCTAssertEqual(order.match(4), 1)
        XCTAssertNil(order.match(5))
        XCTAssertEqual(order.lower(5), 0)          // below the highest → highest die
        XCTAssertEqual(order.lower(1), 0)          // below even the lowest → still highest die
        XCTAssertNil(order.lower(6))
        XCTAssertEqual(order.higher(7), 0)
        XCTAssertNil(order.higher(6))
    }

    func testDecidePriority() {
        let order = SalesOrder(existing: [6, 4, 3])
        XCTAssertEqual(order.decide(3), .sameNumber(index: 2), "rulebook: must choose a) over b)")
        XCTAssertEqual(order.decide(5), .lowerNumber(index: 0))
        XCTAssertEqual(order.decide(9), .largerNumber(index: 0))
        XCTAssertNil(order.decide(0))
        XCTAssertNil(SalesOrder(existing: []).decide(2))
    }

    // Rulebook p.5: Susan has 3, dice 6-4-3 → sells 3, the "3" moves to the Customer Base.
    func testRulebookSameNumberExample() {
        var order = SalesOrder(existing: [6, 4, 3])
        XCTAssertEqual(order.sell(3), SaleResult(unitsSold: 3, saleCase: .sameNumber))
        XCTAssertEqual(order.existing, [6, 4])
        XCTAssertEqual(order.filled, [3])
    }

    // Rulebook p.6: Frank has 1, dice 4-6 → sells 1, the 6 becomes a 5.
    func testRulebookLowerNumberExample() {
        var order = SalesOrder(existing: [4, 6])
        XCTAssertEqual(order.sell(1), SaleResult(unitsSold: 1, saleCase: .lowerNumber))
        XCTAssertEqual(order.existing, [4, 5])
        XCTAssertTrue(order.filled.isEmpty)
    }

    // Rulebook p.6: Annika has 6, dice 4-5 → sells 5, the "5" moves; 1 unsold.
    func testRulebookLargerNumberExample() {
        var order = SalesOrder(existing: [4, 5])
        XCTAssertEqual(order.sell(6), SaleResult(unitsSold: 5, saleCase: .largerNumber))
        XCTAssertEqual(order.existing, [4])
        XCTAssertEqual(order.filled, [5])
    }

    func testSameNumberOnHighestDie() {
        var order = SalesOrder(existing: [4, 2])
        XCTAssertEqual(order.sell(4)?.saleCase, .sameNumber)
        XCTAssertEqual(order.existing, [2])
    }

    func testTiedHighestDiceUseFirst() {
        var order = SalesOrder(existing: [3, 3])
        order.sell(1)
        XCTAssertEqual(order.existing, [2, 3])
    }
}

/// The full automatic Production phase.
final class ProductionPhaseTests: XCTestCase {
    private func productionState(players: Int = 3) -> GameState {
        Fixture.blank(players: players, phase: .production)
    }

    func testSingleSalePaysThroughBankAndMovesToTaxes() throws {
        var state = productionState()
        state.give(0, 1, units: 2)
        state.setOrders(1, existing: [2])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(result.state.coins(of: 0), 102)
        XCTAssertEqual(result.state.board[1].filledOrders, [2])
        XCTAssertEqual(result.state.phase, .taxes)
        XCTAssertEqual(receipts(in: result.events),
                       [BankTransaction(playerID: 0, amount: 2, reason: .sale(locomotiveID: 1, units: 2), balanceAfter: 102)])
    }

    func testPlayersSellInTurnOrderWithinARound() throws {
        var state = productionState()
        state.give(0, 2, units: 5)
        state.give(1, 2, units: 2)
        state.setOrders(2, existing: [3, 2])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(sales(in: result.events), [
            .sold(playerID: 0, locomotiveID: 2, units: 3, saleCase: .largerNumber),
            .sold(playerID: 1, locomotiveID: 2, units: 2, saleCase: .sameNumber)
        ])
        XCTAssertEqual(result.state.coins(of: 0), 106)
        XCTAssertEqual(result.state.coins(of: 1), 104)
    }

    func testTurnOrderDecidesWhoGetsScarceDemand() throws {
        var state = productionState()
        state.turnOrder = [1, 0, 2]
        state.give(0, 1, units: 3)
        state.give(1, 1, units: 3)
        state.setOrders(1, existing: [3])
        state = try apply(.resolvePhase, to: state)
        XCTAssertEqual(state.coins(of: 1), 103)
        XCTAssertEqual(state.coins(of: 0), 100)
    }

    func testLeftoverUnitsSellInLaterRounds() throws {
        var state = productionState()
        state.give(0, 1, units: 5)
        state.setOrders(1, existing: [2, 2])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(sales(in: result.events).count, 2)
        XCTAssertEqual(result.state.coins(of: 0), 104)
    }

    func testMultiPlayerScenario() throws {
        // Dice [4, 1]. P0(3) lower → [1,1]; P1(1) same → [1]; P2(2) larger(1) → [].
        var state = productionState()
        state.give(0, 1, units: 3)
        state.give(1, 1, units: 1)
        state.give(2, 1, units: 2)
        state.setOrders(1, existing: [4, 1])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(sales(in: result.events), [
            .sold(playerID: 0, locomotiveID: 1, units: 3, saleCase: .lowerNumber),
            .sold(playerID: 1, locomotiveID: 1, units: 1, saleCase: .sameNumber),
            .sold(playerID: 2, locomotiveID: 1, units: 1, saleCase: .largerNumber)
        ])
        XCTAssertEqual(result.state.board[1].filledOrders, [1, 1])
    }

    func testSecondRoundContinuesUntilDemandExhausted() throws {
        // Dice [6, 1]. R1: P0(4) lower → [2,1]; P1(4) larger(2) → [1]. R2: P1(2) larger(1) → [].
        var state = productionState(players: 2)
        state.give(0, 1, units: 4)
        state.give(1, 1, units: 4)
        state.setOrders(1, existing: [6, 1])
        state = try apply(.resolvePhase, to: state)
        XCTAssertEqual(state.coins(of: 0), 104)
        XCTAssertEqual(state.coins(of: 1), 103)
        XCTAssertTrue(state.board[1].existingOrders.isEmpty)
    }

    func testLocomotivesResolveInBoardOrder() throws {
        var state = productionState()
        state.turnOrder = [2, 1, 0]
        state.give(0, 1)
        state.give(2, 2)
        state.setOrders(1, existing: [1])
        state.setOrders(2, existing: [1])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        let ids = result.events.compactMap { event -> Int? in
            if case let .sold(_, id, _, _) = event { return id } else { return nil }
        }
        XCTAssertEqual(ids, [1, 2])
    }

    func testNoDemandMeansNoSale() throws {
        var state = productionState()
        state.give(0, 1, units: 3)
        state.setOrders(1, filled: [3])
        state.give(1, 2, units: 3)
        state.board[2].makeObsolete()
        state = try apply(.resolvePhase, to: state)
        XCTAssertEqual(state.bank.balances, [100, 100, 100])
    }

    func testRustingLocomotiveWithDiceStillSells() throws {
        var state = productionState()
        state.give(0, 1)
        state.setOrders(1, existing: [1])
        state.board[1].rust = .rusting
        state.board[1].availableCardCount = 0
        state = try apply(.resolvePhase, to: state)
        XCTAssertEqual(state.coins(of: 0), 101)
    }

    /// The reset: spent units return to the card at the end of the phase.
    func testSpentUnitsAreResetAtEndOfPhase() throws {
        var state = productionState()
        state.give(0, 1, units: 3)
        state.setOrders(1, existing: [2])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(result.state.players[0].hand.card(1)?.production, ProductionUnits(units: 3, spentUnits: 0))
        XCTAssertTrue(result.events.contains(.productionReset))
    }
}
*/
