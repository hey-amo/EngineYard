//
//  Tax.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

public struct Tax: Sendable {
    /// Calculates 10% tax, rounded down to an integer
    public static func calculate(on amount: Int = 0) -> Int {
        guard amount > 0 else { return 0 }
        return amount * GameRules.Economy.taxRate / 100
    }
}
