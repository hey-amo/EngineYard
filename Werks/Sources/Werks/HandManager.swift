import Foundation

/// Handles a player's hand of cards - Push, Pop, etc
public enum HandManagerError: Error {
    case cardAlreadyInHand
    case cardNotInHand
}

extension HandManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cardAlreadyInHand:
            return NSLocalizedString("The card is already in the player's hand.", comment: "")
        case .cardNotInHand:
            return NSLocalizedString("The card is not in the player's hand.", comment: "")
        }
    }
}

/// Manages a player's hand of LocomotiveCards
/// add, remove, check if card exists, etc
public class HandManager {
    
    public init() {}

    public func addCard(_ card: LocomotiveCard, to hand: inout [LocomotiveCard]) throws{
        // Check if the card already exists in the hand
        guard canAddCard(card, to: hand) else {
            throw HandManagerError.cardAlreadyInHand
        }   
        hand.append(card)
    }

    public func removeCard(_ card: LocomotiveCard, from hand: inout [LocomotiveCard]) throws {
        // Check if the card exists in the hand
        guard canRemoveCard(card, from: hand) else {
            throw HandManagerError.cardNotInHand
        }
        hand.removeAll { $0.id == card.id }
    }

    public func canAddCard(_ card: LocomotiveCard, to hand: [LocomotiveCard]) -> Bool {
        let alreadyHasSameCard = hand.contains { $0.id == card.id }
        let alreadyHasSameParentLocomotive = hand.contains { $0.locomotiveID == card.locomotiveID }

        return !alreadyHasSameCard && !alreadyHasSameParentLocomotive
    }

    public func canRemoveCard(_ card: LocomotiveCard, from hand: [LocomotiveCard]) -> Bool {
        // Check if the card exists in the hand
        return hand.contains(where: { $0.id == card.id })
    }
}