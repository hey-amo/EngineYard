//
//  Array+Extensions.swift
//  Werks
//
//  Created by Amarjit on 28/10/2025.
//

// Helper for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
