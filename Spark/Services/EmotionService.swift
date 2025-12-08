//
//  MoodService.swift
//  Spark
//
//  Created by Julius  Jung on 20.11.2025.
//

// This page was created from a ChatGpt Code skeleton. The majority of the
// content however is written by Sanghita, Dania and Julius.
// Some bugs have been resolved with the usage of ChatGpt.

import Foundation
import Combine

enum Emotion: String, Codable, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }

    case happy
    case sad
    case angry
    case relaxed
    case excited
    case stressed
    case bored
    case anxious
    case grateful
    case calm
    case energetic
    case tired
}

final class EmotionService: ObservableObject {
    static let shared = EmotionService()

    @Published private(set) var currentEmotion: Emotion?

    private let key = "currentEmotion"

    private init() {
        load()
    }

    func setEmotion(_ emotion: Emotion) {
        currentEmotion = emotion
        UserDefaults.standard.set(emotion.rawValue, forKey: key)
    }

    func load() {
        if let raw = UserDefaults.standard.string(forKey: key),
           let emotion = Emotion(rawValue: raw) {
            currentEmotion = emotion
        } else {
            // First launch = happy
            currentEmotion = .happy
            UserDefaults.standard.set(Emotion.happy.rawValue, forKey: key)
        }
    }
}
