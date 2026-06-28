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

    public func testUnlockNextGameSpace() {
        // TBD
    }

    
}
