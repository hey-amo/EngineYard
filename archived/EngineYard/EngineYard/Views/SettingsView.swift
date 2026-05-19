//
//  SettingsView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.title)
                Spacer()
                Button {
                    showSettings = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            
            Form {
                Section("Game Settings") {
                    /*
                    Toggle("Sound Effects", isOn: Binding(
                        get: { store.preferences.soundEnabled },
                        set: { store.setSound($0) }
                    ))
                    Toggle("Background Music", isOn: Binding(
                        get: { store.preferences.musicEnabled },
                        set: { store.setMusic($0) }
                    ))*/
                    Toggle("Sound Effects", isOn: .constant(true))
                    Toggle("Background Music", isOn: .constant(true))
                }

                Section("Display") {
                    Toggle("Dark Mode", isOn: .constant(false))
                }

                Section {
                    Button("Reset Game") {
                        // Do something
                    }
                }
            }
            
        }
        .cornerRadius(25)
        .padding()
    }
}

#Preview {
    SettingsView(showSettings: .constant(true))
}
