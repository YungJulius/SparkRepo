//
//  LocationService.swift
//  Spark
//
//  Created by Julius  Jung on 20.11.2025.
//

import Foundation
import CoreLocation
import Combine


struct Geofence: Codable, Hashable {
    var id: UUID = UUID()
    let latitude: Double
    let longitude: Double
    let radius: Double
}

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startMonitoring() {
        manager.startUpdatingLocation()
    }

    func stopMonitoring() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startMonitoring()
        default:
            stopMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func isWithinGeofence(_ geofence: Geofence, from location: CLLocation) -> Bool {
        let target = CLLocation(latitude: geofence.latitude, longitude: geofence.longitude)
        return location.distance(from: target) <= geofence.radius
    }
}
