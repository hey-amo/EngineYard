//
//  GameBoardTests.swift
//  Werks
//
//  Created by Amarjit on 09/06/2026.
//

import XCTest

@testable import Werks

// Test gameboard creation


// MARK: - Private GameBoard Class

/// A temporary private class that holds the entire gameboard with locomotives and their cards
fileprivate class GameBoard {
    let locomotives: [Locomotive]
    var cards: [LocomotiveCard] = []
    
    init() {
        self.locomotives = Locomotive.buildTrains()
        self.createCards()
    }
    
    /// Creates locomotive cards based on each locomotive's trainPool
    private func createCards() {
        var cardID = 1
        
        for locomotive in locomotives {
            // Create trainPool number of cards for this locomotive
            for _ in 0..<locomotive.trainPool {
                let card = LocomotiveCard(id: cardID, locomotiveID: locomotive.id)
                cards.append(card)
                cardID += 1
            }
        }
    }
    
    /// Returns the total number of cards created
    var cardCount: Int {
        return cards.count
    }
    
    /// Returns locomotives grouped by their cards
    func getLocomotiveWithCards(for locomotiveID: Int) -> (locomotive: Locomotive, cards: [LocomotiveCard])? {
        guard let locomotive = locomotives.first(where: { $0.id == locomotiveID }) else {
            return nil
        }
        
        let locomotiveCards = cards.filter { $0.locomotiveID == locomotiveID }
        return (locomotive: locomotive, cards: locomotiveCards)
    }
}

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
        for locomotive in gameBoard.locomotives {
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
        let validLocoIDs = Set(gameBoard.locomotives.map { $0.id })
        
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
                if let locomotive = gameBoard.locomotives.first(where: { $0.id == card.locomotiveID }) {
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
                    if let locomotive = gameBoard.locomotives.first(where: { $0.id == card.locomotiveID }) {
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
