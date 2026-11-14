//
//  GameEngineTests.swift
//  WerksPackage
//

import XCTest
@testable import WerksPackage

/// Game engine tests
final class GameEngineTests: XCTestCase {
    func testMandatoryPhasesOnlyAllowResolve() {
        for phase in [GamePhase.production, .taxes, .marketDemand] {
            let state = Fixture.blank(phase: phase)
            XCTAssertEqual(GameEngine.legalActions(in: state), [.resolvePhase])
            XCTAssertNil(state.currentPlayerID)
            XCTAssertRejects(.pass, in: state, with: .wrongPhase(phase))
        }
    }

    func testResolveRejectedInPlayerPhases() {
        XCTAssertRejects(.resolvePhase, in: Fixture.blank(phase: .development), with: .wrongPhase(.development))
        XCTAssertRejects(.resolvePhase, in: Fixture.blank(phase: .capacity), with: .wrongPhase(.capacity))
    }

    func testRejectedActionLeavesStateUntouched() {
        let state = Fixture.blank()
        XCTAssertFalse(GameEngine.isLegal(.develop(locomotiveID: 3), in: state))
        XCTAssertEqual(state, Fixture.blank())
    }

    func testCapacityLegalActions() {
        var state = Fixture.blank(phase: .capacity)
        state.setOrders(1, existing: [1])
        state.setOrders(2, existing: [1])
        state.give(0, 1)
        state.give(0, 2)
        XCTAssertEqual(GameEngine.legalActions(in: state), [
            .buyCapacity(locomotiveID: 1, units: 1),
            .buyCapacity(locomotiveID: 2, units: 1),
            .shiftCapacity(from: 1, to: 2, units: 1),
            .pass
        ])
    }

    func testFullRoundPhaseFlow() throws {
        var game = try Werks(players: Fixture.seats(3), seed: 2024)
        for _ in 0..<3 { try game.apply(.pass) }
        XCTAssertEqual(game.state.phase, .capacity)
        for _ in 0..<3 { try game.apply(.pass) }
        XCTAssertEqual(game.state.phase, .production)
        try game.apply(.resolvePhase)
        XCTAssertEqual(game.state.phase, .taxes)
        try game.apply(.resolvePhase)
        XCTAssertEqual(game.state.phase, .marketDemand)
        try game.apply(.resolvePhase)
        XCTAssertEqual(game.state.phase, .development)
        XCTAssertEqual(game.state.round, 2)
    }

    func testCodableRoundTrip() throws {
        var game = try Werks(players: Fixture.seats(4), seed: 77)
        try game.apply(.pass)
        let data = try JSONEncoder().encode(game)
        let decoded = try JSONDecoder().decode(Werks.self, from: data)
        XCTAssertEqual(decoded, game)
    }

    func testReplayReproducesGame() throws {
        let played = try Self.simulate(players: 4, seed: 123, maxActions: 400)
        let replayed = try Werks.replay(players: Fixture.seats(4), seed: 123, actions: played.history)
        XCTAssertEqual(replayed.state, played.state)
        XCTAssertEqual(replayed.log, played.log)
    }

    /// Random legal play across many seeds and table sizes, checking invariants after every step.
    func testRandomPlayKeepsInvariants() throws {
        for seed in UInt64(0)..<20 {
            for players in GameState.playerRange {
                let game = try Self.simulate(players: players, seed: seed, maxActions: 3_000) { state in
                    Self.assertInvariants(state)
                }
                XCTAssertGreaterThan(game.state.round, 1)
            }
        }
    }

    func testGreedyPlayReachesGameOver() throws {
        let game = try Self.simulate(players: 3, seed: 5, maxActions: 100_000, greedy: true) { state in
            Self.assertInvariants(state)
        }
        XCTAssertEqual(game.state.phase, .gameOver)
        XCTAssertFalse(game.state.winners.isEmpty)
        let best = game.state.bank.balances.max()
        XCTAssertGreaterThanOrEqual(best ?? 0, game.state.rules.winningCoins)
        XCTAssertTrue(game.state.winners.allSatisfy { game.state.coins(of: $0) == best })
    }

    // MARK: - Helpers

    /// Plays legal actions. Random mode picks with a seeded RNG; `greedy`
    /// uses a simple sensible strategy (see `greedyAction`).
    static func simulate(players: Int, seed: UInt64, maxActions: Int, greedy: Bool = false,
                         check: (GameState) -> Void = { _ in }) throws -> Werks {
        var game = try Werks(players: Fixture.seats(players), seed: seed)
        var chooser = SeededRandomNumberGenerator(seed: seed &+ 1)
        for _ in 0..<maxActions where !game.state.isGameOver {
            let actions = game.legalActions
            let action: GameAction
            if greedy {
                action = greedyAction(in: game.state, legal: actions)
            } else {
                // Pass ~1/3 of the time so turns end and phases advance.
                let nonPass = actions.filter { $0 != .pass }
                let pool = (nonPass.isEmpty || chooser.next(below: 3) == 0) ? actions : nonPass
                action = pool[chooser.next(below: pool.count)]
            }
            try game.apply(action)
            check(game.state)
        }
        return game
    }

    /// Develop the most advanced locomotive available; buy units on the
    /// newest owned card until they match its total demand; otherwise pass.
    static func greedyAction(in state: GameState, legal: [GameAction]) -> GameAction {
        switch state.phase {
        case .development:
            let ids = legal.compactMap { action -> Int? in
                if case let .develop(id) = action { return id } else { return nil }
            }
            return ids.max().map { .develop(locomotiveID: $0) } ?? .pass
        case .capacity:
            guard let playerID = state.currentPlayerID,
                  let newest = state.players[playerID].hand.cards.last else { return .pass }
            let demand = state.board[newest.locomotiveID].existingOrders.reduce(0, +)
            let buy = GameAction.buyCapacity(locomotiveID: newest.locomotiveID, units: 1)
            return newest.production.units < demand && legal.contains(buy) ? buy : .pass
        default:
            return legal.first ?? .pass
        }
    }

    static func assertInvariants(_ state: GameState, file: StaticString = #filePath, line: UInt = #line) {
        for space in state.board.spaces {
            let definition = space.definition
            XCTAssertLessThanOrEqual(space.diceCount, definition.maxDice, "\(definition.name) dice", file: file, line: line)
            XCTAssertTrue((space.existingOrders + space.filledOrders).allSatisfy { (1...6).contains($0) },
                          "\(definition.name) die faces", file: file, line: line)
            XCTAssertGreaterThanOrEqual(space.availableCardCount, 0, file: file, line: line)
            let owned = state.players.filter { $0.hand.contains(space.id) }.count
            XCTAssertLessThanOrEqual(space.availableCardCount + owned, definition.cardCount, file: file, line: line)
            if space.rust == .obsolete {
                XCTAssertEqual(space.diceCount, 0, file: file, line: line)
                XCTAssertNil(space.initialOrder, file: file, line: line)
            }
        }
        XCTAssertTrue(state.bank.balances.allSatisfy { $0 >= 0 }, file: file, line: line)
        for player in state.players {
            for card in player.hand.cards {
                XCTAssertGreaterThan(card.production.total, 0, file: file, line: line)
                XCTAssertEqual(card.production.spentUnits, 0, "spent units never survive a phase", file: file, line: line)
            }
        }
        XCTAssertEqual(state.turnOrder.sorted(), Array(state.players.indices), file: file, line: line)
    }
}
