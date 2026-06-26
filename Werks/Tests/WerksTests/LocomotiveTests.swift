//
//  LocomotiveTests.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import XCTest

@testable import Werks

// Test locomotives
final class LocomotiveTests: XCTestCase {

    private var locomotives: [Locomotive] = [Locomotive]()
    
    override func setUp() async throws {
        locomotives = Locomotive.buildTrains()        
    }

    override func tearDown() {
        super.tearDown()
        self.locomotives.removeAll()
    }

    // MARK: Locomotive Tests
    
    /// Verifies that the total number of locomotives built matches the expected count from GameRules
    func testLocomotiveCount() {
        let count = locomotives.count
        let expected = GameRules.Locomotives.total
        XCTAssertEqual(count, expected, "Expected \(expected) locomotives, but got \(count)")
    }
    
    /// Verifies that the combined dicePool from all locomotives matches the expected total
    /// This ensures that the game's difficulty/progression curve is maintained across all locomotives
    func testDicePoolTotal() {
        // Sum all dicePool values from each locomotive using reduce
        let totalDicePool = locomotives.reduce(0) { sum, locomotive in
            sum + locomotive.dicePool
        }
        
        // Verify the total matches the expected value from GameRules
        let expected = GameRules.Locomotives.expectedDicePoolTotal
        XCTAssertEqual(totalDicePool, expected, 
                      "Expected total dicePool of \(expected), but got \(totalDicePool)")
    }
    
    /// Verifies that all expected locomotives are created with the correct properties
    /// This test ensures buildTrains() creates valid locomotive data matching GameRules specifications
    func testAllLocomotivesPresent() {
        // Verify we have exactly the expected number of locomotives
        XCTAssertEqual(locomotives.count, GameRules.Locomotives.total,
                      "Should have exactly \(GameRules.Locomotives.total) locomotives")
        
        // Verify each locomotive has a unique ID from 1 to 14
        let ids = Set(locomotives.map { $0.id })
        XCTAssertEqual(ids.count, GameRules.Locomotives.total,
                      "All locomotive IDs should be unique")
        XCTAssertEqual(ids, Set(1...GameRules.Locomotives.total),
                      "Locomotive IDs should range from 1 to \(GameRules.Locomotives.total)")
        
        // Verify each locomotive has a non-empty name
        for locomotive in locomotives {
            XCTAssertFalse(locomotive.name.isEmpty, 
                          "Locomotive \(locomotive.id) should have a non-empty name")
        }
        
        // Verify each locomotive has valid dicePool value (> 0)
        for locomotive in locomotives {
            XCTAssertGreaterThan(locomotive.dicePool, 0,
                               "Locomotive \(locomotive.id) (\(locomotive.name)) should have dicePool > 0")
        }
        
        // Verify each locomotive has a valid generation
        for locomotive in locomotives {
            XCTAssertNotNil(Generation(rawValue: locomotive.generation.rawValue),
                          "Locomotive \(locomotive.id) should have a valid generation")
        }
        
        // Verify each locomotive has a valid colour
        for locomotive in locomotives {
            XCTAssertTrue(LocomotiveColor.allCases.contains(locomotive.colour),
                         "Locomotive \(locomotive.id) should have a valid colour")
        }
    }
    
    func testAgeAdvancesRustWithoutGoingPastObsolete() {
        let locomotive = Locomotive(id: 999, name: "Test", generation: .first, colour: .green, cost: 1, trainPool: 1, dicePool: 1, rust: .unavailable)
        
        locomotive.age()
        XCTAssertEqual(locomotive.rust, .new)
        
        locomotive.age()
        XCTAssertEqual(locomotive.rust, .ageing)
        
        locomotive.age()
        XCTAssertEqual(locomotive.rust, .obsolete)
        
        locomotive.age()
        XCTAssertEqual(locomotive.rust, .obsolete)
    }
    
}
