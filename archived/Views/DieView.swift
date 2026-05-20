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
        Image(WerksResources.dieImage(die), bundle: WerksResources.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
    }
}


// Preview
#Preview {
    DieView(die: 1)
}
