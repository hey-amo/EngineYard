//
//  DevelopmentRules.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//


///  Phase 1 – Locomotive Development.
///  Coordinates Board (supply/dice), Bank (cost) and Hand (card).
///

extension GameState {
    /// Throws the reason `playerID` may not develop `locomotiveID` right now.
    func validateDevelop(_ locomotiveID: Int, by playerID: Int) throws {
        guard phase == .development else { throw GameError.wrongPhase(phase) }
        guard let definition = Catalogue.definition(for: locomotiveID) else {
            throw GameError.unknownLocomotive(locomotiveID)
        }
        let space = board[locomotiveID]
        guard space.rust != .obsolete else { throw GameError.locomotiveObsolete(locomotiveID) }
        guard space.initialOrder != nil || space.isInMarket else {
            throw GameError.locomotiveUnavailable(locomotiveID)
        }
        guard space.availableCardCount > 0 else { throw GameError.noCardsAvailable(locomotiveID) }
        guard !players[playerID].hand.hasHeld(locomotiveID) else {
            throw GameError.alreadyDeveloped(locomotiveID)
        }
        try bank.requireFunds(definition.cost, from: playerID)
    }

    /// Develops a locomotive for the current player and ends their turn.
    ///
    /// On the first-ever purchase (the space holds the initial die) the die
    /// moves to Existing Orders unchanged, the next board space receives its
    /// one-and-only initial die, and for 3rd+ generations the unsold cards
    /// two generations older of the same livery are withdrawn.
    mutating func develop(_ locomotiveID: Int, events: inout [GameEvent]) throws {
        guard let playerID = currentPlayerID else { throw GameError.wrongPhase(phase) }
        try validateDevelop(locomotiveID, by: playerID)
        let definition = board[locomotiveID].definition

        let receipt = try bank.charge(definition.cost, from: playerID, for: .development(locomotiveID: locomotiveID))
        try players[playerID].hand.add(LocomotiveCard(locomotiveID: locomotiveID))
        board[locomotiveID].availableCardCount -= 1
        events.append(.transaction(receipt))
        events.append(.developed(playerID: playerID, locomotiveID: locomotiveID))

        if let die = board[locomotiveID].promoteInitialOrder() {
            events.append(.initialOrderPromoted(locomotiveID: locomotiveID, die: die))
            spawnInitialOrder(after: locomotiveID, events: &events)
            withdrawOutdatedCards(introducedBy: definition, events: &events)
        }
        endTurn(events: &events)
    }

    /// Gives the next board space its initial die, once, if nothing has happened to it yet.
    mutating func spawnInitialOrder(after locomotiveID: Int, events: inout [GameEvent]) {
        guard let nextID = Catalogue.nextID(after: locomotiveID),
              board[nextID].rust == .unavailable,
              board[nextID].initialOrder == nil else { return }
        let die = rng.rollDie()
        board[nextID].placeInitialOrder(die)
        events.append(.initialOrderPlaced(locomotiveID: nextID, die: die))
    }

    /// When a 3rd/4th/5th generation comes into play, remove the unsold cards
    /// of the same livery two generations older. Their dice are untouched.
    mutating func withdrawOutdatedCards(introducedBy definition: LocomotiveDefinition,
                                        events: inout [GameEvent]) {
        guard definition.generation >= .third,
              let olderGeneration = definition.generation.older(by: 2),
              let older = Catalogue.definition(livery: definition.livery, generation: olderGeneration)
        else { return }
        let count = board[older.id].availableCardCount
        guard count > 0 else { return }
        board[older.id].availableCardCount = 0
        events.append(.cardsWithdrawn(locomotiveID: older.id, count: count))
    }
}
