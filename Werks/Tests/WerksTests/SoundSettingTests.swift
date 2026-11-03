//
//  SoundSettingTests.swift
//  Werks

import XCTest
@testable import Werks

final class SoundSettingTests: XCTestCase {
    func testDefaults() {
        let settings = SoundSetting()

        XCTAssertTrue(settings.isSoundEnabled)
        XCTAssertTrue(settings.isMusicEnabled)
        XCTAssertFalse(settings.isDarkModeEnabled)
        XCTAssertTrue(settings.areHapticsEnabled)
    }

    func testInitializerSetsEachSettingIndependently() {
        let settings = SoundSetting(
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
        var settings = SoundSetting()

        settings.toggle(.music)

        XCTAssertTrue(settings.isSoundEnabled)
        XCTAssertFalse(settings.isMusicEnabled)
        XCTAssertFalse(settings.isDarkModeEnabled)
        XCTAssertTrue(settings.areHapticsEnabled)

        settings.toggle(.music)
        XCTAssertTrue(settings.isMusicEnabled)
    }

    func testSetEnablesAndDisablesEachSetting() {
        var settings = SoundSetting()

        for setting in GameSetting.allCases {
            settings.set(setting, enabled: false)
            XCTAssertFalse(settings.isEnabled(setting))

            settings.set(setting, enabled: true)
            XCTAssertTrue(settings.isEnabled(setting))
        }
    }
}
