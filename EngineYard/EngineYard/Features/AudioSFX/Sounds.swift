//
//  Sounds.swift
//  EngineYard
//
//  Created by Amarjit on 29/03/2025.
//

import AVFoundation

enum Sounds: String, CaseIterable {
    case click = "Birdy_Note5.wav"
    case notify = "Birdy_Notification1.wav"
    case cardOpen = "cardSlide8.wav"
    case cardSlide1 = "cardSlide1.wav"
    case cardSlide2 = "cardSlide2.wav"
    case cardSlide3 = "cardSlide3.wav"
    case dieThrow1 = "dieThrow1.ogg"
    case dieThrow2 = "dieThrow2.ogg"
}

class SoundPlayer: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    func playSound(_ sound: Sounds) {
        guard !isPlaying else {
            return
        }
        
        if let soundURL = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found: \(sound.rawValue)")
        }
    }
}

extension SoundPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
