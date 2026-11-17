//
//  MarketTests.swift
//  WerksPackage
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

/// Marktet tests
final class MarketTests: XCTestCase {
    private func market(_ state: GameState) throws -> GameState {
        try apply(.resolvePhase, to: state)
    }

    private func marketState() -> GameState {
        Fixture.blank(phase: .marketDemand)
    }

    func testNoGenerationsChangesNothing() throws {
        let state = marketState()
        let next = try market(state)
        XCTAssertEqual(next.board, state.board)
    }

    func testOneGenerationBelowMaxGainsDieAndRollsCustomerBase() throws {
        var state = marketState()
        state.setOrders(1, existing: [2], filled: [3])     // 2 of 3 dice
        let next = try market(state)
        XCTAssertEqual(next.board[1].existingOrders.count, 3)
        XCTAssertEqual(next.board[1].existingOrders.first, 2, "existing dice keep their faces")
        XCTAssertTrue(next.board[1].filledOrders.isEmpty)
        XCTAssertEqual(next.board[1].rust, .available)
    }

    func testOneGenerationAtMaxGainsNothing() throws {
        var state = marketState()
        state.setOrders(1, existing: [1, 2], filled: [4])
        XCTAssertEqual(try market(state).board[1].existingOrders.count, 3)

        state.setOrders(1, existing: [1, 2, 3])
        XCTAssertEqual(try market(state).board[1].existingOrders, [1, 2, 3])
    }

    func testTwoGenerationsAgeTheOlderAndGrowTheNewer() throws {
        var state = marketState()
        state.setOrders(1, existing: [2], filled: [5, 6])
        state.setOrders(5, filled: [3])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        let next = result.state
        XCTAssertEqual(next.board[1].existingOrders.count, 2)
        XCTAssertEqual(next.board[1].diceCount, 2, "one customer die returned")
        XCTAssertEqual(next.board[1].rust, .rusting)
        XCTAssertEqual(next.board[5].existingOrders.count, 2)
        XCTAssertTrue(result.events.contains(.rusting(locomotiveID: 1)))
    }

    // Rulebook p.7 note: no Customer Base dice → the LOWEST Existing Orders die is returned.
    func testOlderGenerationWithEmptyCustomerBaseReturnsLowestExistingDie() throws {
        var state = marketState()
        state.setOrders(1, existing: [5, 2, 6])
        state.setOrders(5, existing: [3])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        XCTAssertEqual(result.state.board[1].existingOrders, [5, 6])
        XCTAssertEqual(result.state.board[1].rust, .rusting)
        XCTAssertTrue(result.events.contains(.dieReturned(locomotiveID: 1, die: 2)))
    }

    func testOlderGenerationPrefersCustomerBaseDie() throws {
        var state = marketState()
        state.setOrders(1, existing: [1], filled: [4])
        state.setOrders(5, existing: [3])
        let next = try market(state)
        XCTAssertEqual(next.board[1].existingOrders, [1], "customer die returned, existing die kept")
    }

    func testOlderGenerationLosingLastDieStopsExisting() throws {
        var state = marketState()
        state.setOrders(1, existing: [4])
        state.setOrders(5, existing: [3])
        let next = try market(state)
        XCTAssertFalse(next.board[1].isInMarket)
        XCTAssertNotEqual(next.board[1].rust, .obsolete)
        XCTAssertFalse(next.board[1].isPurchasable)
    }

    func testThreeGenerationsObsoleteOldestTopUpMiddleGrowNewest() throws {
        var state = marketState()
        state.setOrders(1, existing: [1])
        state.setOrders(5, existing: [2])
        state.setOrders(8, existing: [3])
        let result = try GameEngine.apply(.resolvePhase, to: state)
        let next = result.state
        XCTAssertEqual(next.board[1].rust, .obsolete)
        XCTAssertEqual(next.board[1].diceCount, 0)
        XCTAssertEqual(next.board[1].availableCardCount, 0)
        XCTAssertEqual(next.board[5].existingOrders.count, 4)
        XCTAssertEqual(next.board[5].existingOrders.first, 2)
        XCTAssertEqual(next.board[8].existingOrders.count, 2)
        XCTAssertTrue(result.events.contains(.obsolete(locomotiveID: 1)))
    }

    func testFourGenerationsObsoleteAllButNewestTwo() throws {
        var state = marketState()
        for id in [1, 5, 8, 11] { state.setOrders(id, existing: [1]) }
        let next = try market(state)
        XCTAssertEqual(next.board[1].rust, .obsolete)
        XCTAssertEqual(next.board[5].rust, .obsolete)
        XCTAssertEqual(next.board[8].existingOrders.count, 4)
        XCTAssertEqual(next.board[11].existingOrders.count, 2)
    }

    func testInitialDieAloneIsNotAGeneration() throws {
        var state = marketState()
        state.setOrders(1, existing: [2])
        state.board[5].placeInitialOrder(4)
        let next = try market(state)
        XCTAssertEqual(next.board[1].existingOrders.count, 2, "treated as the only generation")
        XCTAssertEqual(next.board[1].rust, .available)
        XCTAssertEqual(next.board[5].initialOrder, 4)
        XCTAssertTrue(next.board[5].existingOrders.isEmpty)
    }

    func testObsoleteGenerationsAreIgnored() throws {
        var state = marketState()
        state.board[1].makeObsolete()
        state.setOrders(5, existing: [2])
        let next = try market(state)
        XCTAssertEqual(next.board[5].existingOrders.count, 2)
        XCTAssertEqual(next.board[5].rust, .available)
    }

    func testGenerationOrderUsesGenerationNotRustFlag() throws {
        var state = marketState()
        state.setOrders(1, existing: [2])
        state.setOrders(5, existing: [2])
        state.board[5].rust = .rusting          // misleading flag
        let next = try market(state)
        XCTAssertEqual(next.board[1].diceCount, 0, "green 1st is the older generation and returns its die")
        XCTAssertEqual(next.board[5].diceCount, 2, "green 2nd is the newer generation")
    }

    func testLiveriesAreIndependent() throws {
        var state = marketState()
        state.setOrders(1, existing: [2])
        state.setOrders(2, existing: [2])
        let next = try market(state)
        XCTAssertEqual(next.board[1].rust, .available)
        XCTAssertEqual(next.board[2].rust, .available)
        XCTAssertEqual(next.board[2].existingOrders.count, 2)
    }

    func testRolledDiceAreValidAndCapped() throws {
        var state = marketState()
        state.setOrders(11, filled: [1, 1, 1, 1, 1])
        let next = try market(state)
        XCTAssertEqual(next.board[11].existingOrders.count, 5)
        XCTAssertTrue(next.board[11].existingOrders.allSatisfy { (1...6).contains($0) })
    }

    func testMarketStartsNextRound() throws {
        let next = try market(marketState())
        XCTAssertEqual(next.round, 2)
        XCTAssertEqual(next.phase, .development)
        XCTAssertEqual(next.currentPlayerID, next.turnOrder[0])
    }
}
