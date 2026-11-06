//
//  GameSettingsTests.swift
//  Werks

import XCTest
@testable import Werks

final class GameSettingTests: XCTestCase {
    func testDefaults() {
        let settings = GameSetting()

        XCTAssertTrue(settings.isSoundEnabled)
        XCTAssertTrue(settings.isMusicEnabled)
        XCTAssertFalse(settings.isDarkModeEnabled)
        XCTAssertTrue(settings.areHapticsEnabled)
    }

    func testInitializerSetsEachSettingIndependently() {
        let settings = GameSetting(
            soundEnabled: false,
            musicEnabled: true,
            darkModeEnabled: true,
            hapticsEnabled: false
        )

        XCTAssertFalse(settings.isSoundEnabled)
        XCTAssertTrue(settings.isMusicEnabled)
        XCTAssertTrue(settings.isDarkModeEnabled)
        XCTAssertFalse(settings.areHapticsEnabled)
    }

    func testToggleChangesOnlySelectedSetting() {
        var settings = GameSetting()

        settings.toggle(.music)

        XCTAssertTrue(settings.isSoundEnabled)
        XCTAssertFalse(settings.isMusicEnabled)
        XCTAssertFalse(settings.isDarkModeEnabled)
        XCTAssertTrue(settings.areHapticsEnabled)

        settings.toggle(.music)
        XCTAssertTrue(settings.isMusicEnabled)
    }

    func testSetEnablesAndDisablesEachSetting() {
        var settings = GameSetting()

        for setting in Preferences.allCases {
            settings.set(setting, enabled: false)
            XCTAssertFalse(settings.isEnabled(setting))

            settings.set(setting, enabled: true)
            XCTAssertTrue(settings.isEnabled(setting))
        }
    }
}
