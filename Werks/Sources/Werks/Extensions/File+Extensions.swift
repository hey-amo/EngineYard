//
//  File+Extensions.swift
//  Werks
//
//  Created by Amarjit on 28/10/2025.
//

import Foundation

public enum FileError : Error {
    case invalidPath( _ path: String)
    case invalidURL( _ url: URL)
    case fileNotFound( _ filename: String)
    case couldNotLoadFile(_ filename: String)
    case couldNotSaveFile(_ filename: String)
    case fileHasNoData
    case notFound
    case permissionDenied
    case unknownFormat
}

extension FileManager {
    class func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func cacheDirectory() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        let firstPath = paths[0] as String
        return URL(fileURLWithPath: firstPath)
    }
}
