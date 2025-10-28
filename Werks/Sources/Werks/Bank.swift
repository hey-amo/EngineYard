//
//  Bank.swift
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

// Protocol for anything that can have a balance managed by the bank
public protocol Bankable {
    var balance: Int { get set }
    func updateBalance(_ amount: Int)
}

// Protocol defining bank operations
public protocol Banking {
    func credit(_ amount: Int, to account: Bankable) throws
    func debit(_ amount: Int, from account: Bankable) throws
    func getBalance(for account: Bankable) -> Int
}

// Custom errors for bank operations
public typealias BankError = ValidationError

// Concrete implementation
final public class Bank: Banking {
    public func credit(_ amount: Int, to account: Bankable) throws {
        do {
            let _ = try canCredit(amount)
        } catch let err {
            throw err
        }
        
        account.updateBalance(amount)
    }
    
    public func debit(_ amount: Int, from account: Bankable) throws {
        do {
            let _ = try canDebit(amount, from: account)
        } catch let err {
            throw err
        }
        
        account.updateBalance(-amount)
    }
    
    public func getBalance(for account: Bankable) -> Int {
        return account.balance
    }
    
    // MARK: Validate Credit and Debit
    
    public func canCredit(_ amount: Int) throws -> Bool {
        guard amount > 0 else {
            //throw BankError.invalidAmount(value: amount)
            throw BankError.invalidAmount(value: amount)
        }
        return true
    }
    
    public func canDebit(_ amount: Int, from account: Bankable) throws -> Bool {
        guard amount > 0 else {
            throw BankError.invalidAmount(value: amount)
        }
        
        let sum = (account.balance - amount)
        
        guard sum >= 0 else {
            throw BankError.insufficientFunds
        }
        
        return true
    }
}

