//
//  WerksBundle.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import Foundation
import Werks

public enum WerksResources {
    public static let bundle = Bundle.module
    
    public static func dieImage(_ number: Int) -> String {
        return "die-\(number)"
    }
}
