import Foundation

public enum GameMessageType {
    case info
    case warning
    case error
}

public struct GameMessage {
    public let message: String
    public let timestamp: Date
    public let type: GameMessageType

    public init(message: String, timestamp: Date = Date(), messageType: GameMessageType = .info) {
        self.message = message
        self.timestamp = timestamp
        self.type = messageType
    }
}