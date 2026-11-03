//
//  GameMessageTests.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest
@testable import Werks

final class GameMessageTests: XCTestCase {
    func testAddAndGetMessagesReturnsNewestFirstWithMessageTypes() {
        var log = GameLog()
        let older = GameMessage(
            date: Date(timeIntervalSince1970: 1),
            message: "Started",
            messageType: .info
        )
        let newer = GameMessage(
            date: Date(timeIntervalSince1970: 2),
            message: "Purchase failed",
            messageType: .error
        )

        log.add(message: older)
        log.add(message: newer)

        XCTAssertEqual(log.showLatestMessages, [newer, older])
        XCTAssertEqual(log.showLatestMessages.map(\.messageType), [.error, .info])
    }

    func testMessageTypesArePreserved() {
        var log = GameLog()
        let types: [GameMessageType] = [.info, .warning, .success, .error]

        for (index, type) in types.enumerated() {
            log.add(message: GameMessage(
                date: Date(timeIntervalSince1970: TimeInterval(index)),
                message: "\(type)",
                messageType: type
            ))
        }

        XCTAssertEqual(Set(log.showLatestMessages.map(\.messageType)), Set(types))
    }

    func testClearLogRemovesAllMessages() {
        var log = GameLog()
        log.add(message: GameMessage(message: "Round started"))

        log.clearLog()

        XCTAssertTrue(log.showLatestMessages.isEmpty)
    }

    func testMessageLimitKeepsNewest100Messages() {
        var log = GameLog()
        let messages = (0..<101).map { index in
            GameMessage(
                date: Date(timeIntervalSince1970: TimeInterval(index)),
                message: "Message \(index)"
            )
        }

        for message in messages {
            log.add(message: message)
        }

        XCTAssertEqual(log.messageLimit, 100)
        XCTAssertEqual(log.showLatestMessages.count, log.messageLimit)
        XCTAssertEqual(log.showLatestMessages.first?.message, "Message 100")
        XCTAssertFalse(log.showLatestMessages.contains { $0.message == "Message 0" })
    }
}
