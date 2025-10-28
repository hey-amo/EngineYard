//
//  TaxReportView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import SwiftUI
import Foundation

fileprivate struct PlayerViewModel: Identifiable {
    let id: UUID
    let name: String
    let avatar: String
    let isHuman: Bool
}

struct TaxReportView: View {
    fileprivate let players: [PlayerViewModel]
    
    var body: some View {
        List {
            Section {
                Text("Tax Report")
                    .font(.title2)
                    .fontWeight(.bold)
                    .listRowBackground(Color.clear)
            }
            ForEach(players) { player in
                VStack(spacing: 10) {
                    Text("Player #1 paid $1")
                    Text("Player #2 paid $2 in taxes")
                    Text("Player #3 paid $3 in taxes")
                    Text("Player #4 paid $4 in taxes")
                    Text("Player #5 paid $5 in taxes")
                    
                }.frame(alignment: .topLeading)
            }
        }

    }
}


// Add this extension before the preview
private extension TaxReportView {
    static var samplePlayers: [PlayerViewModel] {
        [
            PlayerViewModel(id: UUID(), name: "John", avatar: "avt-1", isHuman: true),
            PlayerViewModel(id: UUID(), name: "Bot#1", avatar: "avt-2", isHuman: false),
            PlayerViewModel(id: UUID(), name: "Sarah", avatar: "avt-3", isHuman: true),
            PlayerViewModel(id: UUID(), name: "Bot#2", avatar: "avt-4", isHuman: false)
        ]
    }
}


#Preview {
    NavigationView {
        TaxReportView(
            players: [TaxReportView.samplePlayers[0]]
        )
    }
}
