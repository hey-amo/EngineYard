//
//  Int+Extension.swift
//  Werks
//
//  Created by Amarjit on 28/10/2025.
//

import Foundation

public extension Int {
    var ordinalFormat: String? {
        let number: NSNumber = NSNumber(integerLiteral: self)
        let cache = NumberFormatCache.ordinalFormat
        return cache.string(from: number)
    }
}
