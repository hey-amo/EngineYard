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
}

// Only keep last 250 messages
public struct GameLog: Sendable {
    public private(set) var messages: [GameMessage]
    
    public func add(message: GameMessage) {}
    
    public mutating func clearLog() {
        guard !messages.isEmpty else { return }
        messages.removeAll()
    }
}
