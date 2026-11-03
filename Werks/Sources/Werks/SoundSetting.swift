//
//  SoundSetting.swift
//  Werks
//
//  Created by Amarjit on 03/11/2026.
//

public enum SoundSetting: Sendable, Codable {
    case sound(Bool)
    case music(Bool)
    case darkMode(Bool)
    case hapticMode(Bool)
    
    public static func toggle(_ setting: SoundSetting) -> Self {
        switch setting {
        case sound(let value): return SoundSetting.sound(!value)
        case music(let value): return SoundSetting.music(!value)
        case darkMode(let value): return SoundSetting.darkMode(!value)
        case hapticMode(let value): return SoundSetting.hapticMode(!value)
        }
    }
}
