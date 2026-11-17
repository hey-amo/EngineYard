////
//  PlayerAvatarView.swift
//  EngineYard
//
//  Created by AD on 17/11/2026.
//

import SwiftUI
import Werks

enum AvatarResource: String {
    case avt1 = "avt-1"
    case avt2 = "avt-2"
    case avt3 = "avt-3"
    case avt4 = "avt-4"
    case avt5 = "avt-5"
}

public enum AvatarStatus: Sendable {
    case idle
    case onTurn
    case disabled
}

public enum PlayerKind: Sendable {
    case human
    case bot

    var emoji: String {
        switch self {
        case .human: "👤"
        case .bot: "🤖"
        }
    }

    var description: String {
        switch self {
        case .human: "human"
        case .bot: "bot"
        }
    }
}

public struct CircleAvatar: View {
    private let image: Image
    private let diameter: CGFloat
    private let kind: PlayerKind?
    private let status: AvatarStatus

    public init(
        _ image: Image,
        diameter: CGFloat = 80,
        kind: PlayerKind? = nil,
        status: AvatarStatus = .idle
    ) {
        self.image = image
        self.diameter = diameter
        self.kind = kind
        self.status = status
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: diameter, height: diameter)
            .saturation(status == .disabled ? 0 : 1)   // greyscale
            .clipShape(Circle())
            .overlay(ring)
            .overlay(alignment: .bottomTrailing) { kindBadge }
            .opacity(status == .disabled ? 0.45 : 1)
            .animation(.easeInOut(duration: 0.25), value: status)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
    }

    // The ring is the turn indicator: accent colour and thicker when it's this player's turn.
    private var ring: some View {
        Circle()
            .strokeBorder(
                status == .onTurn ? Color.accentColor : Color.primary.opacity(0.2),
                lineWidth: status == .onTurn ? max(2, diameter * 0.10) : 1
            )
    }

    @ViewBuilder
    private var kindBadge: some View {
        if let kind {
            Text(kind.emoji)
                .font(.system(size: diameter * 0.3))
                .padding(diameter * 0.04)
                .background(.background, in: Circle())
                .overlay(Circle().strokeBorder(.primary.opacity(0.05), lineWidth: 0.5))
                .offset(x: diameter * 0.05, y: diameter * 0.05)
                .accessibilityHidden(true)
        }
    }

    private var accessibilityText: String {
        var parts: [String] = []
        if let kind { parts.append(kind.description) }
        switch status {
        case .idle: break
        case .onTurn: parts.append("on turn")
        case .disabled: parts.append("not on turn")
        }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    CircleAvatar(
        Image(.avt1),
        diameter: 80,
        kind: .human,
        status: .onTurn
    )

    CircleAvatar(Image(.avt3), diameter: 80, kind: .bot, status: .disabled)

}

