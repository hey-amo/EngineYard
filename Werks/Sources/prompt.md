You are an expert Swift developer with a decade's worth of experience in Swift development, and write clean, modular, and production-quality code that aligns with Apple’s best practices as per the following hyperlinks:

@docs: https://developer.apple.com/documentation
@docs: https://developer.apple.com/design/human-interface-guidelines/
@design: The visual style will use Google Material design where possible

You will help me program a turn-based board game using Swift 5.x, SwiftUI in Modern iOS, with Swift Concurrency.

for targets:
- iOS, iPad, Mac, AppleTV
- TODO: iPhone Duo (not to be done yet)
- Phase 1: (This project: deliver working iOS app project)

Game play supports offline mode only.
- pass and play
- verses bots
- DOES not support: online play

Ensure that:
* Code uses SOLID principles wherever possible.
* You provide comments to explain each part of the architecture.
* The code is concise, avoiding unnecessary complexity.
* Views will be seperated into partials where possible, to keep views clean

-------

## 🚂 Locomotive Werks Game
 
 - 3 to 5 players
 - Most money wins
 
-------
 
## Components:
 
 - 1 Game board
    - 14 board spaces (linear sequence)
        1. Green: 1st Gen, Cost: $4, Production: 2, Income: 1, 3 dice boxes
        2. Red: 1st Gen, Cost: $8, Prod: 4, Income: 2, 3 dice boxes)
        3. Yellow: 1st Gen, Cost: $12, Prod: 6, Income: 3, 2 dice boxes
        4. Blue: 1st Gen, Cost: $16, Prod: 8, Income: 4, 1 dice boxes
        5. Green: 2nd Gen, Cost: $20, Prod: 10, Income: 5, 4 dice boxes
        6. Red: 2nd Gen, Cost: $24, Prod: 12, Income: 6, 3 dice boxes
        7. Yellow: 2nd Gen, Cost: $28, Prod: 14, Income: 7, 3 dice boxes
        8. Green: 3rd Gen,  Cost: $32, Prod: 16, Income: 8, 4 dice boxes
        9. Blue: 2nd Gen, Cost: $36, Prod: 18, Income: 9, 2 dice boxes
        10. Red: 3rd Gen, Cost: $40, Prod: 20, Income: 10, 4 dice boxes
        11. Green: 4th Gen, Cost: $44, Prod: 22, Income: 11, 5 dice boxes
        12. Yellow: 3rd Gen, Cost: $48, Prod: 24, Income: 12,  3 dice boxes
        13. Red: 4th Gen, Cost: $52, Prod: 26, Income: 13, 4 dice boxes
        14. Green: 5th Gen, Cost: $56, Prod: 28, Income: 14, 5 dice boxes
 - 43 Locomotive cards
    - 20 Passenger locomotives (green)
        - (4 First Generation, 4 Second Generation, 4 Third Generation, 4 Fourth Generation, 4 Fifth Generation)
    - 13 Fast locomotives (red)
        - (3 First Generation, 3 Second Generation, 3 Third Generation, 4 Fourth Generation)
    - 7 Freight locomotives (yellow)
        - (2 First Generation, 2 Second Generation, 3 Third Generation)
    - 3 Special locomotives (blue)
        - 1 First Generation, 2 Second Generation)
 - 5 Turn order cards (1-5)
 - 80 Production counters (Fixed value of 1 or 2)
 - Money/Coins
 
-------
 
## Objective of the game

 Players assume the role of engineers, constructing and producing more and more advanced locomotives.
 By selling the locomotives, the players try to gain as much money as possible.
 
 When the game ends when 1 or more players has more than 330 coins.
 
 The winner of the game is the player with the most coins.
 
 Werks is played over a number of rounds.
 
## Setup

In a 3 or 4 player game, 
- Each player gets $12, and 1x Green 1st generation Locomotive card with 1x Production unit on it (Production value: 1)
- Roll 3 dice, place in the first existing orders of the 1st generation Green Locomotive on the main game board
- Roll 1 dice, and place it the initial orders of the 1st generation Red Locomotive

In a 5 player game, each player gets: $14
- No-one starts with any cards
- Roll 1 dice only and place it in the initial orders of the 1st Generation Green Locomotive
 

## Rounds

 Each round consists of the following phases; in each phase players perform their turn in Player Order:
 
 ## 1. Locomotive Development
This decision is optional. A player may skip this step.

Each player, in turn order, may develop 1 new locomotive.
A player can only ever have a maximum 1 of each `locomotive card`.
When locomotives are marked as `obsolete`, the card cannot be purchased. 

During this phase each player may develop only 1 locomotive – however, they are not obliged to do so and may pass.
When developing a locomotive the player must pay its development costs to the Bank. A player may develop only a locomotive that has either 1 die in the Initial Orders area or one or more dice in the Existing Orders boxes.

Additionally, the player may develop a locomotive only if it has an available locomotive card. Furthermore, each player may develop each locomotive only once.

If the player has already developed that locomotive, he may not develop it again. For example, Pete already has a First Generation Freight locomotive. He may not develop another First Generation Freight locomotive.

After a player has developed a locomotive, he takes the corresponding locomotive card and places it face up in front of himself, then takes one Production Unit counter from the game board and places it on the locomotive card, with side “1” face up.

Additionally, if the developed locomotive was the most advanced (i.e., it had a die in the Initial Orders area), then the player slides the die from the `Initial Orders` area to one of the `Existing Orders` boxes for that locomotive without changing the face of the die. He then rolls a new die and places it in the `Initial Orders` area of the next locomotive on the game board (the next locomotive always being the next connected one).

When the `Third`, `Fourth` or `Fifth` Generation of a certain locomotive type is brought into play, remove any un-purchased locomotive cards of that type that are two generations older from the game board.

---------

## 2. Production Capacity
Each player, in turn order, may expand his production capacities. This decision is optional and may skip this step.

During this phase, each player may purchase additional production capacity for his locomotive production. In addition, a player may shift Production Units from older technology locomotive cards to newer technology locomotive cards.
The amount of production capacity the player may purchase or shift is not limited – as long as he can pay the costs.
When purchasing new production capacity, the player must pay the production costs to the bank; he then takes the appropriate counter(s) and places it (or them) on the locomotive card.
When shifting production capacities from older technology cards to newer technology cards, the player simply transfers the Production Unit counters from one locomotive card to the other. In addition, he must pay the difference of production costs to the Bank.
Important:
A player may only upgrade Production Capacities, i.e., he cannot shift capacities from newer technology cards to older technology cards! Trade-ins are not allowed.
(A player may not trade 2 Production Units of a First Generation Passenger locomotive for 1 Production Unit of a First Generation Fast locomotive.)

Production Units may not be sold to another player or to the Bank.
If – after shifting capacities – a locomotive card has no Production Units, remove it from play immediately.

---------
 
 ## 3. Locomotive Production
 This step is mandatory.
 
 Each player, in turn order, sells locomotive (they sell production units)
 
 During this phase, the players sell their produced locomotives. They receive the money for their sold locomotives from the bank.
 
The dice in the `Existing Orders` boxes on the game board show the market demand for each type of locomotive.

When selling locomotives, reduce the `Existing Orders` dice by the number sold; see below for details. The seller receives payment from the bank according to the Income depicted on the locomotive card multiplied by the Production Units.

The players may sell their locomotives only if there are Existing Orders for that type of locomotive.

A player may sell no more of a certain type and gene- ration of locomotive than what‘s shown on the highest die in the Existing Orders boxes of that locomotive. In addition, he may sell more than one locomotive type before the next player begins his sales.

Three different cases of locomotive sales are possible:

a) Same number:
The player has a number of locomotives of a certain type and generation (see the Production Unit coun- ters) equal to the number shown on any 1 die in the `Existing Orders` boxes. In this case he has to choose this option. He may not select option b (see below).
Procedure:
The player sells all the produced units and moves that die from the `Existing Orders` box to a `Customer Base` box for that type of locomotive. Then, he places the Production Unit counters above the locomotive card in question.

b) Lower number:
The player does not have a number of locomotives equal to any of the dice showing in the Existing Orders area. Moreover, he has fewer locomotives than the face on the highest die.
Procedure:
The player sells all his produced units and reduces the number on the highest die by the units sold. He places the Production Unit counters above the locomotive card.

c) Larger number:
The player has more locomotives of a certain type and generation than the highest die showing in the Existing Orders area.
Procedure:
The player sells a number of produced units equal to the highest die and moves that die from the `Existing Orders` area to that locomotive‘s Customer Base. He then places the Production Unit counters above the locomotive card.

New selling round(s)
After each player has had an opportunity to sell, there may still be unsold locomotives for `Existing Orders`.
In this case, another selling round begins, following the procedure above.

Selling rounds continue until all locomotives have been sold or there is no demand anymore.
When all sales have been done, the players put their Production Unit counters back on their respective locomotive cards

---------
 
 
 ## 4. Pay Taxes
This step is mandatory.
 All players must pay taxes.
 

During this phase, all players pay taxes in the sequence of play. They pay 10 % of their cash in taxes, rounded down, to the Bank.

After paying taxes, if at least one player has 330 coins, then the game ends (SEE GAME END); otherwise determine the new Player Order.

If the game doesn’t end, determine a new Player Order. The player with the least cash gets the “1” card, the player with the second lowest amount of cash receives the “2”, etc. In case of a tie, the tied players maintain the same relative player order.

 
 ## 5. Market Demands
  This step is mandatory.
 Players determine Market Demands. Subsequently the next game round starts.


In this phase, new Existing Orders for marketable locomotives are determined and Existing Orders for old and obsolete locomotives are cancelled. The current start player performs this task. It consists of four steps, each step dedicated to one locomotive type:
1. Market for Passenger locomotives (green) 2. Market for Fast locomotives (red)
3. Market for Freight locomotives (yellow) 4. Market for Special locomotives (blue)
Determine how many generations of that locomotive type currently exist. A generation exists if there are dice in either the Existing Orders boxes or the Customer Base boxes or in both.
The maximum number of dice for a locomotive type and generation is determined by the number of boxes in the Customer Base.
The current number of dice for a locomotive type and generation is determined by the number of dice in the Customer Base boxes added to any in the Existing Orders boxes.


There are 4 cases of existing generations: a) No generation exists:
Nothing is done for this type.
b) 1 generation exists:
If this locomotive type does not have the maximum number of dice, add one die to the `Customer Base` from the dice pool. Then roll all dice in the Customer Base and place them in the empty `Existing Order` boxes for that locomotive type.
c) 2 generations exist:
The players begin with the older (lower generation number) locomotive.
Transfer one of the dice from the `Customer Base` to the dice pool.
Then roll any remaining dice in the `Customer Base` and place them in the empty `Existing Order` boxes for that locomotive. This locomotive is considered old.
The newer generation is now checked. If this locomotive type does not have the maximum number of dice, add 1 die to the `Customer Base` from the dice pool. Then the dice in the `Customer Base` are rolled and placed in the empty Existing Order boxes for that locomotive.
d) 3 generations exist:
The players begin with the oldest (lowest generation number) locomotive. Place all dice from the Custo- mer Base and Existing Orders areas back in the dice pool. This locomotive is obsolete – there is no demand for this generation of that locomotive type anymore.
The players continue with the next (middle genera- tion number) locomotive. If needed, add enough dice from the dice pool to the `Customer Base` to match the maximum number of dice for that locomotive. Then roll all dice in the `Customer Base` and place them in the empty `Existing Order` boxes for that locomotive.
Finally, the newest (highest generation number) locomotive is checked. If this locomotive does not have the maximum number of dice, add 1 die to the `Customer Base` from the dice pool. Then all dice in the `Customer Base` are rolled and are placed in the empty `Existing Order` boxes for that locomotive type.
Repeat this procedure for all four locomotive types in the order stated above.
When the Market Demands phase is complete, the game continues with a new locomotive Development phase.


---------

# GAME END

Game ends when 1 player has 330 coins.
Player with the most cash wins.
In a tie, the victory is shared and all tied players wins.

-------

# Game in detail

- The game board is made up of 14 `spaces` in linear sequential order. This order never changes.
- The game has 43 cards. These cards are never modified.
- The game has 3-5 players.
- Each player can hold 0 to many cards in their hand.

The `Werks-board.csv` file lists all 14 locomotives in the game.
The `Werks-cards.csv` file lists all 43 cards in the game.

Each game `space` on the game `board` has the following information:

- Name (string), 
- Color,
- Generation, 
- Cost (Int) (the cost to design the locomotive), 
- Production Cost, (the cost to produce the locomotive)
- Income, (the income made when selling the locomotive)
- Existing orders (An array of D6: Integer), 
- Filled orders (An array of D6: Integer), 
- Initial orders (Integer. This may be -1; if so; that means that no initial orders have been defined and is considered is null/empty).
- Rust: Enum: Int { unavailable, active, rusting, obsolete }

-------

Understanding board.csv

- Where `pool`, this is how many copies of that specific locomotive exists
- Where `max dice` refers to the maximum amount of dice that existing orders and filled orders total (ie: existing orders + filled orders can never exceed this number)
- DicePool means = max dice.

-------

The `game board` is a collection of `spaces` in a linear sequence

```[space] -> [space] -> [space], etc.```

Where each space is a `locomotive`:

## Locomotive data

1. LocomotiveID: Int *immutable*
2. LocomotiveName: String  *immutable*
3. Color: Color: Int  *immutable*
4. Generation: Generation: Int  *immutable*
5. Cost: Cost: Int  *immutable*
6. Production Cost: ProductionCost: Int *Always cost / 2 - rounded up*
7. Income: Income: Int  *Always productionCost / 2 - rounded up*
8. DicePool: Int 
10. InitialOrders: Int
11. ExistingOrders: Array: Int
12. FilledOrders: Array: Int
13. Rust: Enum: Int { unavailable, active, rusting, obsolete }

--

## Players

Players have:

- Name (String)
- Avatar (String)
- Coins (Int)
- Hand, A Portfolio  of Locomotive Cards (Array: Locomotive Cards)
- Status (Enum: Idle, OnTurn)
- isAI (Bool)
- isOnTurn (Bool)

--

# Expected game screens

- MainMenu
- PlayerSelectScreen
- Phase1_BuyLocomotiveScreen
- Phase2_BuyLocomotiveProductionScreen
- Phase3_SellLocomotivesScreen
- Phase4_PayTaxesScreen
- Phase5_MarketDemandsScreen
- GameMessageLog (A list of in-game messages, latest first)
- Winner_Screen
- Generic_MessageScreen
- PauseMenuScreen
- GameSettingsScreen
- OnboardingScreens

 ---
 
 # 🚂 Train Manifest

 | **ID** | **Name** | **Colour** | **Cost** | **Colour Code** | **Gen** | **Pool** | **Dice** |
 |:------:|:----------------------------|:-----------|:--------:|:----------------:|:-------:|:--------:|:--------:|
 | 1  | General I (4-2-1)          | Green  | 4  | 1 | 1 | 4 | 3 |
 | 2  | Fast Freight I (8-4-2)     | Red    | 8  | 2 | 1 | 3 | 3 |
 | 3  | Heavy I (12-6-3)           | Yellow | 12 | 3 | 1 | 2 | 2 |
 | 4  | Special I (16-8-4)         | Blue   | 16 | 4 | 1 | 1 | 2 |
 | 5  | General II (20-10-5)       | Green  | 20 | 1 | 2 | 4 | 4 |
 | 6  | Fast Freight II (24-12-6)  | Red    | 24 | 2 | 2 | 3 | 3 |
 | 7  | Heavy II (28-14-7)         | Yellow | 28 | 3 | 2 | 2 | 3 |
 | 8  | General III (32-16-8)      | Green  | 32 | 1 | 3 | 4 | 4 |
 | 9  | Special II (36-18-9)       | Blue   | 36 | 4 | 2 | 2 | 2 |
 | 10 | Fast Freight III (40-20-10)| Red    | 40 | 2 | 3 | 3 | 4 |
 | 11 | General IV (44-22-11)      | Green  | 44 | 1 | 4 | 4 | 4 |
 | 12 | Heavy III (48-24-12)       | Yellow | 48 | 3 | 3 | 3 | 3 |
 | 13 | Fast Freight IV (52-26-13) | Red    | 52 | 2 | 4 | 4 | 4 |
 | 14 | General V (56-28-14)       | Green  | 56 | 1 | 5 | 4 | 5 |
 ------------------------------------


