//
//  Bank.swift
//  Werks
//
//

//  The ONLY type that changes anyone's coins. Every change returns a
//  `BankTransaction` receipt, which the engine forwards to listeners as a `GameEvent.transaction`.
//

/// Player accounts. The Bank itself has unlimited money.
public struct Bank: Codable, Equatable, Sendable {
    /// Balances indexed by player ID.
    public private(set) var balances: [Int]

    public init(playerCount: Int, startingCoins: Int) {
        self.balances = Array(repeating: startingCoins, count: playerCount)
    }

    /// Opens accounts with specific balances (used by tests and save migration).
    init(balances: [Int]) {
        self.balances = balances
    }

    // MARK: - Queries

    public func balance(of playerID: Int) -> Int { balances[playerID] }

    /// @parameters: `amount: Int`,`playerID: Int`
    public func canAfford(_ amount: Int, _ playerID: Int) -> Bool { balances[playerID] >= amount }

    /// Throws `insufficientFunds` unless the player can pay `amount`.
    public func requireFunds(_ amount: Int, from playerID: Int) throws {
        guard canAfford(amount, playerID) else {
            throw GameError.insufficientFunds(required: amount, available: balances[playerID])
        }
    }

    // MARK: - Transactions

    /// Player pays the Bank. Fails without changing anything if they cannot afford it.
    @discardableResult
    public mutating func charge(_ amount: Int, from playerID: Int, for reason: BankReason) throws -> BankTransaction {
        precondition(amount >= 0, "Charge must not be negative")
        try requireFunds(amount, from: playerID)
        balances[playerID] -= amount
        return BankTransaction(playerID: playerID, amount: -amount, reason: reason, balanceAfter: balances[playerID])
    }

    /// Bank pays the player.
    @discardableResult
    public mutating func pay(_ amount: Int, to playerID: Int, for reason: BankReason) -> BankTransaction {
        precondition(amount >= 0, "Payment must not be negative")
        balances[playerID] += amount
        return BankTransaction(playerID: playerID, amount: amount, reason: reason, balanceAfter: balances[playerID])
    }

    /// Collects `percent`% of the player's cash, rounded down.
    @discardableResult
    public mutating func collectTax(from playerID: Int, percent: Int) -> BankTransaction {
        let tax = balances[playerID] * percent / 100
        balances[playerID] -= tax
        return BankTransaction(playerID: playerID, amount: -tax, reason: .tax, balanceAfter: balances[playerID])
    }
}
