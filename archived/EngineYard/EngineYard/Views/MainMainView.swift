//
//  MainMainView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import SwiftUI

struct MainMainView: View {
    var body: some View {
        VStack {
            Text("Engine Yard")
                .font(.largeTitle)
            
            Button("Start Game") {
                // Add game start logic here
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("New Game")
    }
}

#Preview {
    MainMainView()
}
