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
var game = try Game(players: [.init(name: "Ann"), .init(name: "Bob"), .init(name: "Cat")], seed: 42)
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

## Rules

Number of player: 3-5

**Objective of the game**

Players assume the role of engineers, constructing and producing more and more advanced locomotives. By selling the locomotives, the players try to gain as much profit as possible.

The game ends when one player has 300 coins or more, after paying taxes.

> Winner: Is the player with the most coins after paying taxes.  Tied is shared.

---

### Components:

- 5 player turn order cards
- 43 locomotive cards
- 20 dice
- 80 double sided counters (1 or 2 production units)
- 1 game board with 14 game board spaces in sequential order.

---

### The Board

The game board has 14 `spaces`, this sequence never changes and is never randomised.

---

### Setup

From the first board space and moving sequentially, fill the board space with all locomotive cards that match the same colour and generation.  The order of these cards within each space does not matter.

> For example:
> Board space #1 is Green, 1st Generation.
> Collect all First generation Green locomotives cards and place in this board space.
> Board space #2 is Red, 1st Generation.
> Collect all First generation Red locomotives cards and place in this board space.
> This continues until all locomotive cards are placed in their respective spaces on the board.

For `3-4 players`: give each player $12 and give each player 1 First Generation Green card. Each player places 1 production unit with the "1" face up.  Any remaining locomotive cards in this space are removed and returned to the box.

For `3-4 players`: roll 3 dice and place these into the First Generation Green Orders section. Then, roll 1 die and places this in the initial orders for the next sequential board space, which is the Red, 1st Generation.

For `5 players`: give each player $14. No player starts with any locomotive cards. Roll only 1 die and place this in the Green, 1st Generation initial orders.  No other dice are placed.

Shuffle the player turn order cards and hand 1 to each player.   The first player is the one with the 1st position.

-------

## Playing the game

Werks is played in rounds. Each round consists of the following phases; in each phase will resolve players their turn in Player Order before proceeding to the next game phase. 

Thus, every player in turn order does Phase 1, then every player does Phase 2 in turn order, etc.

- Phase 1: Develop Locomotive - Players may develop 1 new locomotive
- Phase 2: Buy Locomotive Production Capacity - Players may purchase production
- Phase 3: Locomotive Production - Players may produce and sell locomotives
- Phase 4: Pay taxes: Players must pay taxes. Redo turn order. Determine winner.
- Phase 5: Market demands

Phase 1: Develop Locomotive

During this phase each player, in turn order, may develop only 1 locomotive - however, they are not obliged to do so, and may pass.

When developing locomotive, the player must pay its cost to the Bank. A player may only develop a locomotive that either has 1 die in the `Initial orders` box or one or more dice in the `Existing orders` boxes.

Additionally, a player may develop a locomotive only if it has an avalable locomotive card.  Furthermore, each player may develop each locomotive only once.  If the player has already developed that locomotive, that player may not develop it again.

For example, Pete already has a First Generation Freight locomotive. He may not develop another First Generation Freight locomotive.

After a player has developed a locomotive, the player takes the corresponding locomotive card and places it face up in front of himself, then adds one Production Unit counter from the game board and places it on the locomotive card.

Additionally, if the developed locomotive was the most advanced (i.e., it had a die in the Initial Orders area), then the player slides the die from the Initial Orders area to one of the Existing Orders boxes for that locomotive without changing the face of the die. 

That player then rolls a new die and places it in the `Initial Orders` area of the next locomotive on the game board (the next locomotive always being the next connected one).

When the `Third`, `Fourth` or `Fifth` Generation of a certain locomotive type is brought into play, remove any unpurchased locomotive cards of that type that are two generations older from the game board.

---

Phase 2. Production Capacity

During this phase, each player may purchase additional production capacity for his locomotive production. In addition, a player may shift Production Units from older technology locomotive cards to newer technology loco- motive cards.

The amount of production capacity the player may purchase or shift is not limited – as long as he can pay the costs.

When purchasing new production capacity, the play- er must pay the production costs to the bank; he then takes the appropriate counter(s) and places it (or them) on the locomotive card.

When shifting production capacities from older locomotive cards to newer locomotive cards, the player simply transfers the Production Unit counters from one locomotive card to the other. In addition, he must pay the difference of production costs to the Bank.

Important:
A player may only upgrade Production Capacities, i.e., he cannot shift capacities from newer locomotive cards to older locomotive cards!

A player may not trade 2 Production Units of a First Generation Passenger locomotive for 1 Production Unit of a First Generation Fast locomotive.

Production Units may not be sold to another player or to the Bank.

If – after shifting capacities – a locomotive card has no Production Units, remove it from the game immediately.

---

Phase 3. Locomotive Production

During this phase, the players sell their produced locomotives. They receive the money for their sold locomotives from the bank.

The dice in the Existing Orders boxes on the game board show the market demand for each type of locomotive.

When selling locomotives, reduce the `Existing Orders` dice by the number sold; see below for details. 

The seller receives payment from the bank according to the `Income` depicted on the locomotive card multiplied by the `Production Units`.

The players may sell their locomotives only if there are `Existing Orders` for that type of locomotive.

A player may sell no more of a certain type and generation of locomotive than what‘s shown on the highest die in the `Existing Orders` boxes of that locomotive. 

In addition, he may sell more than one locomotive type before the next player begins his sales.

Three different cases of locomotive sales are possible:

a) Same number:
The player has a number of locomotives of a certain type and generation (see the Production Unit counters) equal to the number shown on any 1 die in the `Existing Orders` boxes. In this case he has to choose this option. He may not select option b (see below).

Procedure:
The player sells all the produced units and moves that die from the `Existing Orders` box to a Customer Base box for that type of locomotive. Then, he places the Production Unit counters above the locomotive card in question.

b) Lower number:
The player does not have a number of locomotives equal to any of the dice showing in the `Existing Orders` area. Moreover, he has fewer locomotives than the face on the highest die.

Procedure:
The player sells all his produced units and reduces the number on the highest die by the units sold. He places the Production Unit counters above the locomotive card.

c) Larger number:
The player has more locomotives of a certain type and generation than the highest die showing in the `Existing Orders` area.

Procedure:
The player sells a number of produced units equal to the highest die and moves that die from the `Existing Orders` area to that locomotive‘s `Customer Base`. He then places the Production Unit counters above the locomotive card.

New selling round(s)
After each player has had an opportunity to sell, there may still be unsold locomotives for `Existing Orders`.

In this case, another selling round begins, following the procedure above.

Selling rounds continue until all locomotives have been sold or there is no demand anymore.

When all sales have been done, the players put their `Production Unit` counters back on their respective locomotive cards

---

Phase 4. Pay Taxes
During this phase, all players pay taxes in the sequence of play. They pay 10 % of their cash in taxes, rounded down, to the Bank.

Important:

If one or more players own 300 coins or more after paying taxes, then the game is over and players check who is the winner.

If the game doesn’t end, determine a new Player Order. The player with the least cash gets the “1” card, the player with the second lowest amount of cash receives the “2”, etc. In case of a tie, the tied players maintain the same relative player order.

---

5. Market Demands

In this phase, new `Existing Orders` for marketable locomotives are determined and `Existing Orders` for old and obsolete locomotives are cancelled. The current start player performs this task. It consists of four steps, each step dedicated to one locomotive type:

1. Market for Passenger locomotives (green) 
2. Market for Fast locomotives (red)
3. Market for Freight locomotives (yellow) 
4. Market for Special locomotives (blue)

Determine how many generations of that locomotive type currently exist. A generation exists if there are dice in either the `Existing Orders` boxes or the `Customer Base` boxes or in both.

The maximum number of dice for a locomotive type and generation is determined by the number of boxes in the `Customer Base`.

The current number of dice for a locomotive type and generation is determined by the number of dice in the `Customer Base` boxes added to any in the `Existing Orders` boxes.

There are 4 cases of existing generations: 
a) No generation exists:
Nothing is done for this type.

b) 1 generation exists:
If this locomotive type does not have the maximum number of dice, add one die to the `Customer Base` from the dice pool. Then roll all dice in the `Customer Base` and place them in the empty `Existing Order` boxes for that locomotive type.

c) 2 generations exist:
The players begin with the older (lower generation number) locomotive.
Transfer one of the dice from the `Customer Base` to the dice pool.

Then roll any remaining dice in the `Customer Base` and place them in the empty Existing Order boxes for that locomotive. This locomotive is considered old.

The newer generation is now checked. If this locomotive type does not have the maximum number of dice, add 1 die to the `Customer Base` from the dice pool. Then the dice in the `Customer Base` are rolled and placed in the empty Existing Order boxes for that locomotive.

d) 3 generations exist:

The players begin with the oldest (lowest generation number) locomotive. Place all dice from the `Customer Base` and `Existing Orders` areas back in the dice pool. This locomotive is obsolete – there is no demand for this generation of that locomotive type anymore.

The players continue with the next (generation number) locomotive. If needed, add enough dice from the dice pool to the `Customer Base` to match the maximum number of dice for that locomotive. Then roll all dice in the `Customer Base` and place them in the empty `Existing Order` boxes for that locomotive.

Finally, the newest (highest generation number) loco- motive is checked. If this locomotive does not have the maximum number of dice, add 1 die to the `Customer Base` from the dice pool. Then all dice in the `Customer Base` are rolled and are placed in the empty `Existing Order` boxes for that locomotive type.

Repeat this procedure for all four locomotive types in the order stated above.
When the Market Demands phase is complete, the game continues with a new locomotive Development phase.

---

## End of game

The game ends when one or more players own 300 coins or more after paying taxes. The player owning the most money wins the game. If two or more players are tied, they win together.

