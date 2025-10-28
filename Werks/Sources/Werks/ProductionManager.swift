//
//  ProductionManager.swift
//  Werks
//
//  Created by Amarjit on 28/10/2025.
//

import Foundation

public protocol ProductionDelegate {
    var units: Int { get }
    var spentUnits: Int { get }
    func updateProduction(units: Int, spentUnits: Int)
}
