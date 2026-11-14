//
//  SeededRandomness.swift
//  Werks
//
//  Created by Amarjit on 12/11/2026.
//

import Foundation

/// SplitMix64: tiny, fast, Codable and identical on every platform.
///
/// The engine uses `rollDie()` and `shuffle(_:)` rather than the standard
/// library's `random(in:using:)` / `shuffled(using:)`, whose algorithms are
/// not guaranteed stable across Swift versions. Same seed ⇒ same game.
public struct SeededRandomNumberGenerator: RandomNumberGenerator, Codable, Equatable, Sendable {
    public private(set) var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A uniform value in `0..<bound` (rejection sampling, no modulo bias).
    public mutating func next(below bound: Int) -> Int {
        precondition(bound > 0, "bound must be positive")
        let upper = UInt64(bound)
        let limit = UInt64.max - UInt64.max % upper
        var value = next()
        while value >= limit { value = next() }
        return Int(value % upper)
    }

    /// A six-sided die roll, 1...6.
    public mutating func rollDie() -> Int {
        next(below: 6) + 1
    }

    /// Deterministic Fisher–Yates shuffle.
    public mutating func shuffle<T>(_ array: [T]) -> [T] {
        var result = array
        guard result.count > 1 else { return result }
        for i in stride(from: result.count - 1, to: 0, by: -1) {
            result.swapAt(i, next(below: i + 1))
        }
        return result
    }
}
