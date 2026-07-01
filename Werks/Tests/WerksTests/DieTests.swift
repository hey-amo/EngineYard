import XCTest
@testable import Werks

final class DieTests: XCTestCase {
    func testD6ValidationAndAdjustment() {
        XCTAssertTrue(D6.isValid(3))
        XCTAssertFalse(D6.isValid(0))
        XCTAssertFalse(D6.isValid(7))

        XCTAssertEqual(D6.increment(3), 4)
        XCTAssertEqual(D6.increment(6), 6)
        XCTAssertEqual(D6.decrement(3), 2)
        XCTAssertEqual(D6.decrement(1), 1)
    }

    func testRollStaysInRange() {
        for _ in 0..<100 {
            let roll = D6.roll()
            XCTAssertTrue(D6.isValid(roll))
        }
    }
}
