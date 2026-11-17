////
//  CoinsView.swift
//  EngineYard
//
//  Created by AD on 17/11/2026.
//


import SwiftUI
import Werks

// PARTIAL VIEW: Displays coins only


// A partial view showing only the coins
// Has adjustible font size
struct CoinValueView: View {
    let value: Int
    var fontSize: CGFloat = 24

    var body: some View {
        HStack(spacing: 6) {
            Text("🪙")
            Text(value, format: .number)
                .font(.system(size: fontSize))
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Coins: \(value)"))
    }
}

#Preview {
    CoinValueView(value: 120)
}
