//
//  CapacityRules.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

//  Phase 2 – Production Capacity. A player may take any number of buy/shift actions on their turn, then passes.
//  Coordinates Bank (cost) and ProductionManager (units) and Hand (discard).
//

extension GameState {
    /// Cost of buying `units` new units, after validating the purchase.
    func validateBuyCapacity(_ locomotiveID: Int, units: Int, by playerID: Int) throws -> Int {
        guard phase == .capacity else { throw GameError.wrongPhase(phase) }
        guard let definition = Catalogue.definition(for: locomotiveID) else {
            throw GameError.unknownLocomotive(locomotiveID)
        }
        guard units > 0 else { throw GameError.invalidUnitCount(units) }
        guard players[playerID].hand.contains(locomotiveID) else { throw GameError.locomotiveNotOwned(locomotiveID) }
        guard board[locomotiveID].rust != .obsolete else { throw GameError.locomotiveObsolete(locomotiveID) }
        let cost = definition.productionCost * units
        try bank.requireFunds(cost, from: playerID)
        return cost
    }

    /// Cost of shifting `units` from one card to a newer one, after validation.
    /// "Newer technology" means a higher board ID (see rulebook example:
    /// Green 4th → Yellow 3rd is an upgrade).
    func validateShiftCapacity(from source: Int, to target: Int, units: Int, by playerID: Int) throws -> Int {
        guard phase == .capacity else { throw GameError.wrongPhase(phase) }
        guard let sourceDefinition = Catalogue.definition(for: source) else { throw GameError.unknownLocomotive(source) }
        guard let targetDefinition = Catalogue.definition(for: target) else { throw GameError.unknownLocomotive(target) }
        guard units > 0 else { throw GameError.invalidUnitCount(units) }
        guard target > source else { throw GameError.cannotShiftDown(from: source, to: target) }
        let hand = players[playerID].hand
        guard let card = hand.card(source) else { throw GameError.locomotiveNotOwned(source) }
        guard hand.contains(target) else { throw GameError.locomotiveNotOwned(target) }
        guard board[target].rust != .obsolete else { throw GameError.locomotiveObsolete(target) }
        guard card.production.units >= units else {
            throw GameError.notEnoughUnits(requested: units, available: card.production.units)
        }
        let cost = (targetDefinition.productionCost - sourceDefinition.productionCost) * units
        try bank.requireFunds(cost, from: playerID)
        return cost
    }

    mutating func buyCapacity(_ locomotiveID: Int, units: Int, events: inout [GameEvent]) throws {
        guard let playerID = currentPlayerID else { throw GameError.wrongPhase(phase) }
        let cost = try validateBuyCapacity(locomotiveID, units: units, by: playerID)
        let receipt = try bank.charge(cost, from: playerID,
                                      for: .productionCapacity(locomotiveID: locomotiveID, units: units))
        try ProductionManager.addUnits(units, to: locomotiveID, in: &players[playerID].hand)
        events.append(.transaction(receipt))
        events.append(.capacityBought(playerID: playerID, locomotiveID: locomotiveID, units: units))
    }

    /// Moves units up the board. A source card left with no units is removed
    /// from play (and cannot be developed again by this player).
    mutating func shiftCapacity(from source: Int, to target: Int, units: Int, events: inout [GameEvent]) throws {
        guard let playerID = currentPlayerID else { throw GameError.wrongPhase(phase) }
        let cost = try validateShiftCapacity(from: source, to: target, units: units, by: playerID)
        let receipt = try bank.charge(cost, from: playerID,
                                      for: .shiftCapacity(from: source, to: target, units: units))
        let emptied = try ProductionManager.transfer(units, from: source, to: target, in: &players[playerID].hand)
        events.append(.transaction(receipt))
        events.append(.capacityShifted(playerID: playerID, from: source, to: target, units: units))
        if emptied {
            try players[playerID].hand.remove(source)
            events.append(.cardDiscarded(playerID: playerID, locomotiveID: source))
        }
    }
}
