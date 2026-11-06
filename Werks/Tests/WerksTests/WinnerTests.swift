//
//  WinnerTests.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest
@testable import Werks

private class DummyPlayer: Identifiable {
    let id: Int
    let coins: Int

    init(id: Int, coins: Int) {
        self.id = id
        self.coins = coins
    }
}

final class WinnerTests: XCTestCase {
    func testOnlyOneWinner() throws {
        let players = [
            DummyPlayer(id: 1, coins: 100), DummyPlayer(id: 2, coins: 125), DummyPlayer.init(id: 3, coins: 330)
        ]
        let sortedPlayers = players.sorted { $0.coins > $1.coins }
        let highestCoinTotal = try XCTUnwrap(sortedPlayers.first?.coins)
        let winners = sortedPlayers.filter { $0.coins == highestCoinTotal }

        XCTAssertEqual(sortedPlayers.first?.id, 3)
        XCTAssertEqual(winners.map(\.id), [3])
        XCTAssertEqual(winners.count, 1)
    }

    func testTwoTiedWinners() throws {
        let players = [
            DummyPlayer(id: 1, coins: 100), DummyPlayer(id: 2, coins: 330), DummyPlayer.init(id: 3, coins: 330)
        ]
        let sortedPlayers = players.sorted { $0.coins > $1.coins }
        let highestCoinTotal = try XCTUnwrap(sortedPlayers.first?.coins)
        let winners = sortedPlayers.filter { $0.coins == highestCoinTotal }

        XCTAssertEqual(Set(winners.map(\.id)), [2, 3])
        XCTAssertEqual(winners.count, 2)
    }
}
