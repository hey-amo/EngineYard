//
//  TaxTests.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest
@testable import Werks

final class TaxTests: XCTestCase {

    func testTaxDueIs10Coins() throws {
        let coins: Int = 100
        let expectedDue: Int = 10
        
        let sum: Int = Tax.calculate(on: coins)
        XCTAssertEqual(sum, expectedDue, "Recieved: \(sum)")
    }
}
