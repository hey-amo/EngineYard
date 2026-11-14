//
//  GameMessageLog.swift
//  Werks
//
//

import Foundation

// How in-game events are logged
public enum MessageType: String, Codable, Sendable, Hashable {
    case debug, info, warning, success, error
}

// A single in-game message
public struct GameMessage: Codable, Sendable, Hashable, Equatable {
    public let id: UUID = UUID()
    public let type: MessageType
    public let body: String
    public let date: Date
    
    public enum CodingKeys: CodingKey {
        case id
        case type
        case body
        case date
    }
    
    init(type: MessageType, body: String, date: Date) {
        self.type = type
        self.body = body
        self.date = date
    }
}

// All-in game Messages, capped at 100 messages
// does it need a flag to tell a new message has been created but not read?
public struct GameMessageLog {
    public static let messageCap: Int = 100 /// cap of messages
    public private(set) var messages: [GameMessage] /// only this struct can add messages
    
    /// needs to auto-prune at 100 messages
    public mutating func add(message: GameMessage) {
        guard (messages.count < Self.messageCap) else { return }
        messages.append(message)
    }
    
    /// Flush all messages
    public mutating func clearAllMessages() {
        self.messages.removeAll()
    }
}
