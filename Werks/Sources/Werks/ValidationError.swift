//
//  ValidationError.swift
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//


import Foundation

public enum ValidationError: LocalizedError {
    case insufficientFunds
    case invalidAmount(value: Int)
    case notEnoughResources(required: Int, available: Int)
    
    public var errorDescription: String? {
        switch self {
        case .insufficientFunds:
            return "Insufficient amount"
        case .invalidAmount(let value):
            return "Value cannot be negative (got \(value))."
        case .notEnoughResources(let required, let available):
            return "Not enough: required \(required), available \(available)."
        }
    }
}

public struct NumericValidator {
    public static func validatePositiveAmount(_ amount: Int) throws -> Bool {
        guard amount > 0 else {
            throw ValidationError.invalidAmount(value: amount)
        }
        return true
    }
    
    public static func validateSufficientFunds(_ available: Int, required: Int) throws -> Bool {
        let _ = try validatePositiveAmount(required)
        
        guard (available - required) >= 0 else {
            throw ValidationError.insufficientFunds
        }
        return true
    }
}
