import XCTest

@testable import Werks

final class ProductionHandlerTests: XCTestCase {
    func test_addUnits_updatesLocomotiveCard_viaReadableProtocol() throws {
        let card: ProductionUnitReadable = LocomotiveCard(id: 1, locomotiveID: 1)
        let handler = ProductionHandler()

        try handler.addUnits(1, to: card)

        guard let card = card as? LocomotiveCard else {
            XCTFail("Expected card to remain a LocomotiveCard")
            return
        }

        XCTAssertEqual(card.productionUnits, 1)
        XCTAssertEqual(card.productionUnitsSpent, 0)
    }

    func test_spendAndResetUnits_updateCardState() throws {
        let card = LocomotiveCard(id: 2, locomotiveID: 2)
        let handler = ProductionHandler()

        try card.addProductionUnits(5)
        try handler.spendUnits(2, from: card)
        XCTAssertEqual(card.productionUnits, 3)
        XCTAssertEqual(card.productionUnitsSpent, 2)

        handler.resetUnits(for: card)
        XCTAssertEqual(card.productionUnits, 5)
        XCTAssertEqual(card.productionUnitsSpent, 0)
    }
}
