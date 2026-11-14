//
//  SalesOrderTests.swift
//  Werks
//
//  Created by AD on 12/11/2026.
//

import XCTest
@testable import WerksPackage


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

