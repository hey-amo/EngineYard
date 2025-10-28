//
//  DieView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//


import Werks
import SwiftUI

struct DieView: View {
    let die: Int
    var body: some View {
        Image("die-\(die)")
    }
}


// Preview
#Preview {
    DieView(die: 1)
}
