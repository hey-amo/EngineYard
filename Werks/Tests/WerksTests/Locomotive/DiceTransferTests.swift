//
//  DiceTransferTests.swift
//  WerksPackage
//
//  Created by Claude Haiku 4.5 <noreply@anthropic.com>
//

import XCTest
@testable import WerksPackage

/// Tests for DiceTransferManager - centralized dice transition logic
final class DiceTransferTests: XCTestCase {
    // MARK: - promoteInitialToExisting Tests

    func testPromoteInitialToExistingMovesInitialDie() {
        var state = Fixture.blank()
        state.board[1].placeInitialOrder(4)

        let result = DiceTransferManager.promoteInitialToExisting(1, in: &state.board)

        XCTAssertEqual(result, 4)
        XCTAssertNil(state.board[1].initialOrder)
        XCTAssertEqual(state.board[1].existingOrders, [4])
    }

    func testPromoteInitialToExistingReturnsNilWhenNoInitial() {
        var state = Fixture.blank()
        state.board[1].existingOrders = [2, 3]

        let result = DiceTransferManager.promoteInitialToExisting(1, in: &state.board)

        XCTAssertNil(result)
        XCTAssertEqual(state.board[1].existingOrders, [2, 3])
    }

    // MARK: - returnOneDieToPool Tests

    func testReturnOneDiePrefersCustBase() {
        var state = Fixture.blank()
        state.board[1].filledOrders = [5, 6]
        state.board[1].existingOrders = [1, 2, 3]

        let result = DiceTransferManager.returnOneDieToPool(1, in: &state.board)

        XCTAssertEqual(result, 6)
        XCTAssertEqual(state.board[1].filledOrders, [5])
        XCTAssertEqual(state.board[1].existingOrders, [1, 2, 3])
    }

    func testReturnOneDieUsesLowestExistingWhenNoCustBase() {
        var state = Fixture.blank()
        state.board[1].filledOrders = []
        state.board[1].existingOrders = [5, 2, 6]

        let result = DiceTransferManager.returnOneDieToPool(1, in: &state.board)

        XCTAssertEqual(result, 2)
        XCTAssertEqual(state.board[1].existingOrders, [5, 6])
    }

    func testReturnOneDieReturnsNilWhenNoDice() {
        var state = Fixture.blank()
        state.board[1].filledOrders = []
        state.board[1].existingOrders = []

        let result = DiceTransferManager.returnOneDieToPool(1, in: &state.board)

        XCTAssertNil(result)
    }

    // MARK: - rollFilledOrders Tests

    func testRollFilledOrdersTransitionsDiceCorrectly() {
        var state = Fixture.blank()
        state.board[1].filledOrders = [1, 1, 1]
        state.board[1].existingOrders = [4]

        let rolled = DiceTransferManager.rollFilledOrders(1, using: &state.rng, in: &state.board)

        XCTAssertEqual(rolled.count, 3)
        XCTAssertTrue(rolled.allSatisfy { (1...6).contains($0) })
        XCTAssertTrue(state.board[1].filledOrders.isEmpty)
        XCTAssertEqual(state.board[1].existingOrders.count, 4)
        XCTAssertEqual(state.board[1].existingOrders.first, 4)
    }

    func testRollFilledOrdersEmptyWhenNoFilled() {
        var state = Fixture.blank()
        state.board[1].filledOrders = []
        state.board[1].existingOrders = [3]

        let rolled = DiceTransferManager.rollFilledOrders(1, using: &state.rng, in: &state.board)

        XCTAssertTrue(rolled.isEmpty)
        XCTAssertEqual(state.board[1].existingOrders, [3])
    }

    // MARK: - reduceDemand Tests

    func testReduceDemandSubtractsFromHighestDie() {
        var state = Fixture.blank()
        state.board[1].existingOrders = [2, 5, 3]

        DiceTransferManager.reduceDemand(1, by: 2, in: &state.board)

        XCTAssertEqual(state.board[1].existingOrders, [2, 3, 3])
    }

    func testReduceDemandRemovesDieWhenReachedZero() {
        var state = Fixture.blank()
        state.board[1].existingOrders = [2, 4, 1]

        DiceTransferManager.reduceDemand(1, by: 4, in: &state.board)

        XCTAssertEqual(state.board[1].existingOrders, [2, 1])
    }

    func testReduceDemandWithEmptyOrders() {
        var state = Fixture.blank()
        state.board[1].existingOrders = []

        DiceTransferManager.reduceDemand(1, by: 5, in: &state.board)

        XCTAssertTrue(state.board[1].existingOrders.isEmpty)
    }

    func testReduceDemandWithZeroUnits() {
        var state = Fixture.blank()
        state.board[1].existingOrders = [3, 4]

        DiceTransferManager.reduceDemand(1, by: 0, in: &state.board)

        XCTAssertEqual(state.board[1].existingOrders, [3, 4])
    }

    // MARK: - Integration Tests

    func testMultipleTransitionsInSequence() {
        var state = Fixture.blank()

        // Step 1: Place and promote initial order
        state.board[1].placeInitialOrder(3)
        let promoted = DiceTransferManager.promoteInitialToExisting(1, in: &state.board)
        XCTAssertEqual(promoted, 3)

        // Step 2: Add filled orders and roll them
        state.board[1].filledOrders = [1, 1]
        let rolled = DiceTransferManager.rollFilledOrders(1, using: &state.rng, in: &state.board)
        XCTAssertEqual(rolled.count, 2)

        // Step 3: Reduce demand (simulate sale)
        DiceTransferManager.reduceDemand(1, by: 2, in: &state.board)
        XCTAssertGreaterThanOrEqual(state.board[1].existingOrders.count, 1)
    }

    func testDiceAreNeverLostOrDuplicated() {
        var state = Fixture.blank()
        state.board[1].initialOrder = 4
        state.board[1].existingOrders = [2, 3]
        state.board[1].filledOrders = [5, 6]

        let initialCount = 1 + 2 + 2  // initial + existing + filled

        // Promote
        _ = DiceTransferManager.promoteInitialToExisting(1, in: &state.board)
        let countAfterPromote = state.board[1].existingOrders.count + state.board[1].filledOrders.count

        // Roll filled
        _ = DiceTransferManager.rollFilledOrders(1, using: &state.rng, in: &state.board)
        let countAfterRoll = state.board[1].existingOrders.count + state.board[1].filledOrders.count

        // Return one
        _ = DiceTransferManager.returnOneDieToPool(1, in: &state.board)
        let countAfterReturn = state.board[1].existingOrders.count + state.board[1].filledOrders.count

        // Count after operations: 4 existing, 0 filled
        XCTAssertEqual(countAfterPromote, 5)  // 4 existing + 2 filled
        XCTAssertEqual(countAfterRoll, 5)     // All in existing now
        XCTAssertEqual(countAfterReturn, 4)   // One returned to pool
    }
}
