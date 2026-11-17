//
//  SaleDecisionTests.swift
//  WerksPackage
//
//  Created by AD on 15/11/2026.
//

import XCTest
@testable import WerksPackage

/// Comprehensive tests for the 3-case sales decision tree
/// Tests the priority order: same number → lower number → larger number
final class SaleDecisionTests: XCTestCase {

    // MARK: - Priority Order Tests

    /// Priority a) Same number: exact match takes precedence
    func testPriorityASameNumber() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(3)
        XCTAssertEqual(decision, .sameNumber(index: 2))
    }

    /// Priority b) Lower number: fewer units than highest die
    func testPriorityBLowerNumber() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(5)
        XCTAssertEqual(decision, .lowerNumber(index: 0), "5 < 6, so reduce highest")
    }

    /// Priority c) Larger number: more units than highest die
    func testPriorityCLargerNumber() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(9)
        XCTAssertEqual(decision, .largerNumber(index: 0), "9 > 6, so sell max only")
    }

    // MARK: - Same Number Cases

    /// Same number on lowest die
    func testSameNumberOnLowestDie() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(3)
        XCTAssertEqual(decision, .sameNumber(index: 2))
    }

    /// Same number on middle die
    func testSameNumberOnMiddleDie() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(4)
        XCTAssertEqual(decision, .sameNumber(index: 1))
    }

    /// Same number on highest die
    func testSameNumberOnHighestDie() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(6)
        XCTAssertEqual(decision, .sameNumber(index: 0))
    }

    /// Tied same numbers use first occurrence
    func testSameNumberWithTiedDice() {
        let order = SalesOrder(existing: [4, 4, 2])
        let decision = order.decide(4)
        XCTAssertEqual(decision, .sameNumber(index: 0), "First 4 is chosen")
    }

    // MARK: - Lower Number Cases

    /// Just below highest die
    func testLowerNumberJustBelow() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(5)
        XCTAssertEqual(decision, .lowerNumber(index: 0))
    }

    /// Well below highest die
    func testLowerNumberWellBelow() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(1)
        XCTAssertEqual(decision, .lowerNumber(index: 0), "1 < 6, still use highest")
    }

    /// Lower than multiple dice
    func testLowerNumberMultipleCandidates() {
        let order = SalesOrder(existing: [8, 6, 4])
        let decision = order.decide(5)
        XCTAssertEqual(decision, .lowerNumber(index: 0), "5 < 8, use highest")
    }

    // MARK: - Larger Number Cases

    /// Slightly above highest die
    func testLargerNumberJustAbove() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(7)
        XCTAssertEqual(decision, .largerNumber(index: 0))
    }

    /// Well above highest die
    func testLargerNumberWellAbove() {
        let order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(20)
        XCTAssertEqual(decision, .largerNumber(index: 0))
    }

    // MARK: - Edge Cases

    /// No demand (empty existing orders)
    func testNoDecisionWithNoDemand() {
        let order = SalesOrder(existing: [])
        XCTAssertNil(order.decide(5))
    }

    /// Zero units offered
    func testNoDecisionWithZeroUnits() {
        let order = SalesOrder(existing: [4, 2])
        XCTAssertNil(order.decide(0))
    }

    /// Single die
    func testSingleDie() {
        let order = SalesOrder(existing: [5])
        XCTAssertEqual(order.decide(5), .sameNumber(index: 0))
        XCTAssertEqual(order.decide(3), .lowerNumber(index: 0))
        XCTAssertEqual(order.decide(7), .largerNumber(index: 0))
    }

    // MARK: - Integration with Sell

    /// Verify decide result matches sell behavior
    func testDecideMatchesSellOutcome() {
        var order = SalesOrder(existing: [6, 4, 3])
        let decision = order.decide(5)
        XCTAssertEqual(decision?.saleCase, .lowerNumber)

        var orderCopy = order
        let result = orderCopy.sell(5)
        XCTAssertEqual(result?.saleCase, .lowerNumber)
        XCTAssertEqual(orderCopy.existing, [1, 4, 3], "Highest die reduced: 6 - 5 = 1")
    }

    /// Verify all three cases can occur in sequence
    func testMultipleCasesOnSameDice() {
        var order = SalesOrder(existing: [6, 4, 3])

        // First sale: same number (removes the 3)
        let sale1 = order.sell(3)
        XCTAssertEqual(sale1?.saleCase, .sameNumber)
        XCTAssertEqual(order.existing, [6, 4], "3 removed from dice")
        XCTAssertEqual(order.filled, [3])

        // Second sale: lower number (reduces highest die 6 by 2)
        let sale2 = order.sell(2)
        XCTAssertEqual(sale2?.saleCase, .lowerNumber)
        XCTAssertEqual(order.existing, [4, 4], "6 reduced to 4")
        XCTAssertEqual(order.filled, [3])

        // Third sale: larger number (removes one 4 since 5 > max 4)
        let sale3 = order.sell(5)
        XCTAssertEqual(sale3?.saleCase, .largerNumber)
        XCTAssertEqual(order.existing, [4], "one 4 removed")
        XCTAssertEqual(order.filled, [3, 4])
    }

    // MARK: - Complex Demand Patterns

    /// Dice with gaps (6, 3, 1)
    func testGappedDice() {
        let order = SalesOrder(existing: [6, 3, 1])
        XCTAssertEqual(order.decide(6)?.saleCase, .sameNumber)
        XCTAssertEqual(order.decide(3)?.saleCase, .sameNumber)
        XCTAssertEqual(order.decide(4)?.saleCase, .lowerNumber, "4 < 6")
        XCTAssertEqual(order.decide(2)?.saleCase, .lowerNumber, "2 < 6")
        XCTAssertEqual(order.decide(7)?.saleCase, .largerNumber, "7 > 6")
    }

    /// Identical dice (all same value)
    func testIdenticalDice() {
        let order = SalesOrder(existing: [4, 4, 4])
        XCTAssertEqual(order.decide(4)?.saleCase, .sameNumber)
        XCTAssertEqual(order.decide(3)?.saleCase, .lowerNumber)
        XCTAssertEqual(order.decide(5)?.saleCase, .largerNumber)
    }

    /// Descending order (natural sort)
    func testDescendingDice() {
        let order = SalesOrder(existing: [6, 5, 4, 3, 2, 1])
        XCTAssertEqual(order.decide(6)?.saleCase, .sameNumber, "exact match exists")
        XCTAssertEqual(order.decide(3)?.saleCase, .sameNumber, "exact match exists")
        XCTAssertEqual(order.decide(5)?.saleCase, .sameNumber, "5 matches the 5 die")
        XCTAssertEqual(order.decide(2)?.saleCase, .sameNumber, "2 matches the 2 die")
        XCTAssertEqual(order.decide(7)?.saleCase, .largerNumber, "7 > 6 (highest)")
    }

    // MARK: - Mutation Verification

    /// Verify sameNumber removal
    func testSameNumberRemovesDie() {
        var order = SalesOrder(existing: [6, 4, 3])
        order.sell(4)
        XCTAssertEqual(order.existing, [6, 3])
        XCTAssertEqual(order.filled, [4])
    }

    /// Verify lowerNumber reduces die
    func testLowerNumberReducesDie() {
        var order = SalesOrder(existing: [6, 4, 3])
        order.sell(2)
        XCTAssertEqual(order.existing, [4, 4, 3], "6 - 2 = 4")
        XCTAssertTrue(order.filled.isEmpty)
    }

    /// Verify largerNumber removes highest die
    func testLargerNumberRemovesDie() {
        var order = SalesOrder(existing: [6, 4, 3])
        order.sell(8)
        XCTAssertEqual(order.existing, [4, 3])
        XCTAssertEqual(order.filled, [6])
    }
}
