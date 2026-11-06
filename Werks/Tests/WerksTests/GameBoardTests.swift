import XCTest
@testable import Werks

final class GameBoardTests: XCTestCase {
    func testBoardStartsWithAllSpacesInFixedManifestOrder() {
        let board = GameBoard()

        XCTAssertEqual(board.spaces.map(\.id), Array(1...14).map(UInt.init))
        XCTAssertEqual(board.spaces.map(\.definition.name), LocomotiveDefinition.buildAll().map(\.name))
        XCTAssertTrue(board.spaces.allSatisfy {
            $0.state.availableCardCount == $0.definition.totalCardCount &&
            $0.state.initialOrder == nil &&
            $0.state.existingOrders.isEmpty &&
            $0.state.filledOrders.isEmpty &&
            $0.state.rust == .unavailable
        })
    }

    func testInitialOrderAcceptsOnlyD6AndCanOnlyBeSetOnce() throws {
        var board = GameBoard()

        try board.setInitialOrder(6, for: 1)

        XCTAssertEqual(board.spaces[0].state.initialOrder, 6)
        XCTAssertEqual(board.spaces[0].state.rust, .active)
        XCTAssertThrowsError(try board.setInitialOrder(3, for: 1)) {
            XCTAssertEqual($0 as? GameBoardError, .initialOrderAlreadySet)
        }
        XCTAssertThrowsError(try board.setInitialOrder(7, for: 2)) {
            XCTAssertEqual($0 as? GameBoardError, .invalidDieValue)
        }
        XCTAssertThrowsError(try board.setInitialOrder(0, for: 2)) {
            XCTAssertEqual($0 as? GameBoardError, .invalidDieValue)
        }
    }

    func testExistingAndFilledOrdersShareDicePoolCapacity() throws {
        var board = GameBoard()

        try board.addExistingOrder(2, for: 1)
        try board.addFilledOrder(5, for: 1)
        try board.addExistingOrder(3, for: 1)

        XCTAssertEqual(board.spaces[0].state.existingOrders, [2, 3])
        XCTAssertEqual(board.spaces[0].state.filledOrders, [5])
        XCTAssertThrowsError(try board.addFilledOrder(1, for: 1)) {
            XCTAssertEqual($0 as? GameBoardError, .orderCapacityExceeded)
        }
        XCTAssertThrowsError(try board.addExistingOrder(8, for: 1)) {
            XCTAssertEqual($0 as? GameBoardError, .invalidDieValue)
        }

        XCTAssertEqual(board.spaces[0].state.existingOrders, [2, 3])
        XCTAssertEqual(board.spaces[0].state.filledOrders, [5])
    }

    func testEverySpaceEnforcesItsOwnDicePool() throws {
        var board = GameBoard()

        for space in board.spaces {
            for die in 1...space.definition.dicePool {
                try board.addExistingOrder(die, for: space.id)
            }

            XCTAssertThrowsError(try board.addFilledOrder(1, for: space.id)) {
                XCTAssertEqual($0 as? GameBoardError, .orderCapacityExceeded)
            }
        }
    }

    func testInitialOrderIsOutsideCapacityUntilDevelopmentTransfersIt() throws {
        var board = GameBoard()

        try board.addExistingOrder(1, for: 1)
        try board.addFilledOrder(2, for: 1)
        try board.setInitialOrder(6, for: 1)

        _ = try board.developLocomotive(1)

        XCTAssertNil(board.spaces[0].state.initialOrder)
        XCTAssertEqual(board.spaces[0].state.existingOrders, [1, 6])
        XCTAssertEqual(board.spaces[0].state.filledOrders, [2])
    }

    func testFailedDevelopmentDoesNotPartiallyMutateSpace() throws {
        var board = GameBoard()
        try board.setInitialOrder(4, for: 1)
        try board.addExistingOrder(2, for: 1)
        try board.addExistingOrder(3, for: 1)
        try board.addFilledOrder(5, for: 1)

        XCTAssertThrowsError(try board.developLocomotive(1)) {
            XCTAssertEqual($0 as? GameBoardError, .orderCapacityExceeded)
        }

        XCTAssertEqual(board.spaces[0].state.availableCardCount, 4)
        XCTAssertEqual(board.spaces[0].state.initialOrder, 4)
        XCTAssertEqual(board.spaces[0].state.existingOrders, [2, 3])
        XCTAssertEqual(board.spaces[0].state.filledOrders, [5])
    }

    func testDevelopmentConsumesCardsWithoutChangingDefinitionOrPosition() throws {
        var board = GameBoard()
        try board.setInitialOrder(4, for: 1)
        let originalIDs = board.spaces.map(\.id)
        let originalDefinition = board.spaces[0].definition

        for expectedAvailableCount in (0..<4).reversed() {
            XCTAssertEqual(try board.developLocomotive(1), originalDefinition)
            XCTAssertEqual(board.spaces[0].state.availableCardCount, expectedAvailableCount)
        }

        XCTAssertThrowsError(try board.developLocomotive(1)) {
            XCTAssertEqual($0 as? GameBoardError, .noCardsAvailable)
        }
        XCTAssertEqual(board.spaces[0].definition, originalDefinition)
        XCTAssertEqual(board.spaces.map(\.id), originalIDs)
    }

    func testDevelopmentRequiresMarketDemand() {
        var board = GameBoard()

        XCTAssertThrowsError(try board.developLocomotive(1)) {
            XCTAssertEqual($0 as? GameBoardError, .noMarketDemand)
        }
        XCTAssertEqual(board.spaces[0].state.availableCardCount, 4)
    }

    func testObsoleteSpaceRemainsInPlaceAndCannotBeUsed() throws {
        var board = GameBoard()
        try board.setInitialOrder(3, for: 1)

        try board.markObsolete(1)

        XCTAssertEqual(board.spaces.count, 14)
        XCTAssertEqual(board.spaces[0].id, 1)
        XCTAssertEqual(board.spaces[0].state.rust, .obsolete)
        XCTAssertEqual(board.spaces[0].state.availableCardCount, 0)
        XCTAssertNil(board.spaces[0].state.initialOrder)
        XCTAssertThrowsError(try board.setInitialOrder(2, for: 1)) {
            XCTAssertEqual($0 as? GameBoardError, .spaceUnavailable)
        }
        XCTAssertThrowsError(try board.developLocomotive(1)) {
            XCTAssertEqual($0 as? GameBoardError, .spaceUnavailable)
        }
    }

    func testRustStatusTransitionsDoNotChangeSpaceIdentity() throws {
        var board = GameBoard()
        try board.addExistingOrder(2, for: 1)
        try board.markRusting(1)
        try board.addExistingOrder(4, for: 1)

        XCTAssertEqual(board.spaces[0].state.rust, .rusting)
        XCTAssertEqual(board.spaces[0].state.existingOrders, [2, 4])

        try board.markObsolete(1)

        XCTAssertEqual(board.spaces[0].id, 1)
        XCTAssertEqual(board.spaces[0].state.rust, .obsolete)
        XCTAssertTrue(board.spaces[0].state.existingOrders.isEmpty)
    }

    func testUnknownLocomotiveIDIsRejected() {
        var board = GameBoard()

        XCTAssertThrowsError(try board.addExistingOrder(2, for: 99)) {
            XCTAssertEqual($0 as? GameBoardError, .spaceNotFound)
        }
    }

    func testGameSessionOwnsBoardAndPlayerMembership() async throws {
        let session = GameSession()
        let playerID = UUID()
        let player = Player(id: playerID, coins: 12)

        try await session.addPlayer(player)
        let playerIDs = await session.playerIDs()
        XCTAssertEqual(playerIDs, [playerID])

        await XCTAssertThrowsErrorAsync(try await session.addPlayer(player)) {
            XCTAssertEqual($0 as? GameSessionError, .duplicatePlayer)
        }

        try await session.setInitialOrder(5, for: 2)
        let card = try await session.developLocomotive(2, for: playerID)
        let hand = try await session.playerHand(for: playerID)
        let spaces = await session.boardSnapshot()
        let cardLocomotiveID = await card.locomotiveID
        let cardState = await card.state

        XCTAssertEqual(spaces.count, 14)
        XCTAssertNil(spaces[1].state.initialOrder)
        XCTAssertEqual(spaces[1].state.existingOrders, [5])
        XCTAssertEqual(spaces[1].state.availableCardCount, 2)
        XCTAssertEqual(spaces[1].state.rust, .active)
        XCTAssertEqual(hand.count, 1)
        XCTAssertEqual(cardLocomotiveID, 2)
        XCTAssertEqual(cardState, .owned)

        await XCTAssertThrowsErrorAsync(try await session.developLocomotive(2, for: playerID)) {
            XCTAssertEqual($0 as? GameSessionError, .alreadyOwnsLocomotive)
        }
        let boardAfterFailedDevelopment = await session.boardSnapshot()
        let handAfterFailedDevelopment = try await session.playerHand(for: playerID)
        XCTAssertEqual(boardAfterFailedDevelopment[1].state.availableCardCount, 2)
        XCTAssertEqual(handAfterFailedDevelopment.count, 1)
    }

    func testFailedSessionDevelopmentLeavesBoardAndHandUnchanged() async throws {
        let session = GameSession()
        let playerID = UUID()
        try await session.addPlayer(Player(id: playerID, coins: 12))

        try await session.setInitialOrder(6, for: 2)
        try await session.addExistingOrder(1, for: 2)
        try await session.addExistingOrder(2, for: 2)
        try await session.addFilledOrder(3, for: 2)

        await XCTAssertThrowsErrorAsync(
            try await session.developLocomotive(2, for: playerID)
        ) {
            XCTAssertEqual($0 as? GameBoardError, .orderCapacityExceeded)
        }

        let spaces = await session.boardSnapshot()
        let hand = try await session.playerHand(for: playerID)
        XCTAssertEqual(spaces[1].state.availableCardCount, 3)
        XCTAssertEqual(spaces[1].state.initialOrder, 6)
        XCTAssertEqual(spaces[1].state.existingOrders, [1, 2])
        XCTAssertEqual(spaces[1].state.filledOrders, [3])
        XCTAssertTrue(hand.isEmpty)
    }

    func testUnknownPlayerCannotDevelopLocomotive() async throws {
        let session = GameSession()

        await XCTAssertThrowsErrorAsync(
            try await session.developLocomotive(1, for: UUID())
        ) {
            XCTAssertEqual($0 as? GameSessionError, .playerNotFound)
        }

        let spaces = await session.boardSnapshot()
        XCTAssertEqual(spaces[0].state.availableCardCount, 4)
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}