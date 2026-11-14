//
//  CapacityTests.swift
//  WerksPackage
//
//  Created by Amarjit on 14/11/2026.
//

import XCTest
@testable import WerksPackage

final class CapacityTests: XCTestCase {
    private func capacityState() -> GameState {
        var state = Fixture.blank(phase: .capacity)
        state.setOrders(1, existing: [2])
        state.setOrders(2, existing: [2])
        state.setOrders(5, existing: [2])
        return state
    }

    func testBuyUnits() throws {
        var state = capacityState()
        state.give(0, 2)
        state = try apply(.buyCapacity(locomotiveID: 2, units: 3), to: state)
        XCTAssertEqual(state.units(0, 2), 4)
        XCTAssertEqual(state.coins(of: 0), 100 - 3 * 4)
        XCTAssertEqual(state.currentPlayerID, 0, "buying does not end the turn")
    }

    func testBuyRequiresOwnership() {
        XCTAssertRejects(.buyCapacity(locomotiveID: 2, units: 1), in: capacityState(), with: .locomotiveNotOwned(2))
    }

    func testBuyRejectsNonPositiveUnits() {
        var state = capacityState()
        state.give(0, 2)
        XCTAssertRejects(.buyCapacity(locomotiveID: 2, units: 0), in: state, with: .invalidUnitCount(0))
        XCTAssertRejects(.buyCapacity(locomotiveID: 2, units: -1), in: state, with: .invalidUnitCount(-1))
    }

    func testBuyRequiresFunds() {
        var state = capacityState()
        state.setCoins(0, 7)
        state.give(0, 2)
        XCTAssertRejects(.buyCapacity(locomotiveID: 2, units: 2), in: state,
                         with: .insufficientFunds(required: 8, available: 7))
    }

    func testCannotBuyOnObsoleteLocomotive() {
        var state = capacityState()
        state.give(0, 1)
        state.board[1].makeObsolete()
        XCTAssertRejects(.buyCapacity(locomotiveID: 1, units: 1), in: state, with: .locomotiveObsolete(1))
    }

    func testShiftPaysDifferenceAndDiscardsEmptyCard() throws {
        var state = capacityState()
        state.give(0, 1, units: 2)
        state.give(0, 5, units: 1)
        let result = try GameEngine.apply(.shiftCapacity(from: 1, to: 5, units: 2), to: state)
        let hand = result.state.players[0].hand
        XCTAssertEqual(result.state.coins(of: 0), 100 - (10 - 2) * 2)
        XCTAssertNil(hand.card(1))
        XCTAssertEqual(hand.card(5)?.production.units, 3)
        XCTAssertTrue(hand.hasHeld(1))
        XCTAssertTrue(result.events.contains(.cardDiscarded(playerID: 0, locomotiveID: 1)))
    }

    func testPartialShiftKeepsSourceCard() throws {
        var state = capacityState()
        state.give(0, 1, units: 3)
        state.give(0, 2, units: 1)
        state = try apply(.shiftCapacity(from: 1, to: 2, units: 1), to: state)
        XCTAssertEqual(state.units(0, 1), 2)
        XCTAssertEqual(state.units(0, 2), 2)
        XCTAssertEqual(state.coins(of: 0), 98)
    }

    func testCannotShiftDownOrSideways() {
        var state = capacityState()
        state.give(0, 1)
        state.give(0, 5)
        XCTAssertRejects(.shiftCapacity(from: 5, to: 1, units: 1), in: state, with: .cannotShiftDown(from: 5, to: 1))
        XCTAssertRejects(.shiftCapacity(from: 5, to: 5, units: 1), in: state, with: .cannotShiftDown(from: 5, to: 5))
    }

    func testUnitsOnLastSpaceCanGoNowhere() {
        var state = capacityState()
        state.give(0, 13)
        state.give(0, 14)
        XCTAssertRejects(.shiftCapacity(from: 14, to: 13, units: 1), in: state, with: .cannotShiftDown(from: 14, to: 13))
        XCTAssertFalse(GameEngine.legalActions(in: state).contains { action in
            if case .shiftCapacity(14, _, _) = action { return true } else { return false }
        })
    }

    func testShiftAcrossLiveriesIsAllowedWhenHigherOnBoard() throws {
        var state = capacityState()
        state.give(0, 2)   // Red 1st
        state.give(0, 5)   // Green 2nd
        state = try apply(.shiftCapacity(from: 2, to: 5, units: 1), to: state)
        XCTAssertEqual(state.coins(of: 0), 100 - (10 - 4))
    }

    // Rulebook p.4: Green 4th (22) → Yellow 3rd (24) is an upgrade costing 2.
    func testRulebookShiftExampleAcrossGenerations() throws {
        var state = capacityState()
        state.setOrders(11, existing: [1])
        state.setOrders(12, existing: [1])
        state.give(0, 11)
        state.give(0, 12)
        state = try apply(.shiftCapacity(from: 11, to: 12, units: 1), to: state)
        XCTAssertEqual(state.coins(of: 0), 98)
        XCTAssertEqual(state.units(0, 12), 2)
    }

    // Rulebook p.4: 2 units on Red 1st cost 2 × 4 = 8.
    func testRulebookBuyExample() throws {
        var state = capacityState()
        state.give(0, 2)
        state = try apply(.buyCapacity(locomotiveID: 2, units: 2), to: state)
        XCTAssertEqual(state.coins(of: 0), 92)
    }

    func testShiftRequiresBothCardsAndEnoughUnits() {
        var state = capacityState()
        state.give(0, 1, units: 1)
        XCTAssertRejects(.shiftCapacity(from: 1, to: 5, units: 1), in: state, with: .locomotiveNotOwned(5))
        XCTAssertRejects(.shiftCapacity(from: 2, to: 5, units: 1), in: state, with: .locomotiveNotOwned(2))
        state.give(0, 5)
        XCTAssertRejects(.shiftCapacity(from: 1, to: 5, units: 2), in: state,
                         with: .notEnoughUnits(requested: 2, available: 1))
    }

    func testShiftRequiresFunds() {
        var state = capacityState()
        state.setCoins(0, 7)
        state.give(0, 1)
        state.give(0, 5)
        XCTAssertRejects(.shiftCapacity(from: 1, to: 5, units: 1), in: state,
                         with: .insufficientFunds(required: 8, available: 7))
    }

    func testCanShiftOffAnObsoleteCardButNotOntoOne() throws {
        var state = capacityState()
        state.give(0, 1)
        state.give(0, 2)
        state.give(0, 5)
        state.board[1].makeObsolete()
        state = try apply(.shiftCapacity(from: 1, to: 5, units: 1), to: state)
        XCTAssertNil(state.players[0].hand.card(1))

        state.board[5].makeObsolete()
        XCTAssertRejects(.shiftCapacity(from: 2, to: 5, units: 1), in: state, with: .locomotiveObsolete(5))
    }

    func testManyActionsThenPassToProduction() throws {
        var state = capacityState()
        state.give(0, 1)
        state = try apply(.buyCapacity(locomotiveID: 1, units: 1), to: state)
        state = try apply(.buyCapacity(locomotiveID: 1, units: 2), to: state)
        XCTAssertEqual(state.units(0, 1), 4)
        for _ in 0..<3 { state = try apply(.pass, to: state) }
        XCTAssertEqual(state.phase, .production)
        XCTAssertNil(state.currentPlayerID)
    }

    func testCapacityActionsRejectedInDevelopment() {
        var state = Fixture.blank()
        state.give(0, 1)
        XCTAssertRejects(.buyCapacity(locomotiveID: 1, units: 1), in: state, with: .wrongPhase(.development))
    }
}
