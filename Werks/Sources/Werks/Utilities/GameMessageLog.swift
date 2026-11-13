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

// A single message
public struct Message: Codable, Sendable, Hashable, Equatable {
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
public struct MessageLog {}
