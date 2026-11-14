//
//  PlayerSetup.swift
//  Werks
//
//

/// Who is sitting at the table.
public struct PlayerSetup: Codable, Equatable, Sendable {
    public let name: String
    public let avatar: String
    public let isAI: Bool

    public init(name: String, avatar: String = "", isAI: Bool = false) {
        self.name = name
        self.avatar = avatar
        self.isAI = isAI
    }
}
