//
//  NumericProcessor.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

import Foundation

// MARK: Errors
public enum CoinBalanceError: Error, Equatable, Sendable, LocalizedError {
    case negativeAmount(Int)
    case insufficientFunds(requested: Int, available: Int)

    public var errorDescription: String? {
        switch self {
        case .negativeAmount:
            return NSLocalizedString(
                "Coin amounts cannot be negative.",
                comment: "Shown when a coin transaction has a negative amount"
            )

        case let .insufficientFunds(requested, available):
            let format = NSLocalizedString(
                "Not enough coins. Available: %1$lld; required: %2$lld.",
                comment: "Shown when a player tries to spend more coins than they have"
            )
            return String.localizedStringWithFormat(
                format,
                Int64(available),
                Int64(requested)
            )
        }
    }
}

public enum CoinTransaction: Sendable {
    case add(Int)
    case subtract(Int)
}


/// Receives the player's new balance after a successful transaction.
public protocol WalletObserver: AnyObject, Sendable {
    func coinBalanceDidUpdate(to balance: Int) async
}

public actor Wallet {
    private var coins: Int
    private weak var observer: (any WalletObserver)? //weak observer
    
    public init(
        _ initialBalance: Int = 0,
        observer: (any WalletObserver)? = nil
    ) throws {
        guard initialBalance >= 0 else {
            throw CoinBalanceError.negativeAmount(initialBalance)
        }

        self.coins = initialBalance
        self.observer = observer
    }

    public var balance: Int {
        coins
    }

    /// Applies a transaction, then notifies the observer of the committed balance.
    /// Adding saturates at `Int.max`; subtracting more than the balance throws.
    @discardableResult
    public func perform(_ transaction: CoinTransaction) async throws -> Int {
        switch transaction {
        case let .add(amount):
            guard amount >= 0 else {
                throw CoinBalanceError.negativeAmount(amount)
            }

            let (sum, overflow) = coins.addingReportingOverflow(amount)
            coins = overflow ? .max : sum

        case let .subtract(amount):
            guard amount >= 0 else {
                throw CoinBalanceError.negativeAmount(amount)
            }

            guard amount <= coins else {
                throw CoinBalanceError.insufficientFunds(
                    requested: amount,
                    available: coins
                )
            }

            // The guard above guarantees this subtraction cannot go below zero.
            coins -= amount
        }

        let updatedBalance = coins
        await observer?.coinBalanceDidUpdate(to: updatedBalance)
        return updatedBalance
    }
}
