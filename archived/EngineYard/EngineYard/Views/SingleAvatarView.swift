//
//  SingleAvatarView.swift
//  EngineYard
//
//  Created by Amarjit on 28/10/2025.
//

import SwiftUI
import Werks

struct SingleAvatarView: View {
    let avatar: String
    
    var body: some View {
        Image(avatar)
            .resizable()
            .clipShape(
                RoundedRectangle(cornerRadius: 6.0, style: .continuous)
            )
            .clipped()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: 50, maxHeight: 50, alignment: .topLeading)
        
    }
}

#Preview {
    SingleAvatarView(avatar: "avt-1")
}
