// Werks
// v0.1b

// Main game engine for unofficial clone of `Locomotive Werks`.

import Foundation

public enum GameState: Int, Sendable, Codable {
    case setup, play, paused, ended
}

public enum PlayerState: Int, Sendable, Codable {
    case idle, thinking, playing, done
}

public enum GamePhase: Int, Sendable, Codable {
    case setup
}

public class Werks {}

