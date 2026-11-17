////
//  OBFeature.swift
//  Werks
//
//  Created by AD on 17/11/2026.
//

import Foundation

// Onboarding feature model
public struct OBFeature: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let icon: String?
}

