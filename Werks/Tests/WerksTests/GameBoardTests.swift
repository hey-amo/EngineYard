//
//  GameBoardTests.swift
//  Werks
//
//  Created by Amarjit on 09/06/2026.
//

import XCTest

@testable import Werks

// Test gameboard creation

final class GameBoardTests: XCTestCase {

    private var gameBoard: GameBoard!
    
    override func setUp() async throws {
        try await super.setUp()
        gameBoard = GameBoard()
    }

    override func tearDown() {
        super.tearDown()
        gameBoard = nil
    }

    // MARK: - Card Creation Tests
    
    /// Verifies that exactly 43 cards are created from all locomotives
    func testTotalCardCount() {
        let expected = GameRules.Cards.total
        XCTAssertEqual(gameBoard.cardCount, expected,
                      "Expected \(expected) cards to be created, but got \(gameBoard.cardCount)")
    }
    
    /// Verifies that each locomotive creates the correct number of cards based on its trainPool
    func testCardsPerLocomotive() {
        for locomotive in gameBoard.spaces {
            let cardsForLoco = gameBoard.cards.filter { $0.locomotiveID == locomotive.id }
            XCTAssertEqual(cardsForLoco.count, locomotive.trainPool,
                          "Locomotive \(locomotive.id) (\(locomotive.name)) should have \(locomotive.trainPool) cards, but got \(cardsForLoco.count)")
        }
    }
    
    /// Verifies that all cards have unique IDs
    func testCardIDsAreUnique() {
        let cardIDs = gameBoard.cards.map { $0.id }
        let uniqueIDs = Set(cardIDs)
        XCTAssertEqual(cardIDs.count, uniqueIDs.count,
                      "All card IDs should be unique, but found duplicates")
    }
    
    /// Verifies that card IDs are sequential from 1 to 43
    func testCardIDsAreSequential() {
        let cardIDs = gameBoard.cards.map { $0.id }.sorted()
        let expected = Array(1...GameRules.Cards.total)
        XCTAssertEqual(cardIDs, expected,
                      "Card IDs should be sequential from 1 to \(GameRules.Cards.total)")
    }
    
    /// Verifies that all cards reference valid locomotive IDs
    func testCardsReferenceValidLocomotives() {
        let validLocoIDs = Set(gameBoard.spaces.map { $0.id })
        
        for card in gameBoard.cards {
            XCTAssertTrue(validLocoIDs.contains(card.locomotiveID),
                         "Card \(card.id) references invalid locomotiveID \(card.locomotiveID)")
        }
    }
    
    // MARK: - Card Distribution by Color Tests
    
    /// Verifies that cards are distributed across colors according to GameRules.Cards.totals
    func testCardCountByColor() {
        let expectedCounts = GameRules.Cards.totals
        
        for (color, expectedCount) in expectedCounts {
            let cardsForColor = gameBoard.cards.filter { card in
                if let locomotive = gameBoard.spaces.first(where: { $0.id == card.locomotiveID }) {
                    return locomotive.colour == color
                }
                return false
            }
            
            XCTAssertEqual(cardsForColor.count, expectedCount,
                          "Color \(color.description) should have \(expectedCount) cards, but got \(cardsForColor.count)")
        }
    }
    
    /// Verifies that cards are distributed by color AND generation according to GameRules.Testing
    func testCardCountByColorAndGeneration() {
        for (color, generationExpectations) in GameRules.Testing.expectedGenerationsForLivery {
            for expectation in generationExpectations {
                let generation = Generation(rawValue: expectation.generation) ?? .first
                
                let cardsForColorAndGen = gameBoard.cards.filter { card in
                    if let locomotive = gameBoard.spaces.first(where: { $0.id == card.locomotiveID }) {
                        return locomotive.colour == color && locomotive.generation == generation
                    }
                    return false
                }
                
                XCTAssertEqual(cardsForColorAndGen.count, expectation.count,
                              "Color \(color.description) generation \(expectation.generation) should have \(expectation.count) cards, but got \(cardsForColorAndGen.count)")
            }
        }
    }
    
    // MARK: - Helper Tests
    
    /// Verifies that getLocomotiveWithCards returns correct data
    func testGetLocomotiveWithCards() {
        // Test with a valid locomotive
        if let result = gameBoard.getLocomotiveWithCards(for: 1) {
            XCTAssertEqual(result.locomotive.id, 1)
            XCTAssertEqual(result.cards.count, result.locomotive.trainPool,
                          "Returned cards should match locomotive's trainPool")
            
            for card in result.cards {
                XCTAssertEqual(card.locomotiveID, 1,
                              "All returned cards should reference locomotive ID 1")
            }
        } else {
            XCTFail("Should be able to retrieve locomotive 1 with cards")
        }
    }
    
    /// Verifies that getLocomotiveWithCards returns nil for invalid locomotive
    func testGetLocomotiveWithCardsInvalid() {
        let result = gameBoard.getLocomotiveWithCards(for: 999)
        XCTAssertNil(result, "Should return nil for non-existent locomotive")
    }

}
