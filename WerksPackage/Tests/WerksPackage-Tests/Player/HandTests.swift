//
//  HandTests.swift
//  WerksPackage
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

/// Hand management tests
final class HandTests: XCTestCase {
    func testAddKeepsBoardOrderAndHistory() throws {
        var hand = Hand()
        try hand.add(LocomotiveCard(locomotiveID: 5))
        try hand.add(LocomotiveCard(locomotiveID: 2))
        XCTAssertEqual(hand.ids, [2, 5])
        XCTAssertTrue(hand.hasHeld(2))
        XCTAssertTrue(hand.contains(5))
    }

    func testOnlyOneOfEachLocomotive() throws {
        var hand = Hand(cards: [LocomotiveCard(locomotiveID: 1)])
        XCTAssertGameError(try hand.add(LocomotiveCard(locomotiveID: 1)), .alreadyDeveloped(1))
    }

    func testRemovedCardStaysInHistoryAndCannotReturn() throws {
        var hand = Hand(cards: [LocomotiveCard(locomotiveID: 1)])
        let removed = try hand.remove(1)
        XCTAssertEqual(removed.locomotiveID, 1)
        XCTAssertFalse(hand.contains(1))
        XCTAssertTrue(hand.hasHeld(1))
        XCTAssertGameError(try hand.add(LocomotiveCard(locomotiveID: 1)), .alreadyDeveloped(1))
    }

    func testRemoveOrModifyMissingCard() {
        var hand = Hand()
        XCTAssertGameError(try hand.remove(3), .locomotiveNotOwned(3))
        XCTAssertGameError(try hand.modify(3) { _ in }, .locomotiveNotOwned(3))
    }

    func testFailedModifyLeavesCardUnchanged() throws {
        var hand = Hand(cards: [LocomotiveCard(locomotiveID: 1, units: 2)])
        XCTAssertGameError(try hand.modify(1) { card in
            try card.production.add(1)        // succeeds on the copy...
            try card.production.spend(99)     // ...then fails
        }, .notEnoughUnits(requested: 99, available: 3))
        XCTAssertEqual(hand.card(1)?.production, ProductionUnits(units: 2))
    }

    func testTotalUnits() {
        let hand = Hand(cards: [LocomotiveCard(locomotiveID: 1, units: 2), LocomotiveCard(locomotiveID: 2, units: 3)])
        XCTAssertEqual(hand.totalUnits, 5)
    }
}
