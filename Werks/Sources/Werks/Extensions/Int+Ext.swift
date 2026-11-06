//
//  Int+Ext.swift
//  Werks

// Integer extensions

extension Int {
    func roundedUpHalf() -> Self {
        guard self > 0 else { return 0 }
        return (self / 2 + self % 2)
    }
}

extension UInt {
    func roundedUpHalf() -> Self {
        guard self > 0 else { return 0 }
        return (self / 2 + self % 2)
    }
}
