//
//  Tax
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation

public struct Tax {
    public static func calculateTax(on amount: Int) -> Int {
        let taxRate: Double = GameRules.Economy.taxRate
        guard (amount > 0) else { return 0 }
        return Int(floor(Double(amount) * taxRate))
    }
}