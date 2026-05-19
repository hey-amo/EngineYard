//
//  File.swift
//  Werks
//
//  Created by Amarjit on 18/05/2026.
//

import Foundation
import GameplayKit

public protocol ModifyD6 {
    mutating func increment(_ value: Int) -> Int
    mutating func decrement(_ value: Int) -> Int
}

public struct D6 {
    public static let minValue: Int = 1
    public static  let maxValue: Int = 6
    private let die: GKRandomDistribution
    
    public static func roll() -> Int {
        let die: GKRandomDistribution = GKRandomDistribution.d6()
        return die.nextInt()
    }
}

extension D6: ModifyD6 {
    public mutating func increment(_ value: Int) -> Int {
        guard value < D6.maxValue else { return D6.maxValue }
                return value + 1
    }
    public mutating func decrement(_ value: Int) -> Int {
        guard value > D6.minValue else { return D6.minValue }
               return value - 1
    }
    
    public func isValid(value: Int) -> Bool {
       return (value >= D6.minValue && value <= D6.maxValue)
    }
}
