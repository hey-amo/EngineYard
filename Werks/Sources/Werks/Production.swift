//
//  Production.swift
//  Werks
//
//  Created by Amarjit on 20/05/2026.
//

/// Locomotive Train Production Handler
/// Each train `card` a player owns has `Production Units` assigned to it ie: Card 7 = 10 units, 0 unitsSpent
/// This class handles the increase, spend, reset

public class Production {
    public var units: Int = 0
    public var unitsSpent: Int = 0
    
    // can only add units if amount > 0
    public func addUnits(_ amount: Int = 0) {
        guard amount > 0 else { return } // replace with number validator try-catch throw
        self.units = self.units + amount
    }
    
    // can't spend if amount <= 0
    // can't spend if not enough units
    // can't spend if the balance (units - spend) < 0
    public func spendUnits(_ amount: Int = 0) {
        guard amount > 0 else { return } // replace with number validator try-catch
        guard self.units > amount else { return } // replace with a validator try-catch
        var sum = self.units
        sum = sum - amount
        guard sum >= 0 else { return } // replace with validator try-catch
        self.unitsSpent += amount // add to the amount spent
        self.unitsSpent = self.unitsSpent - amount
    }
    
    // resets the `units` and reset `unitsSpent`
    public func reset() {
        guard self.unitsSpent > 0 else { return }
        self.units = self.unitsSpent
        self.unitsSpent = 0
    }
}
