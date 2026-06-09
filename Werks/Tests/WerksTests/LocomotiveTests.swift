//
//  LocomotiveTests.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import XCTest

@testable import Werks

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
    
    // MARK: Testing Enum Validation Tests
    
    /// Verifies that locomotives are distributed across colors according to GameRules.Cards.totals
    /// Tests that buildTrains() creates the correct count for each locomotive livery (colour)
    func testLocomotiveCountByColor() {
        // Get the expected counts per color from GameRules.Cards
        let expectedCounts: [LocomotiveColor: Int] = GameRules.Cards.totals
        
        // For each color, count actual locomotives and verify against expected
        for (color, expectedCount) in expectedCounts {
            let actualCount = locomotives.filter { $0.colour == color }.count
            XCTAssertEqual(actualCount, expectedCount,
                          "Color \(color.description) should have \(expectedCount) locomotives, but got \(actualCount)")
        }
    }
    
    /// Verifies that locomotives are distributed by color AND generation according to GameRules.Testing.expectedGenerationsForLivery
    /// This is the primary test against the Testing enum specifications
    func testLocomotiveCountByColorAndGeneration() {
        // Iterate through each color and its expected generation breakdown
        for (color, generationExpectations) in GameRules.Testing.expectedGenerationsForLivery {
            // For each generation, verify the count matches the expectation
            for expectation in generationExpectations {
                let generation = Generation(rawValue: expectation.generation) ?? .first
                
                // Filter locomotives by color AND generation
                let matchingLocomotives = locomotives.filter { locomotive in
                    locomotive.colour == color && locomotive.generation == generation
                }
                
                XCTAssertEqual(matchingLocomotives.count, expectation.count,
                              "Color \(color.description) generation \(expectation.generation) should have \(expectation.count) locomotives, but got \(matchingLocomotives.count)")
            }
        }
    }
    
    /// Comprehensive validation that all locomotives match the Testing enum expectations
    /// Verifies that every locomotive built is accounted for in the expected generation breakdown
    func testAllLocomotivesMatchTestingEnumExpectations() {
        // Count all locomotives expected from the Testing enum
        var totalExpectedFromTesting = 0
        for (_, generationExpectations) in GameRules.Testing.expectedGenerationsForLivery {
            for expectation in generationExpectations {
                totalExpectedFromTesting += expectation.count
            }
        }
        
        // Verify that the actual count matches the total expected
        XCTAssertEqual(locomotives.count, totalExpectedFromTesting,
                      "Total locomotives should match Testing enum expectations: expected \(totalExpectedFromTesting), got \(locomotives.count)")
        
        // Also verify that each actual locomotive has a corresponding entry in the Testing enum
        for locomotive in locomotives {
            let expectedCount = GameRules.Testing.count(for: locomotive.colour, generation: locomotive.generation.rawValue)
            XCTAssertNotNil(expectedCount,
                           "Locomotive \(locomotive.id) (\(locomotive.name)) - \(locomotive.colour.description) Gen\(locomotive.generation.rawValue) - should exist in Testing enum expectations")
        }
    }
    
    /// Validates the distribution of locomotives across all five generations
    /// Ensures each generation contains the locomotives specified by the Testing enum
    func testGenerationDistribution() {
        // Iterate through all possible generations
        for generation in Generation.allCases {
            var expectedCount = 0
            var colorBreakdown = [LocomotiveColor: Int]()
            
            // Calculate expected count for this generation from the Testing enum
            for (color, generationExpectations) in GameRules.Testing.expectedGenerationsForLivery {
                if let count = generationExpectations.first(where: { $0.generation == generation.rawValue })?.count {
                    expectedCount += count
                    colorBreakdown[color] = count
                }
            }
            
            // Count actual locomotives for this generation
            let actualLocomotives = locomotives.filter { $0.generation == generation }
            
            XCTAssertEqual(actualLocomotives.count, expectedCount,
                          "Generation \(generation.description) should have \(expectedCount) locomotives, but got \(actualLocomotives.count)")
        }
    }

}
