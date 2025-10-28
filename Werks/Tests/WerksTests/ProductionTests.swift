//
//  ProductionTests.swift
//  Werks
//
//  Created by Amarjit on 28/10/2025.
//

import Testing

@testable import Werks

// Production errors
public typealias ProductionError = ValidationError

final public class ProductionManager {
    public func add(units: Int, to delegate: ProductionDelegate) {
        
    }
    public func spend(units:Int, from delegate: ProductionDelegate) {        
    }
    
    // Resets units amount to spentUnits amount
    // Resets spentUnits to 0
    public func reset(delegate: ProductionDelegate) {
        let units = delegate.units
        let spentUnits = delegate.spentUnits
        delegate.updateProduction(units: spentUnits, spentUnits: 0)
    }
    public func shiftProduction(units: Int, from: ProductionDelegate, to: ProductionDelegate) {
    }
    
    public func canAddUnits(_ amount: Int) throws -> Bool {
        guard amount > 0 else {
            throw ProductionError.invalidAmount(value: amount)
        }
        return true
    }
    
    public func canSubtractUnits(_ amount: Int) throws -> Bool {
        guard amount > 0 else {
            throw ProductionError.invalidAmount(value: amount)
        }
        return true
    }
}


struct ProductionTests {
        
    @Test func testAddProdUnits_NegativeValue_ShouldThrow() async throws {
        
    }
}
