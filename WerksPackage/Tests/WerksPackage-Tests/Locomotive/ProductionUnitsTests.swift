//
//  ProductionUnitsTests.swift
//  WerksPackage
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

final class ProductionUnitsTests: XCTestCase {
    func testSpendThenResetRestoresUnits() throws {
        var units = ProductionUnits(units: 5)
        try units.spend(3)
        XCTAssertEqual(units, ProductionUnits(units: 2, spentUnits: 3))
        XCTAssertEqual(units.total, 5)
        units.reset()
        XCTAssertEqual(units, ProductionUnits(units: 5, spentUnits: 0))
    }

    func testCannotSpendMoreThanOnCard() throws {
        var units = ProductionUnits(units: 2)
        try units.spend(2)
        XCTAssertGameError(try units.spend(1), .notEnoughUnits(requested: 1, available: 0))
    }

    func testAddAndRemove() throws {
        var units = ProductionUnits(units: 1)
        try units.add(2)
        XCTAssertEqual(units.units, 3)
        try units.remove(3)
        XCTAssertTrue(units.isEmpty)
    }

    func testRejectsNonPositiveCounts() {
        var units = ProductionUnits(units: 1)
        XCTAssertGameError(try units.add(0), .invalidUnitCount(0))
        XCTAssertGameError(try units.spend(-1), .invalidUnitCount(-1))
        XCTAssertGameError(try units.remove(0), .invalidUnitCount(0))
    }

    func testResetWithNothingSpentIsNoOp() {
        var units = ProductionUnits(units: 4)
        units.reset()
        XCTAssertEqual(units, ProductionUnits(units: 4))
    }
}

final class ProductionManagerTests: XCTestCase {
    private func hand() -> Hand {
        Hand(cards: [LocomotiveCard(locomotiveID: 1, units: 2), LocomotiveCard(locomotiveID: 5, units: 1)])
    }

    func testAddAndSpend() throws {
        var hand = hand()
        try ProductionManager.addUnits(2, to: 1, in: &hand)
        try ProductionManager.spendUnits(3, on: 1, in: &hand)
        XCTAssertEqual(hand.card(1)?.production, ProductionUnits(units: 1, spentUnits: 3))
    }

    func testResetAllRestoresEveryCard() throws {
        var hand = hand()
        try ProductionManager.spendUnits(2, on: 1, in: &hand)
        try ProductionManager.spendUnits(1, on: 5, in: &hand)
        ProductionManager.resetAll(in: &hand)
        XCTAssertEqual(hand.card(1)?.production, ProductionUnits(units: 2))
        XCTAssertEqual(hand.card(5)?.production, ProductionUnits(units: 1))
    }

    func testTransferReportsEmptiedSource() throws {
        var hand = hand()
        let firstEmptied = try ProductionManager.transfer(1, from: 1, to: 5, in: &hand)
        XCTAssertFalse(firstEmptied)
        let secondEmptied = try ProductionManager.transfer(1, from: 1, to: 5, in: &hand)
        XCTAssertTrue(secondEmptied)
        XCTAssertEqual(hand.card(5)?.production.units, 3)
    }

    func testFailedTransferChangesNothing() {
        var hand = hand()
        XCTAssertGameError(try ProductionManager.transfer(1, from: 1, to: 8, in: &hand), .locomotiveNotOwned(8))
        XCTAssertGameError(try ProductionManager.transfer(3, from: 1, to: 5, in: &hand),
                           .notEnoughUnits(requested: 3, available: 2))
        XCTAssertEqual(hand, self.hand())
    }
}
