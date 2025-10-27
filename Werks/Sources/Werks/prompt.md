You are an expert Swift developer with a decade's worth of experience in Swift development, and write clean, modular, and production-quality code that aligns with Apple’s best practices as per the following hyperlinks:

- https://developer.apple.com/documentation
- https://developer.apple.com/design/human-interface-guidelines/

You will help me program a board game using Swift, SwiftUI

Ensure that:
* Code uses SOLID principles wherever possible.
* You provide comments to explain each part of the architecture.
* The code is concise, avoiding unnecessary complexity.
* Do not include unit tests in the code unless prompted.

--

This is a board game called "locomotive werks". 
This game will be written using Swift.

# Locomotive Werks Overview
 
 - 3 to 5 players
 - Most money wins
 
## Components:
 
 - 1 game board
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
 - 43 locomotive cards
    - 20 Passenger locomotives (green)
        - (4 First Generation, 4 Second Generation, 4 Third Generation, 4 Fourth Generation, 4 Fifth Generation)
    - 13 Fast locomotives (red)
        - (3 First Generation, 3 Second Generation, 3 Third Generation, 4 Fourth Generation)
    - 7 Freight locomotives (yellow)
        - (2 First Generation, 2 Second Generation, 3 Third Generation)
    - 3 Special locomotives (blue)
        - 1 First Generation, 2 Second Generation)
 - 5 Turn order cards (1-5)
 - 80 Production counters (Value: 1 or 2)
 - Money/Coins
 
--
 
## Objective of the game

 Players assume the role of engineers, constructing and producing more and more advanced locomotives.
 By selling the locomotives, the players try to gain as much profit as possible.
 
 When the game ends the player with the most money wins.
 
 Werks is played in rounds.
 
 Each round consists of the following phases; in each phase players perform their turn in Player Order:
 
 1. Locomotive Development
 Each player may develop 1 new locomotive.
 
 2. Production Capacity
 Each player may expand his production capacities.
 
 3. Locomotive Production
 Each player may produce and sell locomotives.
 
 4. Pay Taxes
 Each player must pay taxes.
 If at least one player has 300 coins or more after paying taxes, then the game ends; otherwise determine the new Player
 Order.
 
 5. Market Demands
 Players determine Market Demands. Subsequently the next game round starts.

--

# Game in detail

- The game board is made up of 14 `spaces` in linear sequential order. This order never changes
- The game has 43 cards. These cards are never modified.
- The game has 3-5 players.
- Each player can hold 0 to many cards in their hand.

The Werks-board.csv file lists all 14 locomotives in the game.
The Werks-cards.csv file lists all 43 cards in the game.

Each space on the game board has the following information:

- Name (string), 
- Color,
- Generation, 
- Cost (Int) (the cost to design the locomotive), 
- Production Cost, (the cost to produce the locomotive)
- Income, (the income made when selling the locomotive)
- Existing orders (An array of D6: Integer), 
- Filled orders (An array of D6: Integer), 
- Initial orders (Integer. This may be -1; if so; that means that no initial orders have been defined and is considered is null/empty).

--

Understanding board.csv

- Where pool, this is how many exists of that locomotive, and its also used to say how many cards there are.
- Where max dice refers to the maximum amount of dice that existing orders and filled orders total (ie: existing orders + filled orders can never exceed this number)

--

The `game board` is a collection of `spaces` in a linear sequence

```[space] -> [space] -> [space], etc.```

Where each space is a `locomotive`:

## Locomotive

1. LocomotiveID: Int
2. LocomotiveName: String
3. Color: Color: Int
4. Generation: Generation: Int
5. Cost: Cost: Int
6. Production Cost: ProductionCost: Int
7. Income: Income: Int
8. Pool: Int
9. MaxDice: Int
10. InitialOrders: Int
11. ExistingOrders: Array: Int
12. FilledOrders: Array: Int
13. Status: Enum: Int { unavailable, active, rusting, obsolete }

--

Items 1-10 are immutable.
Itms 11-15 may change.


## Locomotive cards

There are 43 `locomotive cards` (see: Components)

Locomotive card has the following information:

- Locomotive Name
- Locomotive Color
- Locomotive Generation
- Locomotive Cost
- Locomotive Production Cost
- Locomotive Income

You will notice that this shares information from the `Locomotive`.

A player can only ever have a maximum 1 of each `locomotive card`.

--

## Players

Players have:

- Name (String)
- Avatar (String)
- Coins (Int)
- Locomotive Cards (Array: Locomotive Cards)
- Status (Enum: Idle, OnTurn)
- isAI (Bool)
- isOnTurn (Bool)

--


