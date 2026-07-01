import Foundation

public enum GameMessageType: Int, Codable {
    case info, warning, error
}

public protocol GameMessageHandling: AnyObject {
    var messages: [GameMessage] { get }

    func add(_ message: GameMessage)
    func clear()
}

public final class GameMessageHandler: GameMessageHandling {
    public private(set) var messages: [GameMessage] = []

    public init() {}

    public func add(_ message: GameMessage) {
        messages.append(message)
    }

    public func clear() {
        messages.removeAll()
    }
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