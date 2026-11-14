//
//  TestSupport.swift
//  werks-package
//
//  Created by Amarjit on 14/11/2026.
//

import XCTest
@testable import WerksPackage

// A collection of helper functions for testing

/// Asserts that a throwing expression fails with a specific `GameError`.
func XCTAssertGameError<T>(_ expression: @autoclosure () throws -> T, _ expected: GameError,
                           file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { error in
        XCTAssertEqual(error as? GameError, expected, file: file, line: line)
    }
}
