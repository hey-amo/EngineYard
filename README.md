# 🚂 EngineYard
@updated: 12 Nov 2026

Hobby attempt at creating a turn-based game based on `Locomotive Werks` board game.

Uses:
- Swift 5.x

Aims:
- Offline mode (Pass and play and verses bots)
- Local storage

Won't be doing:
- Online mode
- Cloud storage

-------

## Proposed package Usage (WIP)

```swift
var game = try WerksGame(players: [.init(name: "Ann"), .init(name: "Bob"), .init(name: "Cat")], seed: 42)
game.state.currentPlayerID              // who acts
game.legalActions                       // [.develop(locomotiveID: 2), .pass]
try game.apply(.develop(locomotiveID: 2))
// ... once the phase is .production, .taxes or .marketDemand:
try game.apply(.resolvePhase)
game.log.reversed()                     // newest message first

// Live, shared game (serialised, observable):
let store = try GameStore(players: seats, seed: 42)
Task { for await update in await store.updates() { /* render update.state, log update.events */ } }
try await store.send(.pass)
```


---------

