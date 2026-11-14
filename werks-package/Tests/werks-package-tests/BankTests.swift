//
//  BankTests.swift
//  werks-package
//
//  Created by Amarjit on 14/11/2026.
//

import Foundation
import XCTest
@testable import werks_package

final class BankTests: XCTestCase {
    
    /// check we seed the balance
    func testOpeningBalances() {
        let bank = Bank(playerCount: 3, startingCoins: 12)
        XCTAssertEqual(bank.balances, [12, 12, 12])
        XCTAssertEqual(bank.balance(of: 1), 12)
    }

    /// check the recording of a transaction
    func testChargeReturnsReceipt() throws {
        var bank = Bank(playerCount: 2, startingCoins: 20)
        let receipt = try bank.charge(8, from: 1, for: .development(locomotiveID: 2))
        XCTAssertEqual(bank.balances, [20, 12])
        XCTAssertEqual(receipt, BankTransaction(playerID: 1, amount: -8,
                                                reason: .development(locomotiveID: 2), balanceAfter: 12))
    }

    /// checking refusing overdraft doesn't change bank amounts
    func testChargeRefusesOverdraftAndChangesNothing() {
        var bank = Bank(playerCount: 2, startingCoins: 5)
        XCTAssertGameError(try bank.charge(6, from: 0, for: .tax), .insufficientFunds(required: 6, available: 5))
        XCTAssertEqual(bank.balances, [5, 5])
    }

    /// check that we can charge the exact amount in balance
    func testChargeExactBalance() throws {
        var bank = Bank(playerCount: 1, startingCoins: 5)
        try bank.charge(5, from: 0, for: .tax)
        XCTAssertEqual(bank.balance(of: 0), 0)
    }

    /// check a payment has been made
    func testPay() {
        var bank = Bank(playerCount: 2, startingCoins: 0)
        let receipt = bank.pay(6, to: 0, for: .sale(locomotiveID: 2, units: 3))
        XCTAssertEqual(bank.balance(of: 0), 6)
        XCTAssertEqual(receipt.amount, 6)
        XCTAssertEqual(receipt.balanceAfter, 6)
    }

    /// collectTax rounds down
    func testTaxRoundsDown() {
        var bank = Bank(balances: [109, 9, 0])
        XCTAssertEqual(bank.collectTax(from: 0, percent: 10).amount, -10)
        XCTAssertEqual(bank.collectTax(from: 1, percent: 10).amount, 0)
        XCTAssertEqual(bank.collectTax(from: 2, percent: 10).amount, 0)
        XCTAssertEqual(bank.balances, [99, 9, 0])
    }

    /// canAfford (amount, playerID)
    func testCanAfford() {
        let bank = Bank(balances: [4])
        XCTAssertTrue(bank.canAfford(4, 0))
        XCTAssertFalse(bank.canAfford(5, 0))
    }
}
