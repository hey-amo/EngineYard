//
//  GameSetupTests.swift
//  WerksPackage
//

import XCTest
@testable import WerksPackage

final class GameSetupTests: XCTestCase {
    func testThreeAndFourPlayerSetup() throws {
        for count in [3, 4] {
            let state = try GameEngine.newGame(players: Fixture.seats(count), seed: 11).state
            XCTAssertEqual(state.players.count, count)
            XCTAssertEqual(state.bank.balances, Array(repeating: 12, count: count))
            for player in state.players {
                XCTAssertEqual(player.hand.cards, [LocomotiveCard(locomotiveID: 1, units: 1)])
                XCTAssertTrue(player.hand.hasHeld(1))
            }
            let green = state.board[1]
            XCTAssertEqual(green.availableCardCount, 4 - count)
            XCTAssertEqual(green.existingOrders.count, 3)
            XCTAssertNil(green.initialOrder)
            XCTAssertEqual(green.rust, .available)
            XCTAssertNotNil(state.board[2].initialOrder)
            XCTAssertEqual(state.board[2].rust, .available)
            XCTAssertTrue(state.board.spaces.dropFirst(2).allSatisfy { $0.rust == .unavailable })
        }
    }

    func testFivePlayerSetup() throws {
        let state = try GameEngine.newGame(players: Fixture.seats(5), seed: 11).state
        XCTAssertEqual(state.bank.balances, [14, 14, 14, 14, 14])
        XCTAssertTrue(state.players.allSatisfy { $0.hand.isEmpty })
        XCTAssertNotNil(state.board[1].initialOrder)
        XCTAssertTrue(state.board[1].existingOrders.isEmpty)
        XCTAssertEqual(state.board[1].availableCardCount, 4)
        XCTAssertEqual(state.board[2].rust, .unavailable)
    }

    func testInvalidPlayerCounts() {
        for count in [0, 2, 6] {
            XCTAssertThrowsError(try GameEngine.newGame(players: Fixture.seats(count), seed: 1)) {
                XCTAssertEqual($0 as? GameError, .invalidPlayerCount(count))
            }
        }
    }

    func testStartsInDevelopmentWithFirstPlayerOnTurn() throws {
        let state = try GameEngine.newGame(players: Fixture.seats(4), seed: 5).state
        XCTAssertEqual(state.phase, .development)
        XCTAssertEqual(state.round, 1)
        XCTAssertEqual(state.currentPlayerID, state.turnOrder[0])
        XCTAssertEqual(state.status(of: state.turnOrder[0]), .onTurn)
        XCTAssertEqual(state.status(of: state.turnOrder[1]), .idle)
    }

    func testTurnOrderIsSeededShuffle() throws {
        let a = try GameEngine.newGame(players: Fixture.seats(5), seed: 99).state
        let b = try GameEngine.newGame(players: Fixture.seats(5), seed: 99).state
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.turnOrder.sorted(), [0, 1, 2, 3, 4])
        let seeds: [UInt64] = Array(0..<20)
        let orders = try Set(seeds.map { try GameEngine.newGame(players: Fixture.seats(5), seed: $0).state.turnOrder })
        XCTAssertGreaterThan(orders.count, 1)
    }
}
