import XCTest

@testable import Werks

final class TurnOrderTests: XCTestCase {
    func test_turnOrderManager_advancesToNextPlayer() {
        let players = [
            Player(playerId: 1, avatar: "Red"),
            Player(playerId: 2, avatar: "Blue"),
            Player(playerId: 3, avatar: "Green")
        ]
        let manager = TurnOrderManager(players: players)

        XCTAssertEqual(manager.currentPlayer?.playerId, 1)
        XCTAssertEqual(manager.nextPlayer()?.playerId, 2)

        manager.moveToNextPlayer()
        XCTAssertEqual(manager.currentPlayer?.playerId, 2)

        manager.moveToNextPlayer()
        XCTAssertEqual(manager.currentPlayer?.playerId, 3)

        manager.moveToNextPlayer()
        XCTAssertEqual(manager.currentPlayer?.playerId, 1)
    }

    func test_turnOrderManager_returnsNilWhenNoPlayers() {
        let manager = TurnOrderManager(players: [])

        XCTAssertNil(manager.currentPlayer)
        XCTAssertNil(manager.nextPlayer())

        manager.moveToNextPlayer()
        XCTAssertNil(manager.currentPlayer)
    }
}