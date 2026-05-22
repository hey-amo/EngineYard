//
//  LocomotiveTests.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import XCTest

@testable import Werks

final class LocomotiveTests: XCTestCase {

    private let locomotives: [Locomotive]

    override func setUp() async throws {
        locomotives = Locomotive.buildTrains()        
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Locomotive Tests
    func testLocomotiveCount() {
        let count = locomotives.count
        let expected = GameRules.Locomotives.total
        XCTAssertEqual(count, expected, "Expected \(expected) locomotives, but got \(count)")
    }

}
