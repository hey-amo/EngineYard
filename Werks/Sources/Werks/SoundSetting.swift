//
//  SoundSetting.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

public enum GameSetting: CaseIterable, Sendable {
    case sound
    case music
    case darkMode
    case haptics
}

public struct SoundSetting: Equatable, Sendable {
    public private(set) var isSoundEnabled: Bool
    public private(set) var isMusicEnabled: Bool
    public private(set) var isDarkModeEnabled: Bool
    public private(set) var areHapticsEnabled: Bool

    public init(
        soundEnabled: Bool = true,
        musicEnabled: Bool = true,
        darkModeEnabled: Bool = false,
        hapticsEnabled: Bool = true
    ) {
        self.isSoundEnabled = soundEnabled
        self.isMusicEnabled = musicEnabled
        self.isDarkModeEnabled = darkModeEnabled
        self.areHapticsEnabled = hapticsEnabled
    }

    public func isEnabled(_ setting: GameSetting) -> Bool {
        switch setting {
        case .sound: isSoundEnabled
        case .music: isMusicEnabled
        case .darkMode: isDarkModeEnabled
        case .haptics: areHapticsEnabled
        }
    }

    public mutating func set(_ setting: GameSetting, enabled: Bool) {
        switch setting {
        case .sound: isSoundEnabled = enabled
        case .music: isMusicEnabled = enabled
        case .darkMode: isDarkModeEnabled = enabled
        case .haptics: areHapticsEnabled = enabled
        }
    }

    public mutating func toggle(_ setting: GameSetting) {
        set(setting, enabled: !isEnabled(setting))
    }
}
