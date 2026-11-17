//
//  TaxTests.swift
//  WerksPackage
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

final class TaxTests: XCTestCase {
    private func taxState(coins: [Int], order: [Int]? = nil, rules: GameRules = .standard) -> GameState {
        var state = Fixture.blank(players: coins.count, phase: .taxes, rules: rules)
        state.bank = Bank(balances: coins)
        if let order { state.turnOrder = order }
        return state
    }

    func testTenPercentRoundedDownThroughBank() throws {
        let result = try GameEngine.apply(.resolvePhase, to: taxState(coins: [109, 50, 9]))
        XCTAssertEqual(result.state.bank.balances, [99, 45, 9])
        XCTAssertEqual(result.state.phase, .marketDemand)
        XCTAssertEqual(receipts(in: result.events).map(\.amount), [-10, -5, 0])
        XCTAssertTrue(receipts(in: result.events).allSatisfy { $0.reason == .tax })
    }

    func testTaxesPaidInTurnOrder() throws {
        let result = try GameEngine.apply(.resolvePhase, to: taxState(coins: [10, 20, 30], order: [2, 0, 1]))
        XCTAssertEqual(receipts(in: result.events).map(\.playerID), [2, 0, 1])
    }

    func testNewTurnOrderLeastCashFirst() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [109, 50, 9]))
        XCTAssertEqual(state.turnOrder, [2, 1, 0])
    }

    func testTiesKeepRelativeOrder() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [50, 50, 50, 10], order: [2, 0, 3, 1]))
        XCTAssertEqual(state.turnOrder, [3, 2, 0, 1])
    }

    // Rulebook p.6/p.8: 300 Talers or more AFTER paying taxes.
    func testGameEndsAtExactly300AfterTax() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [333, 10, 10]))   // 333 - 33 = 300
        XCTAssertEqual(state.coins(of: 0), 300)
        XCTAssertEqual(state.phase, .gameOver)
        XCTAssertEqual(state.winners, [0])
    }

    func testGameContinuesAt299AfterTax() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [332, 10, 10]))   // 332 - 33 = 299
        XCTAssertEqual(state.coins(of: 0), 299)
        XCTAssertEqual(state.phase, .marketDemand)
    }

    func testWinningThresholdIsConfigurable() throws {
        let rules = GameRules(winningCoins: 330)
        let state = try apply(.resolvePhase, to: taxState(coins: [366, 10, 10], rules: rules))  // 330
        XCTAssertEqual(state.phase, .gameOver)
        let notYet = try apply(.resolvePhase, to: taxState(coins: [365, 10, 10], rules: rules)) // 329
        XCTAssertEqual(notYet.phase, .marketDemand)
    }

    func testTiedWinnersShareVictory() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [400, 400, 10]))
        XCTAssertEqual(state.winners, [0, 1])
    }

    func testRichestWinsEvenIfAnotherTriggeredTheEnd() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [340, 400, 10]))
        XCTAssertEqual(state.winners, [1])
    }

    func testNoActionsAfterGameOver() throws {
        let state = try apply(.resolvePhase, to: taxState(coins: [400, 10, 10]))
        XCTAssertEqual(GameEngine.legalActions(in: state), [])
        XCTAssertRejects(.pass, in: state, with: .gameOver)
        XCTAssertRejects(.resolvePhase, in: state, with: .gameOver)
    }
}
