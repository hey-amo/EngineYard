import XCTest
@testable import Werks

final class WerksTests: XCTestCase {
    func testMessageHandlerStoresAndClearsMessages() throws {
        let handler = GameMessageHandler()
        let game = Werks(gameStage: .idle, messageHandler: handler)

        let message = GameMessage(message: "Round started")
        game.messageHandler.add(message)

        XCTAssertEqual(game.gameMessages.count, 1)
        XCTAssertEqual(game.gameMessages.first?.message, "Round started")

        game.messageHandler.clear()

        XCTAssertTrue(game.gameMessages.isEmpty)
    }
}
