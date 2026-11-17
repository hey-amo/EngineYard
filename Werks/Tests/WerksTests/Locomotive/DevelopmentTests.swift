//
//  LocoDevelopmentTests.swift
//  WerksPackage
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

// Locomotive development tests
final class LocoDevelopmentTests: XCTestCase {
    
    /// You can't develop a locomotive if has no orders
    func testCannotDevelopWithoutAnyOrders() {
        XCTAssertRejects(.develop(locomotiveID: 1), in: Fixture.blank(), with: .locomotiveUnavailable(1))
    }

    /// Initial Die should move -> Existing orders and opens up next space
    func testInitialDieMovesToExistingAndNextSpaceSpawns() throws {
        var state = Fixture.blank()
        state.board[1].placeInitialOrder(4)
        XCTAssertEqual(state.board[1].rust, .available)

        let result = try GameEngine.apply(.develop(locomotiveID: 1), to: state)
        let next = result.state
        XCTAssertNil(next.board[1].initialOrder)
        XCTAssertEqual(next.board[1].existingOrders, [4])
        XCTAssertEqual(next.board[1].availableCardCount, 3)
        XCTAssertEqual(next.coins(of: 0), 96)
        XCTAssertEqual(next.players[0].hand.card(1), LocomotiveCard(locomotiveID: 1, units: 1))
        XCTAssertNotNil(next.board[2].initialOrder)
        XCTAssertEqual(next.board[2].rust, .available)
        XCTAssertEqual(next.board[3].rust, .unavailable)
        XCTAssertEqual(next.currentPlayerID, 1, "developing ends the turn")
        XCTAssertTrue(result.events.contains(.initialOrderPromoted(locomotiveID: 1, die: 4)))
        XCTAssertEqual(receipts(in: result.events),
                       [BankTransaction(playerID: 0, amount: -4, reason: .development(locomotiveID: 1), balanceAfter: 96)])
    }

    /// Ensure the initialDie once used, is never repopulated
    func testInitialDieIsNeverRepopulated() throws {
        var state = Fixture.blank()
        state.board[1].placeInitialOrder(4)
        state = try apply(.develop(locomotiveID: 1), to: state)
        state = try apply(.develop(locomotiveID: 1), to: state)   // player 1, via existing orders
        XCTAssertNil(state.board[1].initialOrder)
        XCTAssertEqual(state.board[1].existingOrders, [4])
        XCTAssertEqual(state.board[1].availableCardCount, 2)
    }

    /// Test that the existing orders doesn't unlock anything
    func testDevelopingViaExistingOrdersDoesNotSpawnNext() throws {
        var state = Fixture.blank()
        state.setOrders(1, existing: [3])
        state = try apply(.develop(locomotiveID: 1), to: state)
        XCTAssertEqual(state.board[2].rust, .unavailable)
        XCTAssertNil(state.board[2].initialOrder)
    }

    /// Test that we can develop via filled orders
    func testDevelopingViaFilledOrdersOnlyIsAllowed() throws {
        var state = Fixture.blank()
        state.setOrders(1, filled: [3])
        state = try apply(.develop(locomotiveID: 1), to: state)
        XCTAssertTrue(state.players[0].hand.contains(1))
    }

    /// Test that we overwrite an initialOrder data
    func testSpawnDoesNotOverwriteAnAlreadyActiveSpace() throws {
        var state = Fixture.blank()
        state.board[1].placeInitialOrder(4)
        state.setOrders(2, existing: [5])
        state = try apply(.develop(locomotiveID: 1), to: state)
        XCTAssertNil(state.board[2].initialOrder)
        XCTAssertEqual(state.board[2].existingOrders, [5])
    }

    /// Test boundaries of board
    func testLastSpaceDoesNotSpawnBeyondBoard() throws {
        var state = Fixture.blank()
        state.board[14].placeInitialOrder(2)
        state = try apply(.develop(locomotiveID: 14), to: state)
        XCTAssertEqual(state.board.spaces.count, 14)
        XCTAssertEqual(state.board[14].existingOrders, [2])
    }

    /// Test you can only develop 1 of each type of locomotive
    func testOnlyOneOfEachLocomotive() {
        var state = Fixture.blank()
        state.setOrders(1, existing: [2])
        state.give(0, 1)
        XCTAssertRejects(.develop(locomotiveID: 1), in: state, with: .alreadyDeveloped(1))
    }

    /// You can redevelop a locomotive after removing it from your hand (rebuy allowed)
    func testCanRebuyAfterRemoval() throws {
        var state = Fixture.blank()
        state.setOrders(1, existing: [2])
        state.give(0, 1)
        try state.players[0].hand.remove(1)
        let result = try GameEngine.apply(.develop(locomotiveID: 1), to: state)
        XCTAssertTrue(result.state.players[0].hand.contains(1))
    }

    /// Test insufficient funds
    func testInsufficientFunds() {
        var state = Fixture.blank(coins: 3)
        state.setOrders(1, existing: [2])
        XCTAssertRejects(.develop(locomotiveID: 1), in: state, with: .insufficientFunds(required: 4, available: 3))
    }

    /// Test exact funds
    func testExactFundsAreEnough() throws {
        var state = Fixture.blank(coins: 4)
        state.setOrders(1, existing: [2])
        XCTAssertEqual(try apply(.develop(locomotiveID: 1), to: state).coins(of: 0), 0)
    }

    /// Test no cards left
    func testNoCardsLeft() {
        var state = Fixture.blank()
        state.setOrders(1, existing: [2])
        state.board[1].availableCardCount = 0
        XCTAssertRejects(.develop(locomotiveID: 1), in: state, with: .noCardsAvailable(1))
    }

    /// Test that you can't develop an `obsolete` locomotive
    func testObsoleteCannotBeDeveloped() {
        var state = Fixture.blank()
        state.board[1].makeObsolete()
        XCTAssertRejects(.develop(locomotiveID: 1), in: state, with: .locomotiveObsolete(1))
    }

    /// Unknown locomotive test
    func testUnknownLocomotive() {
        XCTAssertRejects(.develop(locomotiveID: 15), in: Fixture.blank(), with: .unknownLocomotive(15))
        XCTAssertRejects(.develop(locomotiveID: 0), in: Fixture.blank(), with: .unknownLocomotive(0))
    }

    /// Testing 3rd Gen withdraws 1st Gen cards (is of any specific type though)
    func testThirdGenerationWithdrawsFirstGenerationCards() throws {
        var state = Fixture.blank()
        state.setOrders(1, existing: [2])
        state.setOrders(5, existing: [3])
        state.board[8].placeInitialOrder(3)
        let result = try GameEngine.apply(.develop(locomotiveID: 8), to: state)
        XCTAssertEqual(result.state.board[1].availableCardCount, 0)
        XCTAssertEqual(result.state.board[1].existingOrders, [2], "dice stay, it can still sell")
        XCTAssertEqual(result.state.board[5].availableCardCount, 4)
        XCTAssertTrue(result.events.contains(.cardsWithdrawn(locomotiveID: 1, count: 4)))
    }

    /// Test 4th gen Red withdraws 2nd gen Red
    func testFourthGenerationRedWithdrawsSecondGenerationRed() throws {
        var state = Fixture.blank()
        state.board[13].placeInitialOrder(1)
        state = try apply(.develop(locomotiveID: 13), to: state)
        XCTAssertEqual(state.board[6].availableCardCount, 0)
        XCTAssertEqual(state.board[2].availableCardCount, 3)
        XCTAssertEqual(state.board[10].availableCardCount, 3)
    }

    /// Test A second gen withdraws nothing
    func testSecondGenerationWithdrawsNothing() throws {
        var state = Fixture.blank()
        state.board[5].placeInitialOrder(1)
        state = try apply(.develop(locomotiveID: 5), to: state)
        XCTAssertEqual(state.board[1].availableCardCount, 4)
    }

    /// Test withdraw of a loco only happens on first purchase
    func testWithdrawOnlyHappensOnFirstPurchase() throws {
        var state = Fixture.blank()
        state.setOrders(8, existing: [3])          // already in play
        state = try apply(.develop(locomotiveID: 8), to: state)
        XCTAssertEqual(state.board[1].availableCardCount, 4)
    }

    // Test pass moves game phase -> capacity
    func testAllPassingMovesToCapacity() throws {
        var state = Fixture.blank()
        for _ in 0..<3 { state = try apply(.pass, to: state) }
        XCTAssertEqual(state.phase, .capacity)
        XCTAssertEqual(state.currentPlayerID, 0)
    }

    // Test loco development outside the game phase; should fail
    func testDevelopOutsideDevelopmentPhase() {
        var state = Fixture.blank(phase: .capacity)
        state.setOrders(1, existing: [2])
        XCTAssertRejects(.develop(locomotiveID: 1), in: state, with: .wrongPhase(.capacity))
    }

    // Test the local actions in the purchasable locomotives list
    func testLegalActionsListPurchasableLocomotives() {
        var state = Fixture.blank()
        state.setOrders(1, existing: [2])
        state.board[2].placeInitialOrder(3)
        state.board[4].placeInitialOrder(3)
        state.board[4].availableCardCount = 0
        XCTAssertEqual(GameEngine.legalActions(in: state),
                       [.develop(locomotiveID: 1), .develop(locomotiveID: 2), .pass])
    }
}
