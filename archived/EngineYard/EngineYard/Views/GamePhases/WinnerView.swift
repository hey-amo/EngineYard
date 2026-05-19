//
//  WinnerView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import SwiftUI

struct PlayerScore: Identifiable {
    let id = UUID()
    let playerName: String
    let score: Int
    let avatar: String = "🏆"
}

struct WinnerView: View {
    @Binding var isPresented: Bool
    let players: [PlayerScore]
    
    var sortedPlayers: [PlayerScore] {
        players.sorted { $0.score > $1.score }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Winner celebration section
                if let winner = sortedPlayers.first {
                    Section {
                        VStack(spacing: 16) {
                            Text("🏆")
                                .font(.system(size: 64))
                            
                            Text("\(winner.playerName) Wins!")
                                .font(.title)
                                .bold()
                            
                            Text("Score: \(winner.score)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 32)
                    }
                }
                
                // Scoreboard section
                Section(header: Text("Final Scores")) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        
                        
                            HStack {
                                Text(player.avatar)
                                    .font(.title2)
                                
                                if (index == 0) {
                                    Text(player.playerName)
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Text("\(player.score)")
                                        .font(.body)
                                        .bold()
                                        .foregroundColor(.blue)
                                } else {
                                    Text(player.playerName)
                                        .font(.body)
                                    Spacer()
                                    
                                    Text("\(player.score)")
                                        .font(.body)
                                }
 
                            }
                    }
                }
                
                // Play Again button section
                Section {
                    Button("Play Again") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Game Over")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    WinnerView(
        isPresented: .constant(true),
        players: [
            PlayerScore(playerName: "Player 1", score: 330),
            PlayerScore(playerName: "Player 2", score: 300),
            PlayerScore(playerName: "Player 3", score: 250),
            PlayerScore(playerName: "Player 4", score: 10),
            PlayerScore(playerName: "Player 5", score: 1)
        ]
    )
}
