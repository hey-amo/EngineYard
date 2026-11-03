//
//  WinnerTests.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest
@testable import Werks

private class DummyPlayer: Identifiable {
    let ID: Int
    let coins: Int
    init(id: Int, coins: Int) {
        self.ID = id
        self.coins = coins
    }
}

final class WinnerTests: XCTestCase {

    private var dummyPlayers: [DummyPlayer]?
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        dummyPlayers?.removeAll()
        dummyPlayers = nil
    }

    func testOnlyOneWinner() throws {
        let players = [
            DummyPlayer(id: 1, coins: 100), DummyPlayer(id: 2, coins: 125), DummyPlayer.init(id: 3, coins: 330)
        ]
        // sort it by most coins
        // expect player 3 to be the winner
        // expect only 1 player to be the winner
    }

    func testTwoTiedWinners() throws {
        let players = [
            DummyPlayer(id: 1, coins: 100), DummyPlayer(id: 2, coins: 330), DummyPlayer.init(id: 3, coins: 330)
        ]
        // sort it by most coins
        // expect player 2 & 3 to be joint winners
        // expect 2 players to be the joint winners
    }
}
