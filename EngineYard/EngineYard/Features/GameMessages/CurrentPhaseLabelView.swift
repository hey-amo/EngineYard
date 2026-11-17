////
//  CurrentPhaseLabelView.swift
//  EngineYard
//
//  Created by AD on 17/11/2026.
//

import SwiftUI
import Foundation
import Werks

// PARTIAL VIEW: Displays the current phase of the game

struct CurrentPhaseLabelView: View {
    let phaseLabel: String
    var body: some View {
        HStack {
            Text("Phase:")
            Text(phaseLabel.uppercased())
        }
    }
}

#Preview {
    let phase = GamePhase.development
    CurrentPhaseLabelView(phaseLabel: phase.description)
}
