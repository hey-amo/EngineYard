//
//  RandomTests.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

import Foundation
import XCTest
@testable import werks_package

final class RandomTests: XCTestCase {
    func testSameSeedSameSequence() {
        var a = SeededRandomNumberGenerator(seed: 42)
        var b = SeededRandomNumberGenerator(seed: 42)
        for _ in 0..<100 { XCTAssertEqual(a.next(), b.next()) }
    }

    func testDifferentSeedsDiffer() {
        var a = SeededRandomNumberGenerator(seed: 1)
        var b = SeededRandomNumberGenerator(seed: 2)
        XCTAssertNotEqual((0..<10).map { _ in a.next() }, (0..<10).map { _ in b.next() })
    }

    func testDieRollsCoverOneToSix() {
        var rng = SeededRandomNumberGenerator(seed: 7)
        let rolls = (0..<600).map { _ in rng.rollDie() }
        XCTAssertTrue(rolls.allSatisfy { (1...6).contains($0) })
        XCTAssertEqual(Set(rolls), Set(1...6))
    }

    func testShuffleIsDeterministicPermutation() {
        var a = SeededRandomNumberGenerator(seed: 9)
        var b = SeededRandomNumberGenerator(seed: 9)
        let input = Array(0..<10)
        let shuffled = a.shuffle(input)
        XCTAssertEqual(shuffled, b.shuffle(input))
        XCTAssertEqual(shuffled.sorted(), input)
    }

    func testCodableResumesSequence() throws {
        var rng = SeededRandomNumberGenerator(seed: 3)
        _ = rng.next()
        var copy = try JSONDecoder().decode(SeededRandomNumberGenerator.self,
                                            from: JSONEncoder().encode(rng))
        XCTAssertEqual(rng.next(), copy.next())
    }
}
