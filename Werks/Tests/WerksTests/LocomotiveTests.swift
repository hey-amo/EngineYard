//
//  LocomotiveTests.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest
@testable import Werks

final class LocomotiveTests: XCTestCase {
    func testBuildAllReturnsManifestTrainPools() {
        let locomotives = LocomotiveDefinition.buildAll()

        XCTAssertEqual(locomotives.count, 14)
        XCTAssertEqual(locomotives.map(\.totalCardCount), [4, 3, 2, 1, 4, 3, 2, 4, 2, 3, 4, 3, 4, 4])
        XCTAssertEqual(locomotives.map(\.name), [
            "Green.1st", "Red.1st", "Yellow.1st", "Blue.1st",
            "Green.2nd", "Red.2nd", "Yellow.2nd", "Green.3rd",
            "Blue.2nd", "Red.3rd", "Green.4th", "Yellow.3rd",
            "Red.4th", "Green.5th"
        ])
        XCTAssertEqual(locomotives.reduce(0) { $0 + $1.totalCardCount }, 43)
    }

    func testTrainPoolCountsByColourAndGeneration() {
        let locomotives = LocomotiveDefinition.buildAll()
        let expectedCounts: [(LocomotiveLivery, [Int])] = [
            (.green, [4, 4, 4, 4, 4]),
            (.red, [3, 3, 3, 4, 0]),
            (.yellow, [2, 2, 3, 0, 0]),
            (.blue, [1, 2, 0, 0, 0])
        ]

        for (colour, expectedByGeneration) in expectedCounts {
            let actualByGeneration = LocomotiveGeneration.allCases.map { generation in
                locomotives
                    .filter { $0.colour == colour && $0.generation == generation }
                    .reduce(0) { $0 + $1.totalCardCount }
            }

            XCTAssertEqual(actualByGeneration, expectedByGeneration, "\(colour)")
        }
    }

    func testDicePoolTotalIs46() {
        let totalDicePool = LocomotiveDefinition.buildAll().reduce(0) { $0 + $1.dicePool }

        XCTAssertEqual(totalDicePool, 46)
    }

    func testCostsAreMultiplesOfFourAndTotal420() {
        let costs = LocomotiveDefinition.buildAll().map(\.cost)

        XCTAssertTrue(costs.allSatisfy { $0.isMultiple(of: 4) })
        XCTAssertEqual(costs.reduce(0, +), 420)
    }
}
