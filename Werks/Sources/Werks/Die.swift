//
//  File.swift
//  Werks
//
//  Created by Amarjit on 18/05/2026.
//

import Foundation

public protocol ModifyD6 {
    static func increment(_ value: Int) -> Int
    static func decrement(_ value: Int) -> Int
    static func isValid(_ value: Int) -> Bool
}

public struct D6: ModifyD6 {
    public static let minValue = 1
    public static let maxValue = 6

    public static func roll() -> Int {
        Int.random(in: minValue...maxValue)
    }

    public static func increment(_ value: Int) -> Int {
        isValid(value) ? min(value + 1, maxValue) : maxValue
    }

    public static func decrement(_ value: Int) -> Int {
        isValid(value) ? max(value - 1, minValue) : minValue
    }

    public static func isValid(_ value: Int) -> Bool {
        (minValue...maxValue).contains(value)
    }
}
