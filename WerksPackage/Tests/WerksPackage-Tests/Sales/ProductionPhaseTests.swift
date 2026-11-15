//
//  ProductionPhaseTests.swift
//  WerksPackage
//
//  Created by AD on 15/11/2026.
//

import XCTest
@testable import WerksPackage

// Comprehensive production phase tests with dice logging
final class ProductionPhaseTests: XCTestCase {

    /// Single locomotive sale round with detailed dice transition logging
    func testSingleLocomotiveSaleRoundWithDiceLogging() throws {
        var state = Fixture.blank(players: 3, phase: .production)

        // Setup Green 1st (ID 1) with controlled demand
        state.setOrders(1, existing: [4, 1])
        state.give(0, 1, units: 3)  // Player 0: 3 units
        state.give(1, 1, units: 1)  // Player 1: 1 unit
        state.give(2, 1, units: 2)  // Player 2: 2 units

        printHeader("SALES ROUND: Green 1st (ID: 1)")
        printBoardState(state, locomotiveID: 1)
        printPlayerInventory(state, locomotiveID: 1)

        // Execute production phase
        let result = try GameEngine.apply(.resolvePhase, to: state)

        // Log sales decisions
        print("\n[SALES DECISIONS]")
        var saleCount = 0
        for event in result.events {
            if case let .sold(playerID, locID, units, saleCase) = event, locID == 1 {
                saleCount += 1
                let caseStr = saleCase == .sameNumber ? "SAME" : (saleCase == .lowerNumber ? "LOWER" : "LARGER")
                print("  [\(saleCount)] Player \(playerID): \(units) units (\(caseStr))")
            }
        }

        // Final state
        printHeader("AFTER PRODUCTION")
        printBoardState(result.state, locomotiveID: 1)

        // Verify dice transitions
        XCTAssertEqual(result.state.board[1].existingOrders, [1], "Remaining demand should be 1")
        XCTAssertEqual(result.state.board[1].filledOrders, [4, 1], "Both dice should be filled")
        XCTAssertEqual(result.state.coins(of: 0), 106, "Player 0: 3 units × 2 coins = +6")
        XCTAssertEqual(result.state.coins(of: 1), 102, "Player 1: 1 unit × 2 coins = +2")
        XCTAssertEqual(result.state.coins(of: 2), 102, "Player 2: 1 unit × 2 coins = +2")
    }

    /// Multi-round sales with multiple locomotives
    func testMultiLocomotiveSalesRound() throws {
        var state = Fixture.blank(players: 2, phase: .production)

        // Setup two locomotives
        state.setOrders(1, existing: [3])  // Green 1st
        state.setOrders(2, existing: [2]) // Green 2nd

        state.give(0, 1, units: 2)
        state.give(0, 2, units: 3)
        state.give(1, 1, units: 1)
        state.give(1, 2, units: 1)

        printHeader("MULTI-LOCOMOTIVE SALES TEST")

        let result = try GameEngine.apply(.resolvePhase, to: state)

        // Verify both locomotives were processed
        let soldEvents = result.events.filter { event in
            if case .sold = event { return true } else { return false }
        }
        XCTAssertGreaterThan(soldEvents.count, 0, "Should have multiple sales")

        // Both dice should be fully satisfied
        XCTAssertTrue(result.state.board[1].existingOrders.isEmpty, "Loco 1: all demand satisfied")
        XCTAssertTrue(result.state.board[2].existingOrders.isEmpty, "Loco 2: all demand satisfied")
    }

    /// Verify unsold inventory handling
    func testUnsoldInventoryAfterSales() throws {
        var state = Fixture.blank(players: 1, phase: .production)

        // Setup: demand is 3, player has 5 units
        state.setOrders(1, existing: [3])
        state.give(0, 1, units: 5)

        let result = try GameEngine.apply(.resolvePhase, to: state)

        // Player should have 2 unsold units remaining
        let card = result.state.players[0].hand.card(1)
        XCTAssertEqual(card?.production.units, 2, "Should have 2 unsold units (5 - 3)")
        XCTAssertEqual(result.state.coins(of: 0), 106, "Income: 3 units × 2 coins = +6")
    }
}

// MARK: - Logging Helpers

/// Print formatted header for console output
private func printHeader(_ title: String) {
    print("\n╔" + String(repeating: "═", count: 58) + "╗")
    let padding = (60 - title.count) / 2
    print("║" + String(repeating: " ", count: padding) + title +
          String(repeating: " ", count: 60 - padding - title.count) + "║")
    print("╚" + String(repeating: "═", count: 58) + "╝")
}

/// Print current board state for a locomotive
private func printBoardState(_ state: GameState, locomotiveID: Int) {
    let space = state.board[locomotiveID]
    let name = space.definition.name
    print("""
    [BOARD STATE] \(name) (ID: \(locomotiveID))
      Existing Orders (demand): \(space.existingOrders)     [Total: \(space.existingOrders.count)]
      Filled Orders (sold):     \(space.filledOrders)       [Total: \(space.filledOrders.count)]
      Initial Order:            \(space.initialOrder.map(String.init) ?? "nil")
      Status:                   \(space.rust)
    """)
}

/// Print player inventory for a locomotive
private func printPlayerInventory(_ state: GameState, locomotiveID: Int) {
    let income = state.board[locomotiveID].definition.income
    print("[PLAYERS] Locomotive \(locomotiveID)")
    var totalUnits = 0
    for (playerID, player) in state.players.enumerated() {
        let units = player.hand.card(locomotiveID)?.production.units ?? 0
        print("  Player \(playerID): \(units) units")
        totalUnits += units
    }
    let totalDemand = state.board[locomotiveID].existingOrders.reduce(0, +)
    print("  ────────────────────────────────")
    print("  Total supply: \(totalUnits) units")
    print("  Total demand: \(totalDemand) units")
    print("  → Income per unit: \(income) coins")
}
