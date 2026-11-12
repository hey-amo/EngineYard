//
//  GameEvent.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

/// What happened as a result of an action. Feed these to the message log.
/// All money movements appear as `.transaction`, issued only by the `Bank`.
public enum GameEvent: Codable, Equatable, Sendable, CustomStringConvertible {
    case gameStarted(seed: UInt64, turnOrder: [Int])
    case phaseStarted(GamePhase, round: Int)
    case transaction(BankTransaction)
    case initialOrderPlaced(locomotiveID: Int, die: Int)
    case existingOrdersPlaced(locomotiveID: Int, dice: [Int])
    case startingLocomotiveGiven(playerID: Int, locomotiveID: Int)
    case developed(playerID: Int, locomotiveID: Int)
    case initialOrderPromoted(locomotiveID: Int, die: Int)
    case cardsWithdrawn(locomotiveID: Int, count: Int)
    case passed(playerID: Int)
    case capacityBought(playerID: Int, locomotiveID: Int, units: Int)
    case capacityShifted(playerID: Int, from: Int, to: Int, units: Int)
    case cardDiscarded(playerID: Int, locomotiveID: Int)
    case sold(playerID: Int, locomotiveID: Int, units: Int, saleCase: SaleCase)
    /// All spent Production Units were put back on their cards.
    case productionReset
    case turnOrderChanged([Int])
    case dieReturned(locomotiveID: Int, die: Int)
    case customerDiceAdded(locomotiveID: Int, count: Int)
    case ordersRolled(locomotiveID: Int, dice: [Int])
    case rusting(locomotiveID: Int)
    case obsolete(locomotiveID: Int)
    case gameEnded(winners: [Int])

    public var description: String {
        func loco(_ id: Int) -> String { Catalogue.definition(for: id)?.name ?? "#\(id)" }
        switch self {
        case let .gameStarted(seed, order): return "Game started (seed \(seed)); turn order \(order)"
        case let .phaseStarted(phase, round): return "Round \(round): \(phase)"
        case let .transaction(receipt): return receipt.description
        case let .initialOrderPlaced(id, die): return "\(loco(id)) receives initial order \(die)"
        case let .existingOrdersPlaced(id, dice): return "\(loco(id)) receives existing orders \(dice)"
        case let .startingLocomotiveGiven(p, id): return "Player \(p) starts with \(loco(id))"
        case let .developed(p, id): return "Player \(p) develops \(loco(id))"
        case let .initialOrderPromoted(id, die): return "\(loco(id)) initial order \(die) moves to existing orders"
        case let .cardsWithdrawn(id, count): return "\(count) unsold \(loco(id)) card(s) withdrawn"
        case let .passed(p): return "Player \(p) passes"
        case let .capacityBought(p, id, units): return "Player \(p) adds \(units) unit(s) to \(loco(id))"
        case let .capacityShifted(p, from, to, units): return "Player \(p) shifts \(units) unit(s) \(loco(from)) → \(loco(to))"
        case let .cardDiscarded(p, id): return "Player \(p) discards empty \(loco(id))"
        case let .sold(p, id, units, saleCase): return "Player \(p) sells \(units) × \(loco(id)) (\(saleCase.rawValue))"
        case .productionReset: return "Production units return to their cards"
        case let .turnOrderChanged(order): return "New turn order \(order)"
        case let .dieReturned(id, die): return "\(loco(id)) returns a \(die) to the dice pool"
        case let .customerDiceAdded(id, count): return "\(loco(id)) gains \(count) customer die/dice"
        case let .ordersRolled(id, dice): return "\(loco(id)) new existing orders \(dice)"
        case let .rusting(id): return "\(loco(id)) is old (rusting)"
        case let .obsolete(id): return "\(loco(id)) is obsolete"
        case let .gameEnded(winners): return "Game over; winner(s) \(winners)"
        }
    }
}
