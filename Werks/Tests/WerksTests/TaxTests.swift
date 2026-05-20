//
//  TaxTests.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import XCTest

@testable import Werks

final class TaxTests: XCTestCase {

    func testTaxOn100_Equals_10() throws {
        let amount = 100
        let expected = 10
        let due = Tax.calculate(on: amount)
        XCTAssertEqual(due, expected, "Due: \(due) is not equal to expected: \(expected)")
    }
    
    func testTaxOn9_Equals_0() throws {
        let amount = 9
        let expected = 0
        let due = Tax.calculate(on: amount)
        XCTAssertEqual(due, expected, "Due: \(due) is not equal to expected: \(expected)")
    }
    
    func testTaxOn300_Equals_30() throws {
        let amount = 300
        let expected = 30
        let due = Tax.calculate(on: amount)
        XCTAssertEqual(due, expected, "Due: \(due) is not equal to expected: \(expected)")
    }
}
