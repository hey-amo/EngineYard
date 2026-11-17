# Sales Test Specification with Dice Logging

## Overview

**Test Name:** `testSingleLocomotiveSaleRoundWithDiceLogging`
**File:** `Tests/WerksPackage-Tests/Sales/ProductionPhaseTests.swift`
**Purpose:** Trace a complete sale round for ONE locomotive, logging all dice transitions

---

## Test Structure

### Phase 1: Setup
```swift
func testSingleLocomotiveSaleRoundWithDiceLogging() throws {
    var state = Fixture.blank(players: 3, phase: .production)
    
    // Configure board for Green 1st (ID 1)
    state.setOrders(1, existing: [4, 1])  // Two dice showing 4 and 1
    
    // Give players ownership and units
    state.give(0, 1, units: 3)  // Player 0: 3 units
    state.give(1, 1, units: 1)  // Player 1: 1 unit
    state.give(2, 1, units: 2)  // Player 2: 2 units
    
    // Initial state log
    printHeader("=== SALES ROUND START ===")
    printBoardState(state, locomotiveID: 1)
    printPlayerInventory(state, locomotiveID: 1)
}
```

### Phase 2: Execute Production
```swift
    // Resolution happens here
    let result = try GameEngine.apply(.resolvePhase, to: state)
    
    // Intercept and log sales decisions as they happen
    for event in result.events {
        if case let .sold(playerID, locID, units, saleCase) = event {
            printSaleDecision(playerID: playerID, units: units, saleCase: saleCase)
        }
    }
```

### Phase 3: Verify Dice Transitions
```swift
    // After sales, dice should be moved to filledOrders
    printHeader("=== AFTER ROUND 1 ===")
    printBoardState(result.state, locomotiveID: 1)
    
    // Assertions
    XCTAssertEqual(result.state.board[1].existingOrders, [1])
    XCTAssertEqual(result.state.board[1].filledOrders, [4, 1])
}
```

---

## Console Output Design

### Header Format
```
╔════════════════════════════════════════════════════════════╗
║                  SALES ROUND START                         ║
╚════════════════════════════════════════════════════════════╝
```

### Board State Snapshot
```
[BOARD STATE] Green 1st (ID: 1)
  Existing Orders (demand): [4, 1]        [Total dice: 2]
  Filled Orders (sold):     []            [Total dice: 0]
  Initial Order:            nil
  Cards available:          3
  Status:                   available

[MARKET DEMAND]
  - Order to fill: 4 units (from highest die)
  - Then: 1 unit (from second die)
  - Total demand: 5 units
```

### Player Inventory
```
[PLAYERS] Locomotive 1 (Green 1st, Income: 2 coins/unit)
  Player 0: 3 units [available]
  Player 1: 1 unit  [available]
  Player 2: 2 units [available]
  ────────────────────────────────
  Total supply: 6 units
  Total demand: 5 units
  → Shortage: -1 unit (1 unit will remain unsold)
```

### Sale Decision Log (Per Player Turn)
```
[ROUND 1] Turn order: [0, 1, 2]
────────────────────────────────────

[TURN 1] Player 0 (has 3 units)
  Decision: Offered 3, Demanded [4, 1]
  → Case: LOWER_NUMBER (offered < max demand)
  → Action: Sell ALL 3 units
  → Price: 3 units × 2 coins = 6 coins
  → Dice transition: [4, 1] → (reduce by 3) → [1, 1]
  → Filled: (move satisfied die) → [4]
  ✓ SOLD: 3 units, +6 coins → P0 balance: 106

[TURN 2] Player 1 (has 1 unit)
  Decision: Offered 1, Demanded [1, 1]
  → Case: SAME_NUMBER (exact match exists)
  → Action: FORCED to sell exactly 1
  → Price: 1 unit × 2 coins = 2 coins
  → Dice transition: [1, 1] → (move die to filled) → [1]
  ✓ SOLD: 1 unit, +2 coins → P1 balance: 102

[TURN 3] Player 2 (has 2 units)
  Decision: Offered 2, Demanded [1]
  → Case: LARGER_NUMBER (offered > max demand)
  → Action: Sell MAX demand only (1 unit)
  → Price: 1 unit × 2 coins = 2 coins
  → Dice transition: [1] → (move die to filled) → []
  ✓ SOLD: 1 unit, +2 coins → P2 balance: 102

[END OF ROUND 1]
  Unsold inventory: Player 2 has 1 remaining unit
  ──────────────────────────────
  Existing Orders: []      [all satisfied → move to filled]
  Filled Orders:   [4, 1]  [sold in this round]
```

### Dice Flow Diagram
```
[DICE FLOW] Green 1st Locomotive (ID: 1)
────────────────────────────────────────

BEFORE:
  Initial:  nil
  Existing: [4, 1]
  Filled:   []

AFTER PLAYER 0:
  Existing: [1, 1]  ← reduced by 3 (sale amount)
  Filled:   [4]     ← die fully satisfied

AFTER PLAYER 1:
  Existing: [1]     ← reduced by 1 (sale amount)
  Filled:   [4, 1]  ← die fully satisfied

AFTER PLAYER 2:
  Existing: []      ← reduced by 1 (sale amount)
  Filled:   [4, 1]  ← die fully satisfied

ROUND 2 (if continues):
  No more demand, stop
```

---

## Implementation Details

### Logging Helpers (Add to TestSupport or new SalesTestLogging.swift)

```swift
/// Print formatted header
func printHeader(_ title: String) {
    print("\n╔" + String(repeating: "═", count: 58) + "╗")
    let padding = (60 - title.count) / 2
    print("║" + String(repeating: " ", count: padding) + title + 
          String(repeating: " ", count: 60 - padding - title.count) + "║")
    print("╚" + String(repeating: "═", count: 58) + "╝")
}

/// Print current board state for a locomotive
func printBoardState(_ state: GameState, locomotiveID: Int) {
    let space = state.board[locomotiveID]
    print("""
    [BOARD STATE] \(space.definition.name) (ID: \(locomotiveID))
      Existing Orders: \(space.existingOrders)     [Total: \(space.existingOrders.count)]
      Filled Orders:   \(space.filledOrders)       [Total: \(space.filledOrders.count)]
      Initial Order:   \(space.initialOrder.map(String.init) ?? "nil")
      Status:          \(space.rust)
    """)
}

/// Print player inventory for a locomotive
func printPlayerInventory(_ state: GameState, locomotiveID: Int) {
    let income = state.board[locomotiveID].definition.income
    print("[PLAYERS] Locomotive \(locomotiveID)")
    for (playerID, player) in state.players.enumerated() {
        let units = player.hand.card(locomotiveID)?.production.units ?? 0
        let spent = player.hand.card(locomotiveID)?.production.spentUnits ?? 0
        print("  Player \(playerID): \(units) units (spent: \(spent))")
    }
    print("  → Income per unit: \(income) coins")
}

/// Print a single sale decision
func printSaleDecision(playerID: Int, units: Int, saleCase: String) {
    let emoji = saleCase == "same" ? "✓" : "→"
    print("\(emoji) SALE: Player \(playerID) sold \(units) units (\(saleCase))")
}
```

---

## Full Test Example

```swift
func testSingleLocomotiveSaleRoundWithDiceLogging() throws {
    var state = Fixture.blank(players: 3, phase: .production)
    
    // Setup Green 1st with controlled demand
    state.setOrders(1, existing: [4, 1])
    state.give(0, 1, units: 3)
    state.give(1, 1, units: 1)
    state.give(2, 1, units: 2)
    
    printHeader("SALES ROUND: Green 1st (ID: 1)")
    printBoardState(state, locomotiveID: 1)
    printPlayerInventory(state, locomotiveID: 1)
    
    // Execute
    let result = try GameEngine.apply(.resolvePhase, to: state)
    
    // Log sales decisions
    print("\n[SALES DECISIONS]")
    for event in result.events {
        if case let .sold(playerID, locID, units, saleCase) = event, locID == 1 {
            print("  → Player \(playerID): \(units) units (\(saleCase.description))")
        }
    }
    
    // Final state
    printHeader("AFTER PRODUCTION")
    printBoardState(result.state, locomotiveID: 1)
    
    // Assertions
    XCTAssertEqual(result.state.board[1].existingOrders, [1])
    XCTAssertEqual(result.state.board[1].filledOrders, [4, 1])
    XCTAssertEqual(result.state.coins(of: 0), 106)
    XCTAssertEqual(result.state.coins(of: 1), 102)
    XCTAssertEqual(result.state.coins(of: 2), 102)
}
```

---

## Additional Multi-Round Test

For a more complex scenario:

```swift
func testMultiRoundSalesWithDiceTransitions() throws {
    var state = Fixture.blank(players: 2, phase: .production)
    
    // Setup with high demand
    state.setOrders(1, existing: [6, 1])
    state.give(0, 1, units: 4)
    state.give(1, 1, units: 4)
    
    printHeader("MULTI-ROUND SALES TEST")
    printBoardState(state, locomotiveID: 1)
    
    let result = try GameEngine.apply(.resolvePhase, to: state)
    
    // Verify multiple rounds happened
    let salesEvents = result.events.filter { event in
        if case .sold = event { return true } else { return false }
    }
    XCTAssertGreaterThan(salesEvents.count, 2, "Should have multiple sale rounds")
    
    printHeader("FINAL DICE STATE")
    print("""
    Expected:
      - Both 6 and 1 should be moved to filledOrders
      - existingOrders should be empty
      
    Actual:
      Existing: \(result.state.board[1].existingOrders)
      Filled:   \(result.state.board[1].filledOrders)
    """)
    
    XCTAssertTrue(result.state.board[1].existingOrders.isEmpty)
    XCTAssertEqual(result.state.board[1].filledOrders.count, 2)
}
```

---

## What This Tests

✅ **Dice Movement:**
- Initial board state visibility
- Dice reduction as sales happen
- Proper transition to filledOrders

✅ **Sale Decisions:**
- Case detection (same/lower/larger) is logged
- Each player's turn order is clear
- Unit calculations are transparent

✅ **Board State Consistency:**
- No dice lost or duplicated
- Existing → Filled transitions correct
- Final state matches assertions

✅ **Debugging:**
- Console output shows exact progression
- Easy to spot where logic breaks
- Great for explaining rules to non-devs

---

## Related Task

This test design complements **[fix-dice-transfer-manager-2]** which would centralize all dice transitions.

