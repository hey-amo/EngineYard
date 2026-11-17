//
//  GameStoreTests.swift
//  WerksPackage
//
//

import XCTest
@testable import WerksPackage

final class GameStoreTests: XCTestCase {
    func testSendAppliesAndNotifiesSubscribers() async throws {
        let store = try GameStore(players: Fixture.seats(3), seed: 8)
        let stream = await store.updates()
        var iterator = stream.makeAsyncIterator()

        let initial = await iterator.next()
        XCTAssertNil(initial?.action)

        try await store.send(.pass)
        let update = await iterator.next()
        XCTAssertEqual(update?.action, .pass)
        XCTAssertEqual(update?.state.turnIndex, 1)
        let current = await store.state
        XCTAssertEqual(update?.state, current)
    }

    func testIllegalActionNotifiesNobodyAndChangesNothing() async throws {
        let store = try GameStore(players: Fixture.seats(3), seed: 8)
        let before = await store.state
        do {
            try await store.send(.resolvePhase)
            XCTFail("expected wrongPhase")
        } catch {
            XCTAssertEqual(error as? GameError, .wrongPhase(.development))
        }
        let after = await store.state
        XCTAssertEqual(before, after)
    }

    /// Many concurrent callers: the actor serialises them, so the result is
    /// always a consistent game (each pass accepted exactly once or rejected).
    func testConcurrentSendsAreSerialised() async throws {
        let store = try GameStore(players: Fixture.seats(3), seed: 8)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<6 {
                group.addTask { _ = try? await store.send(.pass) }
            }
        }
        let state = await store.state
        XCTAssertEqual(state.phase, .production, "3 passes per phase × 2 phases")
        let history = await store.game.history
        XCTAssertEqual(history.count, 6)
    }
}
