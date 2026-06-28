import Foundation

public protocol GameBoardConfig {
    func unlockNext()
}

public class GameBoard: GameBoardConfig {
    public var spaces: [Locomotive] = [Locomotive]() 
    public var cards: [LocomotiveCard] = []

    public init() {
        self.spaces = Locomotive.buildTrains()
        self.createCards()
    }

    private func createCards() {
         var cardID = 1
        
        for locomotive in spaces {
            // Use the trainPool number to create cards for this locomotive
            for _ in 0..<locomotive.trainPool {
                let card = LocomotiveCard(id: cardID, locomotiveID: locomotive.id)
                cards.append(card)
                cardID += 1
            }
        }
    }
    
    /// Returns the total number of cards created
    public var cardCount: Int {
        return cards.count
    }

    /// Unlocks next board space
    public func unlockNext() {
        // TBD
    }
}