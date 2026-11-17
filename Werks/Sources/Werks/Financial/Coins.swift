//
//  Coins.swift
//  Werks
//
//

/// Hands coins manipulation
/// Doesn't care about anything else


/// the coin actions
public enum CoinAction {
    case add(_ coins: Int)
    case subtract(_ coins: Int)
}

/// constants
public struct CoinRules {
    public static let minCoins: Int = -5_000
    public static let maxCoins: Int = 10_000
    public static let balanceCanGoBelowZero: Bool = false /// can the coins be <0
    
    // override init here with custom coin rules?
}

/// handles add, subtract of coins safely
public struct CoinHandler: Codable, Sendable {
    private var _coins: Int
    public var available: Int {
        get { return _coins }
    }
    
    public init(_coins: Int) { // would like to set custom rules
        self._coins = _coins
    }
    
    public mutating func perform(_ action: CoinAction) {
        switch action {
        case .add(let amount):
            self.add(amount)
            break
        case .subtract(let amount):
            self.subtract(amount)
            break
        }
    }
    
    /// Can't add negative numbers
    private mutating func add(_ amount: Int = 0) {
        guard amount > 0 else { return }
        guard amount <= CoinRules.maxCoins else { return }
        _coins += amount
    }
    
    /// Can't subtract negative numbers
    /// Can only subtract to available
    /// Can't go beyond minCoins
    private mutating func subtract(_ amount: Int = 0) {
        guard amount > 0 else { return }
        guard available >= amount else { return }
        guard available > CoinRules.minCoins else { return }
        _coins -= amount
    }
}
