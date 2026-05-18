//
//  Die
//  Werks
//
//  Created by Amarjit on 27/10/2025.
//

import Foundation
import GameplayKit

public protocol DieModifer {
    mutating func increment(value: Int) -> Int
    mutating func decrement(value: Int) -> Int
}

public struct D6 {
    public static var minValue: Int {
        if #available(iOS 9, *) {
            return GKRandomDistribution.d6().lowestValue
        } else {
            return 1
        }
    }
    public static var maxValue: Int {
        if #available(iOS 9, *) {
            return GKRandomDistribution.d6().highestValue
        } else {
            return 6
        }
    }

    private let die: GKRandomDistribution   // GKRandomDistribution for randomness
    let value: Int 
    
    public static func roll() -> Int {
        if #available(iOS 9, *) {
            let die: GKRandomDistribution = GKRandomDistribution.d6()
            return die.nextInt()
        } else {
            return Int.random(in: D6.minValue...D6.maxValue)
        }
    }
}

extension D6: CustomStringConvertible {
    public var description: String {
        return "D6(\(value))"
    }
}

extension D6: DieModifer {
    public mutating func increment(value: Int) -> Int {
        guard value < D6.maxValue else { return D6.maxValue }
        return value + 1
    }
    
    public mutating func decrement(value: Int) -> Int {
        guard value > D6.minValue else { return D6.minValue }
        return value - 1
    }

    public func isValid(value: Int) -> Bool {
        return (value >= D6.minValue && value <= D6.maxValue)
    }
}
