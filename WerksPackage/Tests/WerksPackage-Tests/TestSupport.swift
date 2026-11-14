//
//  TestSupport.swift
//  werks-package
//
//  Created by AD on 14/11/2026.
//

import XCTest
@testable import WerksPackage

// A collection of helper functions for testing

enum Fixture {
    static func seats(_ count: Int) -> [PlayerSetup] {
        (0..<count).map { PlayerSetup(name: "P\($0)") }
    }

    /// A blank, fully controlled state: fixed turn order 0..<n, untouched
    /// board, empty hands, everyone holding `coins`, in `phase`.
    static func blank(players count: Int = 3, coins: Int = 100, phase: GamePhase = .development,
                      rules: GameRules = .standard, seed: UInt64 = 1) -> GameState {
        let players = (0..<count).map { Player(id: $0, name: "P\($0)") }
        var state = GameState(rules: rules, players: players,
                              bank: Bank(balances: Array(repeating: coins, count: count)),
                              turnOrder: Array(0..<count), board: GameBoard(),
                              rng: SeededRandomNumberGenerator(seed: seed))
        state.phase = phase
        return state
    }
}

// A collection of helper functions for testing on game state
extension GameState {
    /// Test helper: hand a card with `units` to a player.
    mutating func give(_ playerID: Int, _ locomotiveID: Int, units: Int = 1) {
        try! players[playerID].hand.add(LocomotiveCard(locomotiveID: locomotiveID, units: units))
    }

    /// Test helper: replace a player's balance (opens a fresh Bank).
    mutating func setCoins(_ playerID: Int, _ amount: Int) {
        var balances = bank.balances
        balances[playerID] = amount
        bank = Bank(balances: balances)
    }

    /// Test helper: put dice on a space and mark it available.
    mutating func setOrders(_ id: Int, existing: [Int] = [], filled: [Int] = []) {
        board[id].existingOrders = existing
        board[id].filledOrders = filled
        if board[id].rust == .unavailable { board[id].rust = .available }
    }

    /// Test helper: a player's units (on card) for a locomotive.
    func units(_ playerID: Int, _ locomotiveID: Int) -> Int? {
        players[playerID].hand.card(locomotiveID)?.production.units
    }
}

/// Applies an action and returns only the new state.
func apply(_ action: GameAction, to state: GameState) throws -> GameState {
    try GameEngine.apply(action, to: state).state
}

/// Just the `.sold` events.
func sales(in events: [GameEvent]) -> [GameEvent] {
    events.filter { if case .sold = $0 { true } else { false } }
}

/// Just the Bank receipts.
func receipts(in events: [GameEvent]) -> [BankTransaction] {
    events.compactMap { if case let .transaction(receipt) = $0 { receipt } else { nil } }
}

/// Asserts that an action fails with a specific error.
func XCTAssertRejects(_ action: GameAction, in state: GameState, with expected: GameError,
                      file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertThrowsError(try GameEngine.apply(action, to: state), file: file, line: line) { error in
        XCTAssertEqual(error as? GameError, expected, file: file, line: line)
    }
}



/// Asserts that a throwing expression fails with a specific `GameError`.
func XCTAssertGameError<T>(_ expression: @autoclosure () throws -> T, _ expected: GameError,
                           file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { error in
        XCTAssertEqual(error as? GameError, expected, file: file, line: line)
    }
}
