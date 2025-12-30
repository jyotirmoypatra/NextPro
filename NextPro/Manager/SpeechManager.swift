//
//  SpeechManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/12/25.
//


import AVFoundation
import UIKit

final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = SpeechManager()

    private var synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()

    private override init() {
        super.init()
        synthesizer.delegate = self
        setupNotifications()
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }

        prepareAudioSession()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.42
        utterance.pitchMultiplier = 0.95
        utterance.volume = 0.9
        utterance.postUtteranceDelay = 0.1   // small pause after speaking

        synthesizer.speak(utterance)
        
    }
    
    private func prepareAudioSession() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
            try audioSession.setActive(true)
        } catch {
            print("❌ Speech audio session error:", error)
        }
    }
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioInterrupted),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func appBecameActive() {
        print("🔊 Resetting speech synthesizer")

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
    }

    
    @objc private func audioInterrupted(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        if type == .began {
            synthesizer.stopSpeaking(at: .immediate)
        } else {
            prepareAudioSession()
        }
    }

}
