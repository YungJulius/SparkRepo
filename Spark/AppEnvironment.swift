//
//  AppEnvironment.swift
//  Spark
//
//  Created by Julius  Jung on 20.11.2025.
//

// This page was created from a ChatGpt Code skeleton. The majority of the
// content however is written by Sanghita, Dania and Julius.
// Some bugs have been resolved with the usage of ChatGpt.

import Foundation
import Combine

final class AppEnvironment: ObservableObject {

    let locationService = LocationService()
    let weatherService = WeatherService()
    let emotionService = EmotionService.shared
    let storageService = StorageService.shared
    let unlockService: UnlockService

    init() {
        unlockService = UnlockService(
            location: locationService,
            weather: weatherService,
            emotion: emotionService
        )

        storageService.load()
    }
}
