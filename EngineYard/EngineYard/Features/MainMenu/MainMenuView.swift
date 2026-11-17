//
//  MainMenuView.swift
//  EngineYard
//

import SwiftUI

// MARK: - Colors

extension Color {
    static let neonCyan   = Color(red: 0.49, green: 0.96, blue: 1.00)
    static let neonBlue   = Color(red: 0.62, green: 0.83, blue: 1.00)
    static let neonViolet = Color(red: 0.72, green: 0.55, blue: 1.00)
    static let deepIndigo = Color(red: 0.10, green: 0.04, blue: 0.22)
    static let ink        = Color(red: 0.07, green: 0.03, blue: 0.18)
}

// MARK: - Main Menu

struct MainMenuView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                hero

                Spacer()

                menu

                footer
            }
            .padding(.horizontal, 26)
            .padding(.top, 60)
            .padding(.bottom, 12)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
        //.preferredColorScheme(.dark)
    }

    
    // Hero Section: Title, and subtitle
    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("🚂")
                    .font(.system(size: 56, weight: .heavy ))
            }
            .frame(width: 124, height: 124)

            VStack(spacing: 10) {
                Text("Engine Yard")
                    .font(.system(size: 40, weight: .heavy))
                Text("Build locomotives, sell them")
            }
        }
        .padding(.top, 40)
    }

    // Play, Continue, Settings
    private var menu: some View {
        VStack(spacing: 14) {
            Button {
                print("Play (pressed)")
            } label: {
                Label("Play", systemImage: "play.fill")
            }
            .buttonStyle(MenuButtonStyle(kind: .primary))

            Button {
                print("Continue (pressed)")
            } label: {
                Label("Continue", systemImage: "arrow.clockwise")
            }
            .buttonStyle(MenuButtonStyle(kind: .secondary))
            

            Button {
                print("Settings (pressed)")
            } label: {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(MenuButtonStyle(kind: .secondary))
        }
        .frame(maxWidth: 340)
        .frame(maxWidth: .infinity)
    }

    // Version on the left, Credits on the bottom right
    private var footer: some View {
        HStack {
            Text("v1.0.0")
                .font(.footnote)
                .foregroundStyle(.secondary.opacity(0.6))

            Spacer()

            Button {
                print("Credits (pressed)")
            } label: {
                Text("Credits")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                    .padding(.leading, 14)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 26)
    }
}

// MARK: - Button Style

struct MenuButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary }
    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        let isPrimary = kind == .primary

        configuration.label
            .font(.system(size: isPrimary ? 19 : 17, weight: .bold, design: .rounded))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(isPrimary ? Color.ink : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: isPrimary ? 68 : 60)
            .background {
                if isPrimary {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonViolet],
                            startPoint: .leading, endPoint: .trailing))
                        .shadow(color: .neonCyan.opacity(0.4), radius: 16, y: 8)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed && isPrimary ? 0.05 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
}
