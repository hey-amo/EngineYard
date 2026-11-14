//
//  CatalogueTests.swift
//  Werks
//
//  Created by AD on 12/11/2026.
//

import XCTest
@testable import WerksPackage


final class CatalogueTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFourteenSpacesInBoardOrder() {
            XCTAssertEqual(Catalogue.all.count, 14)
            XCTAssertEqual(Catalogue.all.map(\.id), Array(1...14))
            XCTAssertEqual(Catalogue.all.map(\.cost), stride(from: 4, through: 56, by: 4).map { $0 })
        }

        func testFortyThreeCards() {
            XCTAssertEqual(Catalogue.all.reduce(0) { $0 + $1.cardCount }, 43)
            func cards(_ livery: Livery) -> Int {
                Catalogue.all.filter { $0.livery == livery }.reduce(0) { $0 + $1.cardCount }
            }
            XCTAssertEqual(cards(.green), 20)
            XCTAssertEqual(cards(.red), 13)
            XCTAssertEqual(cards(.yellow), 7)
            XCTAssertEqual(cards(.blue), 3)
        }

        func testProductionCostAndIncomeFormulas() {
            for definition in Catalogue.all {
                XCTAssertEqual(definition.productionCost, (definition.cost + 1) / 2)
                XCTAssertEqual(definition.income, (definition.productionCost + 1) / 2)
            }
            XCTAssertEqual(Catalogue.definition(for: 1)?.productionCost, 2)
            XCTAssertEqual(Catalogue.definition(for: 1)?.income, 1)
            XCTAssertEqual(Catalogue.definition(for: 14)?.productionCost, 28)
            XCTAssertEqual(Catalogue.definition(for: 14)?.income, 14)
        }

        func testProductionCostStrictlyIncreasesAlongBoard() {
            let costs = Catalogue.all.map(\.productionCost)
            XCTAssertEqual(costs, costs.sorted())
            XCTAssertEqual(Set(costs).count, costs.count)
        }

        func testLookups() {
            XCTAssertNil(Catalogue.definition(for: 0))
            XCTAssertNil(Catalogue.definition(for: 15))
            XCTAssertEqual(Catalogue.nextID(after: 1), 2)
            XCTAssertEqual(Catalogue.nextID(after: 13), 14)
            XCTAssertNil(Catalogue.nextID(after: 14))
            XCTAssertEqual(Catalogue.definition(livery: .yellow, generation: .third)?.id, 12)
            XCTAssertNil(Catalogue.definition(livery: .blue, generation: .third))
        }

        func testFreshBoardIsUnavailableWithAllCards() {
            let board = GameBoard()
            for space in board.spaces {
                XCTAssertEqual(space.rust, .unavailable)
                XCTAssertNil(space.initialOrder)
                XCTAssertTrue(space.existingOrders.isEmpty)
                XCTAssertTrue(space.filledOrders.isEmpty)
                XCTAssertEqual(space.availableCardCount, space.definition.cardCount)
                XCTAssertFalse(space.isPurchasable)
            }
            XCTAssertEqual(board.spaces(of: .green).map(\.id), [1, 5, 8, 11, 14])
        }

}
