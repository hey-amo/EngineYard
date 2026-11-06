//
//  Test.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import XCTest


@testable import Werks

@MainActor
private final class DummyPlayer: WalletObserver {
    public private(set) var coins: Int
    
    init(coins: Int = 0) {
        self.coins = coins
    }
    
    func coinBalanceDidUpdate(to balance: Int) async {
        self.coins = balance
    }
}

private actor BalanceObserverSpy: WalletObserver {
    private var updates: [Int] = []

    func coinBalanceDidUpdate(to balance: Int) async {
        updates.append(balance)
    }

    func recordedUpdates() -> [Int] {
        updates
    }
}

final class PlayerCoinBalanceTests: XCTestCase {
    
    func testObserverIsNotRetainedByBalanceActor() async throws {
        weak var weakObserver: BalanceObserverSpy?
        var observer: BalanceObserverSpy? = BalanceObserverSpy()

        weakObserver = observer
        let wallet = try Wallet(10,
            observer: observer
        )

        XCTAssertNotNil(weakObserver)

        // The actor remains alive, but should not keep the observer alive.
        observer = nil
        XCTAssertNil(weakObserver)

        let balance = await wallet.balance
        XCTAssertEqual(balance, 10)
    }

        
    func testAddAndSubtractUpdateBalanceAndNotifyObserver() async throws {
        let observer = BalanceObserverSpy()
        let wallet = try Wallet(10, observer: observer)

        let afterAdd = try await wallet.perform(.add(5))
        let afterSubtract = try await wallet.perform(.subtract(3))
        let finalBalance = await wallet.balance
        let updates = await observer.recordedUpdates()

        XCTAssertEqual(afterAdd, 15)
        XCTAssertEqual(afterSubtract, 12)
        XCTAssertEqual(finalBalance, 12)
        XCTAssertEqual(updates, [15, 12])
    }

    func testAdditionSaturatesAtIntMax() async throws {
        let wallet = try Wallet(Int.max - 1)

        let result = try await wallet.perform(.add(10))

        XCTAssertEqual(result, Int.max)
    }

    func testSubtractingMoreThanBalanceThrowsAndDoesNotChangeBalance() async throws {
        let wallet = try Wallet(4)

        do {
            _ = try await wallet.perform(.subtract(5))
            XCTFail("Expected insufficient-funds error")
        } catch let error as CoinBalanceError {
            XCTAssertEqual(
                error,
                .insufficientFunds(requested: 5, available: 4)
            )
        }

        let balance = await wallet.balance
        XCTAssertEqual(balance, 4)
    }

    func testNegativeTransactionAmountThrows() async throws {
        let wallet = try Wallet(4)

        do {
            _ = try await wallet.perform(.add(-1))
            XCTFail("Expected negative-amount error")
        } catch let error as CoinBalanceError {
            XCTAssertEqual(error, .negativeAmount(-1))
        }
    }

    func testNegativeInitialBalanceThrows() {
        XCTAssertThrowsError(try Wallet(-1)) { error in
            XCTAssertEqual(error as? CoinBalanceError, .negativeAmount(-1))
        }
    }
    
    // Test against a player object
    func testPlayerDidAddCoins() async throws {
        let player = await DummyPlayer(coins: 100)
            let processor = try await Wallet(
                player.coins,
                observer: player
            )

            _ = try await processor.perform(.add(25))
            let coinsAfterAdd = await player.coins
            XCTAssertEqual(coinsAfterAdd, 125)

            _ = try await processor.perform(.subtract(10))
            let coinsAfterSubtract = await player.coins
            XCTAssertEqual(coinsAfterSubtract, 115)
        
        print ("Coins: \(await player.coins)")
    }
}
