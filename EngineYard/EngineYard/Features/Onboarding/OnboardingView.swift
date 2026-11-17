////
//  OnboardingView.swift
//  EngineYard
//
//  Created by AD on 17/11/2026.
//

import SwiftUI
import Werks

struct OnboardingView: View {
    @State var appName: String
    @State private var closingOnboarding = false
    @State private var showingOnboarding = false
    let features: [OBFeature]
    let color: Color?
    var body: some View {
        VStack {}
        .hidden()
        .onAppear() {
            let defaults = UserDefaults.standard
            let seen = defaults.bool(forKey: "OnboardingSeen")
            if(!seen) {
                //the onboarding has not been seen, trigger the onboarding screen
                showingOnboarding = true
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            VStack {
                Text("Welcome to \(appName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 50)
                    .multilineTextAlignment(.center)
                Spacer()
                VStack {
                    ForEach(features) { feature in
                        VStack(alignment: .leading) {
                            HStack {
                                if let icon = feature.icon {
                                    Image(systemName: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45, alignment: .center)
                                        .clipped()
                                        .foregroundColor(color ?? Color.blue)
                                        .padding(.trailing, 15)
                                        .padding(.vertical, 10)
                                }
                                VStack(alignment: .leading) {
                                    Text(feature.title)
                                        .fontWeight(.bold)
                                        .font(.system(size: 16))
                                    Text(feature.description)
                                        .font(.system(size: 15))
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal,20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, 30)
                Spacer()
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(color ?? Color.blue)
                            .cornerRadius(12)
                            .frame(height: 54)
                        Text("Continue")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .onDisappear() {
                        UserDefaults.standard.set(true, forKey: "OnboardingSeen")
                        closingOnboarding = true
                    }
                    .onTapGesture {
                        showingOnboarding = false
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 50)
                .padding(.horizontal,15)
            }
            .padding()
        }
    }
}
