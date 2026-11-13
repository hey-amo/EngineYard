# Locomotive Werks – Product Requirements (Game Logic Package)

## 1. Purpose and scope

A UI-free, deterministic Swift package that implements the board game Locomotive Werks (3–5 players, most money wins). The UI is a later phase.

- Targets: iOS first; iPadOS, macOS and tvOS later. iPhone Duo is not planned yet.
- Offline only: pass-and-play. Online play is out of scope.
- Bots are out of scope for the engine. The engine exposes `legalActions` so a bot can be added later.
- Swift 6.x, complete strict concurrency, no `@MainActor` anywhere in the package.
- No UIKit, SwiftUI or Combine imports.

## 2. Architecture principles

1. Each bounded concept is its own folder if they share the same context.
2. **Folders are named for what they do.
3. **Single owner per concern.** Coins change only in `Banking`. Cards change only in `LocomotivePortfolio`. Production-unit arithmetic changes only in `ProductionCapacity`. Dice orders change only in `LocomotiveMarket`. Owners use `private(set)`, and phase code calls them rather than doing `+=` / `-=` itself.
4. **Domain models are separate from infrastructure models.** Save-game records, DTOs and DB entities are never the domain types, even when the fields look identical. DRY means not duplicating *knowledge*. A DTO changes when the storage format changes, and a domain model changes when the business rules change.
5. **Value types by default.** Models are `struct` / `enum` and `Sendable`. The only actor is the live-game store.
6. **Determinism.** All randomness goes through a seedable die roller. The same seed and the same actions always give the same game.

## 3. Package structure

```text
Sources/
├── LocomotiveCatalogue/        printed data of the 14 board spaces (never changes)
│   └── {Models, Errors}
├── Banking/                    every coin, one owner
│   └── {Models, Errors}
├── LocomotivePortfolio/        what a player owns
│   ├── {Models, Errors}
│   ├── CardOwnership/          add, remove, remember developed cards
│   └── ProductionCapacity/     add, spend, transfer, reset production units
├── LocomotiveMarket/           demand dice and card supply
│   ├── {Models, Errors}
│   ├── OrderMatching/          same / lower / larger number sale decision
│   ├── DemandGeneration/       0/1/2/3-generation market cases
│   └── CardSupply/             withdrawing outdated cards, initial die
├── DiceRolling/
│   ├── {Protocol}             DieRoller
│   └── SeededRolling/          seeded, Codable implementation
├── GameRoundFlow/              who acts and in which phase
│   ├── {Models, Actions, Events, Errors}
│   ├── TableSetup/
│   ├── Ph1-LocomotiveDev/          phase 1 (Locomotive development)
│   ├── Ph2-CapacityExpansion/      phase 2
│   ├── Ph3-LocomotiveSales/        phase 3
│   ├── Ph4-TaxCollection/          phase 4
│   ├── Ph5-MarketDemandPhase/      phase 5
│   ├── GameEndDetection/       
│   └── LegalMoveListing/
├── LiveGameSession/            one running game seen from outside
│   ├── Models/          Game, GameUpdate
│   ├── ReplayHistory/
│   └── UpdateBroadcasting/     GameStore actor, AsyncStream subscribers
└── GameMessageLog/
    └── Presentation/ViewData/  event-to-text formatting
Tests/                          one test target per framework, same folder names
```

Future, when saving is added: `/Persistence/{Models, StoreImplementation}` holds the stored record (`SavedGameRecord`) and its mapping to and from `GameState`.

**Dependency direction (no cycles):**
`LocomotiveCatalogue`, `Banking`, `DiceRolling` ← `LocomotivePortfolio`, `LocomotiveMarket` ← `GameRoundFlow` ← `LiveGameSession` ← `GameMessageLog`

Cross-framework members that must be hidden from the app use Swift's `package` access level.

**Delivery option:** start with a single `WerksEngine` target using these exact folders, then promote each top-level folder to its own target.

## 4. Error handling requirements

**Goal:** when something throws, the type alone says which part of the game threw it.

1. **One error type per framework**, named for its context:

   Numeric/unit problems (`ProductionCapacityError`) are never mixed with flow problems (`RoundFlowError`).
   
2. **An umbrella `EngineError` at the public boundary** wraps each context error:
   ```swift
   public enum EngineError: Error, Equatable, Sendable {
       case catalogue(CatalogueError)
       case banking(BankingError)
       case cardOwnership(CardOwnershipError)
       case productionCapacity(ProductionCapacityError)
       case market(MarketError)
       case roundFlow(RoundFlowError)
   }
   ```
3. **Rejected actions carry context.** `GameEngine.apply` throws an `ActionRejection` containing the `EngineError`, the `GameAction` and the acting player ID, so a log line can say *who tried what and which part refused*.
4. **Typed throws.** Public engine functions declare `throws(ActionRejection)` (Swift 6). Internal functions throw their own context error.
5. **Atomic actions.** A rejected action never changes the state, and tests assert this.
6. **Every error case has at least one test** that asserts the exact type and case, not just "throws".

## 5. Game rules

### Players and setup
- 3–5 players. Each starts with money, and turn order is a seeded shuffle.
- **3–4 players:** $12 each, one Green 1st card with 1 production unit per player, 3 dice in Green 1st existing orders, 1 die as Red 1st initial order.
- **5 players:** $14 each, no cards, 1 die as Green 1st initial order.

### GameBoard (14 spaces, fixed order, never shuffled)

| ID | Name | Cost | Max dice | Cards |
|---|---|---|---|---|
| 1 | Green 1st | 4 | 3 | 4 |
| 2 | Red 1st | 8 | 3 | 3 |
| 3 | Yellow 1st | 12 | 2 | 2 |
| 4 | Blue 1st | 16 | 1 | 1 |
| 5 | Green 2nd | 20 | 4 | 4 |
| 6 | Red 2nd | 24 | 3 | 3 |
| 7 | Yellow 2nd | 28 | 3 | 2 |
| 8 | Green 3rd | 32 | 4 | 4 |
| 9 | Blue 2nd | 36 | 2 | 2 |
| 10 | Red 3rd | 40 | 4 | 3 |
| 11 | Green 4th | 44 | 5 | 4 |
| 12 | Yellow 3rd | 48 | 3 | 3 |
| 13 | Red 4th | 52 | 4 | 4 |
| 14 | Green 5th | 56 | 5 | 4 |

Production cost = cost ÷ 2, rounded up. Income = production cost ÷ 2, rounded up. "Next locomotive" means ID + 1, and nothing follows ID 14. The dice-pool limit does not matter digitally, and neither do the physical counter limits.

### Game loop

```text
each phase [] is done in turn order, before preceeding to the next one
[Locomotive Development] -> [Production Capacity] -> [Locomotive production] -> [Pay taxes] *check for end game trigger here* -> Market demands -> [New round]
```


### Round phases
1. **Locomotive Development (optional).** Each player in turn may develop one locomotive. It needs an initial die or existing/filled orders, an available card, enough money, and the player must never have developed it before. On the first-ever purchase the initial die moves unchanged into existing orders, and the next space receives its one initial die, rolled once and never repopulated. When a 3rd, 4th or 5th generation is first bought, unsold cards of that colour two generations older are removed, but their dice stay.
2. **Production Capacity (optional).** Any number of buy actions or shifts. Units move only to a higher board ID, paying the production-cost difference. A card left with no units is removed, and the player cannot redevelop it.
3. **Locomotive Production (automatic).** One locomotive at a time in board order. Selling rounds run in turn order until nobody can sell. Same number beats lower number, then larger number. Sold units are *spent*, and at the end all spent units are reset back onto their cards.
4. **Pay Taxes (automatic).** 10% of cash, rounded down. Then the end-of-game check. If the game continues, the new turn order is least cash first, with ties keeping their previous order.
5. **Market Demands (automatic).** Per colour in order green, red, yellow, blue:
   - 0 generations: nothing.
   - 1: add one customer die if below max, then roll the customer base into existing orders.
   - 2: the older one returns one customer die (or, with none, its lowest existing die) and rolls the rest; the newer one grows by one.
   - 3 or more: the oldest become obsolete, the middle is topped up to max, and the newest grows by one.

   Rules decide on `Generation` and dice, never on the informational `rusting` flag.

### Game end
The game ends after taxes when a player reaches the winning threshold. The richest player wins, and tied players share the win. The threshold lives in `GameRules`. See open item 1.

## 6. Production units
Each card holds `units` and `spentUnits`.
- `add(n)` increases `units`.
- `spend(n)` moves `n` from `units` to `spentUnits`.
- `reset()` does `units += spentUnits; spentUnits = 0`.
- `remove(n)` takes units off for shifting.

## 7. Concurrency
- Rules and models are value types, and each action runs on a private copy (a transaction).
- The live game is one `GameStore` actor. It serialises actions and broadcasts `GameUpdate` through `AsyncStream`.
- Banking and portfolio are **not** separate actors, so validate-then-charge-then-add stays one atomic step.

## 8. Testing
- XCTest, one test target, with folders for the item being tested
- Every rule gets a happy path, each rejection and a boundary.
- The PDF rulebook examples (same, lower and larger number sales, the shift cost example) are tests.
- A seeded random-play test checks invariants after every action.
- A strategy game checks that games reach game over.
- Replay from seed and actions must reproduce the same state.

## 9. Expected screens

This is when we implement visuals

- Main Menu
- Settings screen
- New Game setup
    - Select players (humans and bots)
- Game board screen
- Player profile card
- My Portfolio (cards, production units, etc)
- Phase1-screen
- Phase2-screen
- Phase3-screen
- Phase4-screen (taxes)
- Phase5-screen (market demands)
- EoR-Reports-screen (end of round reports, end of round financial report?)
- Winners-screen
- Game message log (showing in-game messages, latest first, capped at 50 messages)
- Financial reports
- How to play screens (carousel style)

Onboarding:  (with mascot)
- Welcome to the game
- How to play (carousel)
    - Phase 1 short intro
    - Phase 2 short intro
    - Phase 3 short intro
    - Phase 4 short intro
    - Phase 5 short intro


Modals
- Tutorial hints/tips
- Messages

Drawers
- My hand
- Locomotive: View locomotive detail card
- Locomotive: Enter production units with display of rivals who owns this, turn order

### Game board screen intended structure

[HUD: List of players, Hamburger menu] (sticky at top of screen)
[Phase label]
[Help mascot telling you what to do]
[Game message mini view]
[Game board]
-- [List of locomotives with detail indicator]
[Sticky at bottom: Tab bar? Buttons? Continue button?]

### Hamburger menu

- Settings
- Load/save game (?)
- My hand (?)
- How to play (?)
- Financial reports (?)
- Quit game (ends current game, returns to main menu)

## Other points

Menu buttons, dialogs should not be clickable if animations are playing
If the hamburger menu is pressed, the game is paused
If the hamburger menu is dismissed, the game continues
