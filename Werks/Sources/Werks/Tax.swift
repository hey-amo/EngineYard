//
//  Tax.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

import Foundation

public struct Tax {
    private static let rate: Double = GameRules.Economy.taxRate
    
    public func calculate(on amount: Int) -> Int {
        guard (amount > 0) else { return 0 }
        
        return Int(floor(Double(amount) * Tax.rate))
    }
}
