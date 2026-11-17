# WerksPackage Improvement Suggestions

## Test Coverage Gaps

### 1. **Missing tests for Hand edge cases**
- **File:** Tests should be added to `Player/HandTests.swift`
- **Issue:** No tests verify `Hand` mutation edge cases: what happens when modifying throws during a transaction?
- **Reason:** The `modify` method has a precondition that cards stay in sorted order. Testing ensures the internal invariants are maintained even under partial failure.
- **Suggested test:** Add tests for `modify` failure rollback, and verify cards remain sorted after all mutations.

APPROVED

### 2. **Missing tests for concurrent/sequential development patterns**
- **File:** Should add to `Locomotive/DevelopmentTests.swift`
- **Issue:** Only single development per player is tested. No tests for what happens when MULTIPLE players develop the same type of locomotive in the SAME round.
- **Reason:** Rules state "each player may develop each locomotive only once" but this is per-player. Two players both developing the same locomotive type is legal and should be tested.
- **Suggested tests:** 
  - Player 0 develops Green 1st, then Player 1 develops Green 1st (same round)
  - Verify both get cards and both mark it as developed
  - Verify `hand.hasHeld()` is per-player, not global

APPROVED. This is correct: Multiple players CAN buy from the same deck (assuming its not empty, and assuming they haven't bought it yet)


### 3. **Missing integration test: Full game flow from setup to conclusion**
- **File:** `Game/GameEngineTests.swift` has `testFullRoundPhaseFlow` but it only goes one round
- **Issue:** No test verifies a realistic 2–3 round game where players accumulate wealth strategically
- **Reason:** Helps catch phase transition bugs and unexpected state mutations between rounds
- **Suggested test:** A seeded game that runs until round 2–3 where specific players develop specific locomotives and sell

APPROVED

### 4. **Missing edge-case tests for Market Demand phase with initial dice**
- **File:** `Sales/MarketTests.swift`
- **Issue:** No test covers the scenario where all four locomotive types have only initial dice (no existing/filled orders yet)
- **Reason:** The game rules state "initial die alone is not a generation" but this is only tested once. Need to verify all liveries behave consistently when only initial dice exist.
- **Suggested test:** `testAllLiveriesWithOnlyInitialDiceYieldNoGeneration`


APPROVED

### 5. **Missing tests for GameBoard indexing and space integrity**
- **File:** Should add to `Locomotive/CatalogueTests.swift` or a new `GameBoard` test file
- **Issue:** No tests verify the board spaces are in correct order, have correct definitions, or that space IDs match catalogue indices
- **Reason:** The board is initialized at setup and never changes structure; ensuring it's built correctly prevents silent logic bugs.
- **Suggested test:** Verify all 14 spaces exist, have correct names/colours, cost/income calculations, and maxDice values

APPROVED

### 6. **Missing tests for ProductionUnits state boundaries**
- **File:** `Locomotive/ProductionUnitsTests.swift`
- **Issue:** Only basic tests exist. Missing: what if `reset()` is called when `spentUnits == 0`? What if `units == 0` before `spend()`?
- **Reason:** Production units are a small state machine; boundary conditions often hide bugs.
- **Suggested tests:**
  - `reset()` when already reset (should be idempotent)
  - `spend()` more units than available (should throw)
  - `add()` after `spend()` but before `reset()` (should increase total)

APPROVED.  If you reset:
- spentUnits adds to existing -> Units (ie: Spent: 3, Units: 1.  After reset: Spent: 0, Units: 4 )

### 7. **Missing tests for invalid board state recovery**
- **File:** `Game/GameEngineTests.swift`
- **Issue:** The random play test (`testRandomPlayKeepsInvariants`) is excellent, but only runs ~100 games
- **Reason:** Increasing the seed range and/or game depth would catch rare state mutation bugs earlier
- **Suggested test:** Run the random invariant check across 200+ seeds and 5000+ actions per game

APPROVED

### 8. **Missing test: ActionResult atomicity across all phases**
- **File:** `Game/GameEngineTests.swift`
- **Issue:** Only one test (`testRejectedActionLeavesStateUntouched`) verifies atomicity, and it's in development phase
- **Reason:** Atomicity is critical; if a phase action (Production, Taxes, Market) is rejected halfway through events, it must leave state clean.
- **Suggested test:** Create a failing bank charge scenario in production phase; verify state rolls back cleanly


APPROVED

### 9. **Missing tests for Coins/Bank transaction ordering**
- **File:** `Coins/BankTests.swift`
- **Issue:** Only basic balance checking. No test verifies transaction history ordering or receipt sequencing during complex multi-sale rounds.
- **Reason:** The log is append-only; ensuring receipts are in the order events occurred helps UI rendering and replay correctness.
- **Suggested test:** A multi-player production round where receipts are verified in exact turn order

APPROVED

### 10. **Missing test for Player turn order stability across game state changes**
- **File:** `Player/HandTests.swift` or new test
- **Issue:** No test verifies that a player's ID doesn't shift when hands are mutated, and that the turnOrder array is always consistent
- **Reason:** Turn order is fundamental to game fairness; subtle bugs here are hard to catch visually.
- **Suggested test:** Mutate player hands and verify `turnOrder` still maps to the correct players

APPROVED

---

## Code Improvement Suggestions

### 1. **Add a GameSession abstraction layer**
- **File:** `State/GameSession.swift` (new)
- **Issue:** The `Werks` struct is both the public API and the replay history keeper. Distinguishing concerns improves testability and future persistence.
- **Reason:** Helps with:
  - Separating mutable game state (phase, coins, cards) from immutable metadata (players, rules, seed)
  - Future save/load: serialization can focus on `GameState` without duplicating `history` + `log`
  - Testing: easier to create a "blank" game vs. a "replayed-to-turn-N" game
- **Suggested structure:**
  ```
  struct GameSession: Codable {
      let metadata: GameMetadata  // players, rules, seed
      var game: Werks
      mutating func fast_forward(_ actions: [GameAction]) throws
  }
  struct GameMetadata {
      let players: [PlayerSetup]
      let rules: GameRules
      let seed: UInt64
  }
  ```

APPROVED


### 2. **Extract Catalogue initialization from GameBoard**
- **File:** `Locomotive/Catalogue.swift` already exists; improve `GameBoard.swift`
- **Issue:** The board is a big array of `LocomotiveState`. Computing space definitions happens lazily in each space.
- **Reason:** Improves testability by centralizing board shape/definition logic.
- **Suggested refactor:** Move board setup into a `func buildBoard() -> [LocomotiveState]` helper; verify it at startup

APPROVED


### 3. **Add a GamePhase.isResolvable property**
- **File:** `State/GamePhase.swift`
- **Issue:** Logic like `if phase == .production || phase == .taxes || phase == .marketDemand` is duplicated in GameEngine and tests
- **Reason:** Single source of truth reduces duplication and makes phase invariants explicit.
- **Suggested addition:**
  ```swift
  public var isResolvable: Bool { self == .production || self == .taxes || self == .marketDemand }
  ```

APPROVED

### 4. **Make ValidationResults explicit for complex rules**
- **File:** `Rules/DevelopmentRules.swift`, `Rules/SalesRules.swift`
- **Issue:** Methods like `validateDevelop` throw, making the reason clear in type system, but callers don't know what conditions to check first.
- **Reason:** Better error messages and easier debugging in UI (player feedback).
- **Suggested addition:** Create lightweight `ValidationResult` type that captures all failure reasons, not just the first
  ```swift
  struct ValidationResult {
      let valid: Bool
      let errors: [GameError]  // all blocking reasons
      let warnings: [String]?  // e.g., "this locomotive is rusting"
  }
  ```

APPROVED 

### 5. **Deprecate direct mutating of GameState in tests**
- **File:** `TestSupport.swift`
- **Issue:** Test helpers like `give()` and `setOrders()` mutate state directly without events, making assertions fragile
- **Reason:** These helpers bypass the event system, so tests don't catch bugs where events are missing.
- **Suggested refactor:** Create factory functions that return a properly-initialized `GameState` instead of mutating a blank one
  ```swift
  static func stateWithCards(players: Int, cards: [(playerID: Int, locID: Int)]) -> GameState
  ```

APPROVED

### 6. **Add GameState.legalActionsForCurrentPlayer() helper**
- **File:** `State/GameState.swift`
- **Issue:** `GameEngine.legalActions()` is stateless and operates on the whole state. UI often wants "what can player 0 do right now?"
- **Reason:** Simplifies UI logic and makes the intent clearer.
- **Suggested addition:**
  ```swift
  public func legalActionsForCurrentPlayer() -> [GameAction] {
      guard let id = currentPlayerID else { return [] }
      return GameEngine.legalActions(in: self)  // already filtered by currentPlayerID
  }
  ```

APPROVED. Legal actions are important

### 7. **Extract SalesOrder matching logic into a separate decision tree**
- **File:** `GameBoard/SalesOrder.swift`
- **Issue:** The `sell()` method does case matching but the three cases (same, lower, larger) are defined in the rulebook with specific priority rules
- **Reason:** Easier to test the decision tree independently; improves clarity of rulebook implementation.
- **Suggested addition:** Create `enum SaleDecision` with clear matching logic
  ```swift
  enum SaleCase { case sameNumber, lowerNumber, largerNumber }
  static func decideSale(offered: Int, demanded: [Int]) -> (case: SaleCase, sold: Int)?
  ```

APPROVED

### 8. **Add GameState.summary() for debugging**
- **File:** `State/GameState.swift`
- **Issue:** When tests fail, the error message is the whole GameState JSON. Hard to read quickly.
- **Reason:** Improves debugging and test failure readability.
- **Suggested addition:**
  ```swift
  public var summary: String {
      "Round \(round) [\(phase)] P\(currentPlayerID ?? -1): " +
      bank.balances.map { "$\($0)" }.joined(separator: ", ") +
      " | Board: \(board.summary)"
  }
  ```

APPROVED

### 9. **Replace try? with explicit error logging in ProductionManager.resetAll**
- **File:** `Production/ProductionManager.swift`, line 43
- **Issue:** Silently ignores errors in `resetAll()`. If a modification throws, the card won't reset but the game continues.
- **Reason:** This should never fail; if it does, it's a game-breaking bug. Logging makes it visible.
- **Suggested change:**
  ```swift
  public static func resetAll(in hand: inout Hand) {
      for id in hand.ids {
          do {
              try hand.modify(id) { $0.production.reset() }
          } catch {
              preconditionFailure("resetAll should never fail: \(error)")
          }
      }
  }
  ```

APPROVED.

### 10. **Add GameError descriptions for player-facing messages**
- **File:** `Errors/GameError.swift`
- **Issue:** GameError cases are technical. UI needs human-readable messages.
- **Reason:** Enables better UX feedback without UI layer having to map errors manually.
- **Suggested addition:**
  ```swift
  extension GameError {
      public var playerMessage: String {
          switch self {
          case .insufficientFunds: "You don't have enough coins for this action"
          case .locomotiveNotOwned: "You don't own this locomotive"
          // ...
          }
      }
  }
  ```
APPROVED.  

---

## Game State & Session Improvements

### 1. **Add a GameSession type to track player participation**
- **Gap:** The engine knows players exist but doesn't track who is playing (human vs. bot, online status, etc.)
- **Why:** Future UI layer needs to know whether to wait for a player's action or auto-resolve a bot's turn
- **Suggested type:**
  ```swift
  struct GameSession {
      let game: Werks
      let players: [PlayerSession]
      var currentPlayer: PlayerSession { players[game.state.currentPlayerID ?? -1] }
  }
  struct PlayerSession {
      let playerID: Int
      let name: String
      let isBot: Bool = false
      var timeBank: TimeInterval = 0  // for online play
  }
  ```

APPROVED

### 2. **Add GameStateSnapshot for UI state queries**
- **Gap:** UI needs to ask "what has changed since last update?" but the engine only offers full state
- **Why:** Improves rendering performance; UI can highlight only changed cards/coins instead of redrawing everything
- **Suggested type:**
  ```swift
  struct GameStateSnapshot {
      let state: GameState
      let deltas: Set<StateChange>
  }
  enum StateChange {
      case coinsChanged(playerID: Int)
      case cardAdded(playerID: Int, locomotiveID: Int)
      case phaseChanged
      case turnChanged
  }
  ```

APPROVED

### 3. **Add GameMetrics for replay/replay validation**
- **Gap:** No way to validate that a replayed game follows the same rules execution path
- **Why:** Helps catch bugs in determinism and rule changes
- **Suggested type:**
  ```swift
  struct GameMetrics {
      let totalSalesRounds: Int
      let cardsWithdrawn: [Int: Int]  // locomotiveID -> count
      let marketDemandRolls: Int
      let averageWealthPerRound: [Int]
  }
  ```

APPROVED

### 4. **Add UndoManager integration point**
- **Gap:** No way to roll back a single action (useful for misclicks in UI)
- **Why:** The Werks replay system already supports it; exposing it would improve UX
- **Suggested method:**
  ```swift
  public mutating func undo() throws -> GameAction {
      guard history.count > 1 else { throw GameError.cannotUndo }
      let previousAction = history.removeLast()
      self = try Werks.replay(players: /* ... */, actions: history)
      return previousAction
  }
  ```

APPROVED


### 5. **Add GameState.playerStats() for end-game reporting**
- **Gap:** No way to compute per-player statistics (wealth by round, cards developed, best-selling locomotive)
- **Why:** Enables rich end-game screens and replay analysis
- **Suggested type:**
  ```swift
  struct PlayerStats {
      let playerID: Int
      let finalWealth: Int
      let cardsDevoped: Int
      let totalUnitsSold: Int
      let roundWealthProgression: [Int]
      let mostProfitableLocomotive: Int?
  }
  ```

APPROVED

---

## Clarification Questions About the Game

### 1. **Discarded cards and re-development:**
- **Rule:** "A player may only develop a locomotive once per hand history"
- **Question:** If Player A develops Green 1st, then shifts all units away and discards it, can Player A never develop Green 1st again, even later in the game?
- **Current test:** `LocoDevelopmentTests.testCannotRedevelopADiscardedCard` confirms this, but the rulebook doesn't explicitly say what "previously discarded" means

APPROVED: Just keep a history of previousily held cards. Allow a player to build any card they legally can. So in this case, they can legally, technically rebuy a card that was removed

### 2. **Rusting flag vs. Generation determination:**
- **Rule:** "Rusting is a flag; active generations are identified by dice only"
- **Question:** If a locomotive has no dice but is marked rusting, is it still a generation for market demand purposes?
- **Current implementation:** The code correctly checks dice, not rust. Good. Confirms in test `GenerationOrderUsesGenerationNotRustFlag`

APPROVED: If a locomotive is active, but rusting and has no dice: this is the wrong flag.  It should be rusted because 0 dice.  

### 3. **Multiple generations in market demand:**
- **Rule:** "3 generations exist → oldest becomes obsolete, middle is topped up, newest grows"
- **Question:** What if the middle generation has no dice (all were returned)? Does it still count as a generation?
- **Current implementation:** Line 30 in `MarketRules.swift` checks `isInMarket`, which requires existing or filled orders. So a generation with zero dice is not counted. **This interpretation should be explicit in a test.**

APPROVED: Its not possible as far as I can tell.

### 4. **Turn order ties and stability:**
- **Rule:** "Least cash first; ties keep their relative order"
- **Question:** After a tie resolution, what if two players end up with the same new cash (due to taxes)? Does the old order persist exactly, or is it re-sorted?
- **Current test:** `TaxTests.testTiesKeepRelativeOrder` covers this, but only at one moment. Should test if the order is stable across multiple rounds with repeated ties.

APPROVED: The order is in relative turn order. 
1st Tom: 10, 2nd Alex: 10, 3rd Sarah: 30.  Tom & Alex are drawing. Tom remains 1st, Alex 2nd, Sarah 3rd.

### 5. **Income calculation for fractional costs:**
- **Rule:** "Income = production cost ÷ 2, rounded up. Production cost = development cost ÷ 2, rounded up."
- **Question:** For a locomotive with cost 3, production cost = 2, income = 1. Is this correctly reflected in the Catalogue?
- **Current test:** `LocomotiveCatalogueTests` should verify these calculations for all 14 spaces

APPROVED: THere should be NO fractional costs at all in the game.  They are integers only.

### 6. **Shift capacity across multiple generations:**
- **Rule:** "Shift from Red 1st → Green 2nd is allowed because Green 2nd is higher on the board"
- **Question:** Can you shift from Red 1st → Green 5th in the same action, or does it have to be one space higher?
- **Current test:** `CapacityTests.testShiftAcrossLiveriesIsAllowedWhenHigherOnBoard` tests Red 1st → Green 2nd but not Red 1st → Green 3rd+

APPROVED: You can shift production units from any active card you have in your hand, to any active card in your hand SO long as the card you're moving to is sequentially higher than previous.  A quick way to tell is if the price of the card gaining the production units is higher, or just look at the board state, where did it come from: is it further along in the game board, and active: then yes, you can shift it.

You can:  shift Red 1st -> ANY card in your hand so long as its higher than Red 1st.  

My hand: Green 1st -> Red 1st Valid 
My hand: Red 1st -> Green 3rd Valid
My hand: Green 3rd -> Green 1st INVALID

### 7. **Sales priority in simultaneous multi-type selling:**
- **Rule:** "A player may sell one locomotive type before the next player begins"
- **Question:** If Player A owns Red 1st, Red 2nd, Green 1st with demand on all three, can Player A sell in any order (Red 1st, Green 1st, Red 2nd) or must it follow board order?
- **Current implementation:** `resolveProduction` iterates board order, not player preference order. Confirm this is intentional.

APPROVED: It must follow the exact board order, in linear sequence and is described below.

Perform all sales for [board.space.1] for all players involved, in turn order. It may not be possible to sell anything; in which case they are skipped.  Keep repeating this sales cycle for [board.space.1] until all players cannot sell. They cannot pass. All sales are automatic, are done in turn order.

When the sales cycle for board.space.1 is done, then move to board.space.2; and continue this process until all active board.spaces sales are done.

Thus: Find all active board.spaces in linear sequence starting at board.space.1 with valid orders to resolve, and walk through each board.space, performing the sales cycle in turn order, if possible and skip those who cannot sell.

FEATURE: All sales transactions for that round should be recorded. Its only for 1 round; and no history is recorded for prior rounds sales transactions (yet)

FEATURE REQUEST: I may want to animate the sales visually board space by board space, so I'd like a way to handle this:
- Idea: Add the sales made in a queue and the animation's then do the rest in some way, animations can be skipped; and the animation queue is cleared and moved to next stage.  UI Animations should block all buttons interaction except on that animation modal, this is not to implemented yet but make a note of it somewhere.


### 8. **Initial die on the next space after development:**
- **Rule:** "Place initial die on the next locomotive, rolled once, never repopulated"
- **Question:** If a player develops the last locomotive (ID 14), there is no "next." The rule says "nothing follows ID 14." Should this be tested?
- **Current test:** `LocoDevelopmentTests.testLastSpaceDoesNotSpawnBeyondBoard` covers this ✓

APPROVED: Yes, it should be tested. Only 14 spaces, so if on 14, no new spawns of initial die should be happening.

### 9. **Simultaneous end-game condition:**
- **Rule:** "After taxes, if ≥1 player has 300 coins, the richest wins"
- **Question:** What if two players tie with exactly 300 coins, and a third has 299? Both tied players win, right?
- **Current test:** `TaxTests.testTiedWinnersShareVictory` confirms this ✓

APPROVED: All tied players wins.

### 10. **Production reset timing:**
- **Rule:** "After all sales, players put Production Unit counters back on their cards"
- **Question:** If a card is removed (empty from shift) before the reset, does it need units reset? No—it's gone.
- **Current test:** `ProductionPhaseTests.testSpentUnitsAreResetAtEndOfPhase` only tests surviving cards

APPROVED: This is not possible because in PHASE 2: Production capacity, if the production units are shifted and is empty then its removed from play.  This edge case is only handled in PHASE 2 only.  

In all other cases, production units are returned to the cards.

---

## Summary of Priorities

### High Priority (Improves Testability):
1. Extract GameSession abstraction (enables better test isolation)
2. Add missing edge-case tests for Hand and ProductionUnits
3. Add GameBoard initialization/integrity tests
4. Increase random play test coverage (200+ seeds, 5000+ actions)

### Medium Priority (Improves Clarity):
5. Add GamePhase.isResolvable property
6. Extract SalesOrder decision tree
7. Replace silent try? with preconditionFailure
8. Add GameError.playerMessage
9. Add GameState.summary() for debugging

### Low Priority (Nice-to-Have):
10. Add concurrent/sequential development tests
11. Add GameStateSnapshot for UI
12. Add GameMetrics for validation
13. Add UndoManager integration point
14. Document game rule clarifications in comments

---

# Tagged Fixes (v2 - Post-Clarification)

## High Priority

### [fix-sales-test-dice-logging-1]
**File:** `Tests/WerksPackage-Tests/Sales/ProductionPhaseTests.swift`
**What:** Add comprehensive single-locomotive test with console logging of dice state transitions
**Why:** Verify dice move correctly (Initial→Existing→Filled→back to Existing), see sale case decisions
**Scope:** Add 1 new test function (~50 lines)
**Details:**
- Set up single locomotive (e.g., Green 1st) with controlled dice
- Player 0 has 3 units, board shows [4, 1] existing orders
- Log before/after for each player sale: "Player 0 sells 3 units: sale case = lowerNumber, dice: [4,1] → [1,1]"
- Verify dice returned to board correctly

---

### [fix-dice-transfer-manager-2]
**File:** `Locomotive/DiceTransferManager.swift` (new file)
**What:** Create single-responsibility type for all dice movements
**Why:** Currently dice move in multiple places (Development, Market, Sales); centralize for clarity and testing
**Scope:** ~100 lines of new code
**Details:**
Move these operations into a new enum:
```swift
enum DiceTransferManager {
    // From Initial Orders to Existing (when locomotive first developed)
    static func promoteInitialToExisting(_ id: Int, in board: inout GameBoard) -> Die?
    
    // From Existing to Filled (market demand aging)
    static func returnOneDieToPool(_ id: Int, in board: inout GameBoard) -> Die?
    
    // Roll Filled → Existing (market demand resolution)
    static func rollFilledOrders(_ id: Int, using rng: inout SeededRandomNumberGenerator, 
                                in board: inout GameBoard) -> [Int]
    
    // Reduce Existing (sales)
    static func reduceDemand(_ id: Int, by units: Int, in board: inout GameBoard)
    
    // Move die from Existing → Filled (complete sale)
    static func fillOrder(_ id: Int, from existingOrders: inout [Int], 
                         to filledOrders: inout [Int])
}
```
**Tests:** Add `Tests/WerksPackage-Tests/Locomotive/DiceTransferTests.swift` (30 lines)

---

### [fix-sales-order-decision-tree-3]
**File:** `GameBoard/SalesOrder.swift`
**What:** Extract the 3-case sale decision (same/lower/larger) into testable function
**Why:** Currently buried in `sell()` method; makes priority rules unclear
**Scope:** Extract existing logic into new public function
**Details:**
```swift
// Add to SalesOrder:
public enum SaleCase { case sameNumber, lowerNumber, largerNumber }
public struct SaleDecision {
    let saleCase: SaleCase
    let unitsSold: Int
}

public static func decideSale(offered: Int, demanded: [Int]) -> SaleDecision? {
    // 1. If exact match exists: same number (forced choice)
    if demanded.contains(offered) {
        return SaleDecision(saleCase: .sameNumber, unitsSold: offered)
    }
    // 2. If offered < max demand: lower number (sell all)
    if let max = demanded.max(), offered < max {
        return SaleDecision(saleCase: .lowerNumber, unitsSold: offered)
    }
    // 3. If offered > max demand: larger number (sell max only)
    if let max = demanded.max() {
        return SaleDecision(saleCase: .largerNumber, unitsSold: max)
    }
    return nil
}
```
**Tests:** Add `Tests/WerksPackage-Tests/Sales/SaleDecisionTests.swift` with case-by-case tests

---

### [fix-bank-encapsulation-4]
**File:** `Financial/Bank.swift` and `Rules/TaxRules.swift`
**What:** Make Bank.balances completely private; expose only query methods
**Why:** Enforce that ALL coin operations go through Bank methods
**Scope:** Add 3 methods to Bank, modify TaxRules
**Details:**
```swift
// Add to Bank:
public func hasWinnerAt(_ threshold: Int) -> Bool {
    balances.contains { $0 >= threshold }
}

public func winnersAbove(_ threshold: Int) -> [Int] {
    players.indices.filter { balances[$0] >= threshold }
}

public func reorderByWealth(_ currentOrder: [Int]) -> [Int] {
    currentOrder.enumerated()
        .sorted { lhs, rhs in
            (balances[lhs.element], lhs.offset) < (balances[rhs.element], rhs.offset)
        }
        .map(\.element)
}

// Change line 14:
private var balances: [Int]  // was: public private(set)
```
Then update `TaxRules.resolveTaxes()` to use these methods

---

## Medium Priority

### [fix-hand-edge-case-tests-5]
**File:** `Tests/WerksPackage-Tests/Player/HandTests.swift`
**What:** Add edge case tests for Hand mutations
**Why:** Verify internal invariants (sorted order, history tracking) under partial failures
**Scope:** Add 3 test functions (~30 lines)
**Details:**
- Test that cards stay sorted after add/remove/modify
- Test history is persistent even after removal
- Test that modify failure leaves card unchanged

---

### [fix-gamestate-summary-6]
**File:** `State/GameState.swift`
**What:** Add debug-friendly summary property
**Why:** Improve test failure messages and debuggability
**Scope:** Add 1 property (~10 lines)
**Details:**
```swift
public var summary: String {
    "Round \(round) [\(phase)] Player \(currentPlayerID ?? -1) of \(turnOrder.count): " +
    bank.balances.enumerated().map { "P\($0.offset):\($0.element)" }.joined(separator: ", ")
}
```

---

### [fix-gamephase-helper-7]
**File:** `State/GamePhase.swift`
**What:** Add `isResolvable` property to eliminate duplicated phase checks
**Why:** Phase logic repeated in GameEngine and tests
**Scope:** Add 1 computed property (~3 lines)
**Details:**
```swift
public var isResolvable: Bool { 
    self == .production || self == .taxes || self == .marketDemand 
}
```
Then update `GameEngine.legalActions()` to use `state.phase.isResolvable`

---

### [fix-production-manager-error-logging-8]
**File:** `Production/ProductionManager.swift`, line 43
**What:** Replace `try?` with explicit `preconditionFailure` in `resetAll`
**Why:** This should never fail; silent failures hide game-breaking bugs
**Scope:** Change 2 lines
**Details:**
```swift
// BEFORE:
try? hand.modify(id) { $0.production.reset() }

// AFTER:
do {
    try hand.modify(id) { $0.production.reset() }
} catch {
    preconditionFailure("resetAll should never fail: \(error)")
}
```

---

### [fix-gameerror-player-message-9]
**File:** `Errors/GameError.swift`
**What:** Add player-facing error message extension
**Why:** UI shouldn't need to map technical errors manually
**Scope:** Add extension (~25 lines)
**Details:**
```swift
extension GameError {
    public var playerMessage: String {
        switch self {
        case .insufficientFunds(let req, let avail):
            "Need \(req) coins; you have \(avail)"
        case .locomotiveNotOwned(let id):
            "You don't own locomotive \(id)"
        case .locomotiveObsolete(let id):
            "Locomotive \(id) is obsolete and cannot be used"
        case .wrongPhase(let phase):
            "This action is not allowed in \(phase)"
        // ... etc
        }
    }
}
```

---

## Low Priority (Future/Optional)

### [fix-bot-shift-lookahead-10]
**File:** `GameBoard/SalesOrder.swift` or new `AI/ShiftStrategy.swift`
**What:** Create helper to check if shifting would eliminate unfulfilled demand
**Why:** Bot needs to know: "If I shift all units away, can I still fulfill this locomotive's demand?"
**Scope:** Add 1 utility function (~15 lines)
**Details:**
```swift
// Helper for bot logic:
public static func wouldEliminateDemand(shiftingFrom source: Int, 
                                        in board: GameBoard) -> Bool {
    guard let card = hand.card(source), card.production.units > 0 else { return false }
    let space = board[source]
    return space.existingOrders.reduce(0, +) > 0 && 
           card.production.units == space.existingOrders.max() ?? 0
}
```

---

### [fix-locomotive-definition-validation-11]
**File:** `Tests/WerksPackage-Tests/Locomotive/CatalogueTests.swift`
**What:** Add comprehensive board integrity test
**Why:** Verify all 14 spaces are initialized correctly with right costs/income
**Scope:** Add 1 test (~50 lines)
**Details:**
- Loop through all 14 locomotives
- Verify cost calculations: income = cost / 2 rounded up
- Verify production cost = development cost / 2 rounded up
- Verify maxDice and available cards match catalogue
- Verify IDs match expected board position

---

### [fix-random-play-coverage-12]
**File:** `Tests/WerksPackage-Tests/Game/GameEngineTests.swift`
**What:** Increase random play test seed range and depth
**Why:** Catch rare state mutation bugs with longer simulations
**Scope:** Change 2 lines in `testRandomPlayKeepsInvariants`
**Details:**
```swift
// BEFORE:
for seed in UInt64(0)..<20 {
    for players in GameState.playerRange {
        let game = try Self.simulate(players: players, seed: seed, maxActions: 3_000)

// AFTER:
for seed in UInt64(0)..<200 {  // was 20
    for players in GameState.playerRange {
        let game = try Self.simulate(players: players, seed: seed, maxActions: 5_000)  // was 3000
```

---

## Implementation Order

**Recommended sequence (by impact and dependency):**

1. **[fix-sales-test-dice-logging-1]** - Gives visibility into dice movement (no dependencies)
2. **[fix-dice-transfer-manager-2]** - Centralizes logic for clarity (no dependencies)
3. **[fix-sales-order-decision-tree-3]** - Extracts decision logic (standalone)
4. **[fix-bank-encapsulation-4]** - Enforces coin-only-through-bank (depends on 1-3 being clean)
5. **[fix-hand-edge-case-tests-5]** - Improves test coverage (no dependencies)
6. **[fix-gamestate-summary-6]** - Debug improvement (no dependencies)
7. **[fix-gamephase-helper-7]** - Code cleanup (no dependencies)
8. **[fix-production-manager-error-logging-8]** - Safety improvement (no dependencies)
9. **[fix-gameerror-player-message-9]** - UX prep (no dependencies)
10. **[fix-bot-shift-lookahead-10]** - Future feature prep (depends on understanding from 1-3)
11. **[fix-locomotive-definition-validation-11]** - Test coverage (no dependencies)
12. **[fix-random-play-coverage-12]** - Test depth (no dependencies)

