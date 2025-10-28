//
//  CardPrototype
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

// Prototype registry (loaded once from CSVs)
final class PrototypeRepository {
    private(set) var specsByID: [Int: LocomotiveSpec] = [:]

    init(specs: [LocomotiveSpec]) {
        specsByID = Dictionary(uniqueKeysWithValues: specs.map { ($0.id, $0) })
    }

    func spec(for id: Int) -> LocomotiveSpec? { specsByID[id] }
}


/**


// Example lookups / usage
func exampleUsage(repo: PrototypeRepository, state: GameState) {
    let space = state.board[0]                        // first board space
    if let spec = repo.spec(for: space.prototypeID) {
        print("Space[0] is \(spec.name) cost:\(spec.cost)")
    }

    // Find all card instances that match this board space's prototype
    let cardsForSpace = state.cardInstances.filter { $0.prototypeID == space.prototypeID }

    // Find pool cards (not owned) of this prototype
    let poolCards = cardsForSpace.filter { $0.ownerPlayerID == nil }

    // Example: move production units between two CardInstances
    // (validate via engine rules; shown here conceptually)
    if let from = state.cardInstances.first(where: { $0.ownerPlayerID != nil && $0.productionUnits > 0 }),
       let to = state.cardInstances.first(where: { $0.ownerPlayerID == from.ownerPlayerID && $0.prototypeID > from.prototypeID }) {
        // engine.validateMoveProduction(from: from.id, to: to.id, amount: 1) ...
    }
}

**/