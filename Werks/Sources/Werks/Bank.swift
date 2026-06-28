//
//  Bank.swift
//  Werks
//
//  Created by Amarjit on 08/06/2026.
//

/// To handle all payments
public class Bank {
    public func payTax(on amount: Int = 0) throws -> Int {
        // Is it a valid number? : Throw validation error
        // Can we afford it?: Throw validation error
        var amount = amount
        guard amount > 0 else { return amount }
        let sum = Tax.calculate(on: amount)
        amount = amount - sum
        return amount
    }
    
    // credit coins to a given player?
    public func credit(_ amount: Int = 0) throws -> Int {
        do {
            let result: Bool = canCredit(amount)
        } catch {   
            fatalError("error thrown")
        }
    }
    
    // debit coins from a given player?
    public func debit(_ amount: Int = 0) -> Int {
        do {
            let result: Bool = canDebit(amount)
        } catch let err  : NumericValidator {
            throw err
        }
    }
    
    // MARK: Private functions
    
    private func canCredit(_ amount: Int = 0) throws -> Bool {
       // use try-catch to use the numberValidator to check amount is valid, throw if error
        return true
    }
    
    private func canDebit(_ amount: Int = 0) throws -> Bool {
        // use try-catch numberValidator only accept positiveNumber
        // use try-catch validateSufficientFunds only if this returns true
        // cannot debit a negative number
        // the result balance - amount cannot be negative
        return true
    }
}
