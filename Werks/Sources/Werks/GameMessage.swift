//
//  GameMessage.swift
//  Werks
//

import Foundation

public enum GameMessageType: Int, Codable, Hashable, Sendable {
    case info, warning, success, error
}

public struct GameMessage: Identifiable, Codable, Sendable, Hashable, Equatable {
    public let id: UUID
    public let date: Date
    public let message: String
    public let messageType: GameMessageType

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        message: String,
        messageType: GameMessageType = .info
    ) {
        self.id = id
        self.date = date
        self.message = message
        self.messageType = messageType
    }
}

// Only keep last 100 messages
// - Can `add, `clear`, and `get` messages
// - Messages are stored in an array, and sorted by date, with the most recent messages first
public struct GameLog: Sendable {
    private var _messages: [GameMessage] = []
    public let messageLimit: Int = 100

    public init() {}

    public var showLatestMessages: [GameMessage] {
        _messages
    }

    public mutating func add(message: GameMessage) {
        _messages.append(message)
        _messages.sort { $0.date > $1.date }

        if _messages.count > messageLimit {
            _messages.removeLast(_messages.count - messageLimit)
        }
    }
    
    public mutating func clearLog() {
        guard !_messages.isEmpty else { return }
        _messages.removeAll()
    }
}
