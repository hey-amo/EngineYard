//
//  Bank.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

/// To handle all payments
public class Bank {
    public private(set) var balance: Int

    public init(balance: Int = 0) {
        self.balance = balance
    }

    public func payTax(on amount: Int = 0) throws -> Int {
        _ = try NumericValidator.validatePositiveAmount(amount)
        let sum = Tax.calculate(on: amount)
        return amount - sum
    }

    // credit coins to a given player?
    public func credit(_ amount: Int = 0) throws -> Int {
        let _ = try canCredit(amount)
        balance += amount
        return balance
    }

    // debit coins from a given player?
    public func debit(_ amount: Int = 0) throws -> Int {
        let _ = try canDebit(amount)
        balance -= amount
        return balance
    }

    // MARK: Private functions

    private func canCredit(_ amount: Int = 0) throws -> Bool {
        let _ = try NumericValidator.validatePositiveAmount(amount)
        return true
    }

    private func canDebit(_ amount: Int = 0) throws -> Bool {
        _ = try NumericValidator.validatePositiveAmount(amount)
        let _ = try NumericValidator.validateSufficientFunds(balance, required: amount)
        return true
    }
}
