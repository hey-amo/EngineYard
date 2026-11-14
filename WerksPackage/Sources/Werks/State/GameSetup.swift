//
//  GameSetup.swift
//  Werks
//
//  Created by AD on 13/11/2026.
//


extension GameState {
    public static let playerRange = 3...5

    /// Builds the opening position (rulebook p.2).
    ///
    /// - 3–4 players: starting cash and a Green 1st card with 1 unit each;
    ///   3 dice in Green 1st Existing Orders; 1 initial die on Red 1st.
    /// - 5 players: starting cash, no cards; 1 initial die on Green 1st.
    /// - Turn order is a seeded shuffle.
    static func setUp(_ seats: [PlayerSetup], seed: UInt64, rules: GameRules) throws -> (GameState, [GameEvent]) {
        guard playerRange.contains(seats.count) else { throw GameError.invalidPlayerCount(seats.count) }
        var rng = SeededRandomNumberGenerator(seed: seed)
        var board = GameBoard()
        var events: [GameEvent] = []
        let greenFirst = 1, redFirst = 2
        let isFivePlayer = seats.count == 5

        var players = seats.enumerated().map { index, seat in
            Player(id: index, name: seat.name, avatar: seat.avatar, isAI: seat.isAI)
        }
        let bank = Bank(playerCount: seats.count, startingCoins: rules.startingCoins(playerCount: seats.count))

        if isFivePlayer {
            let die = rng.rollDie()
            board[greenFirst].placeInitialOrder(die)
            events.append(.initialOrderPlaced(locomotiveID: greenFirst, die: die))
        } else {
            for index in players.indices {
                try players[index].hand.add(LocomotiveCard(locomotiveID: greenFirst))
                board[greenFirst].availableCardCount -= 1
                events.append(.startingLocomotiveGiven(playerID: index, locomotiveID: greenFirst))
            }
            let dice = (0..<3).map { _ in rng.rollDie() }
            board[greenFirst].existingOrders = dice
            board[greenFirst].rust = .available
            events.append(.existingOrdersPlaced(locomotiveID: greenFirst, dice: dice))

            let die = rng.rollDie()
            board[redFirst].placeInitialOrder(die)
            events.append(.initialOrderPlaced(locomotiveID: redFirst, die: die))
        }

        let order = rng.shuffle(Array(players.indices))
        var state = GameState(rules: rules, players: players, bank: bank, turnOrder: order, board: board, rng: rng)
        events.insert(.gameStarted(seed: seed, turnOrder: order), at: 0)
        state.enter(.development, events: &events)
        return (state, events)
    }
}
