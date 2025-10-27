//
//  BankTests.swift
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Testing

@testable import Werks

struct BankTests {

    // Test: Credit a negative value should throw
    @Test func testCredit_NegativeValue_ShouldThrow() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 100)

        do {
            try bank.credit(-10, to: account)
        } catch {
            let err = error as? BankError
            #expect(err != nil)
            if let err = err {
                if case let .invalidAmount(value) = err {
                    #expect(value == -10)
                } else {
                    throw err
                }
            }
        }
    }
    
    // Test: Debit a negative value should throw
    @Test func testDebit_NegativeValue_ShouldThrow() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 100)

        do {
            try bank.debit(-5, from: account)
        } catch {
            let err = error as? BankError
            #expect(err != nil)
            if let err = err {
                if case let .invalidAmount(value) = err {
                    #expect(value == -5)
                } else {
                    throw err
                }
            }
        }
    }

    // Test: Debit a value which will result in a negative value should throw
    @Test func testDebit_NegativeResult_ShouldThrow() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 50)

        do {
            try bank.debit(60, from: account)
        } catch {
            let err = error as? BankError
            #expect(err != nil)
            if let err = err {
                if case .insufficentFunds = err {
                    #expect(true)
                } else {
                    throw err
                }
            }
        }
    }
    
    // Test: didCredit coins
    @Test func testDidCredit_Coins() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 0)

        do {
            try bank.credit(25, to: account)
            #expect(bank.getBalance(for: account) == 25)
        } catch let err {

            throw err
        }
    }
    
    // Test: didDebit coins and result >= 0
    @Test func testDidDebit_Coins() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 100)

        do {
            try bank.debit(30, from: account)
            #expect(bank.getBalance(for: account) == 70)
        } catch let err {
            throw err
        }
    }
    
    // Test: didDebit coins and result == 0
    @Test func testDidDebit_CoinsToZero() async throws {
        let bank = Bank()
        let account = Account(initialBalance: 50)

        
        do {
            try bank.debit(50, from: account)
            #expect(bank.getBalance(for: account) == 0)
        } catch let err {
            throw err
        }
    }
}
