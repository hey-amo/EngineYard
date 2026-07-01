import XCTest
@testable import Werks

final class HandManagerTests: XCTestCase {
    func test_canAddCard_rejectsDuplicateParentLocomotive() throws {
        let manager = HandManager()
        let existingCard = LocomotiveCard(id: 1, locomotiveID: 10)
        let duplicateParentCard = LocomotiveCard(id: 2, locomotiveID: 10)
        let otherParentCard = LocomotiveCard(id: 3, locomotiveID: 11)

        var hand: [LocomotiveCard] = [existingCard]

        XCTAssertFalse(manager.canAddCard(duplicateParentCard, to: hand))
        XCTAssertTrue(manager.canAddCard(otherParentCard, to: hand))

        XCTAssertThrowsError(try manager.addCard(duplicateParentCard, to: &hand))
        XCTAssertEqual(hand.count, 1)
    }
}
