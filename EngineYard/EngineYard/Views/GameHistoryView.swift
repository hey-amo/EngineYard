//
//  GameHistoryView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import Foundation
import SwiftUI

struct ActionLog: Identifiable {
    let id = UUID()
    let description: String
    let timestamp: Date
    let actionType: ActionType
    
    enum ActionType {
        case locomotivePurchased
        case locomotiveSold
        case addedProduction
        case paidTax
        // Add more action types as needed
    }
}


@MainActor
class HistoryLogViewModel: ObservableObject {
    @Published private(set) var actions: [ActionLog] = []
    
    func addAction(_ action: ActionLog) {
        actions.insert(action, at: 0) // Insert at beginning for reverse chronological order
    }
    
    func clearHistory() {
        actions.removeAll()
    }
    
    // For preview/testing
    func populateWithSampleData() {
        let sampleActions = [
            ActionLog(description: "Purchased Locomotive #1234",
                      timestamp: Date().addingTimeInterval(-3600),
                      actionType: .locomotivePurchased),
            ActionLog(description: "Added production to Locomotive #1234",
                      timestamp: Date().addingTimeInterval(-7200),
                       actionType: .addedProduction),
            ActionLog(description: "Locomotive #1234 was sold",
                      timestamp: Date().addingTimeInterval(-10800),
                       actionType: .locomotiveSold)
        ]
        actions = sampleActions
    }
}



struct GameHistoryView: View {
    @StateObject private var viewModel = HistoryLogViewModel()
    
    @State private var showingClearConfirmation = false
    
    var body: some View {
        List {
            ForEach(viewModel.actions) { action in
                HistoryActionRow(action: action)
            }
        }
        .navigationTitle("History Log")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    Text("Clear")
                }
                .disabled(viewModel.actions.isEmpty)
            }
        }
        .overlay {
            if viewModel.actions.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Actions will appear here as you play the game")
                )
            }
        }
        .alert("Clear History", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearHistory()
            }
        } message: {
            Text("Are you sure you want to clear all history? This action cannot be undone.")
        }
        .task {
            #if DEBUG
            viewModel.populateWithSampleData()
            #endif
        }
    }
}

struct HistoryActionRow: View {
    let action: ActionLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(action.description)
                .font(.body)
            
            Text(action.timestamp, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GameHistoryView()
    }
}
