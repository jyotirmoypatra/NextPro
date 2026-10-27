//
//  LocationManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/03/26.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var address: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus?
    var onLocationError: ((String) -> Void)?
    
    private var updateCount = 0
    private let requiredUpdates = 3
    /// Guards against `onLocationReady`/`onLocationError` firing more than once per
    /// `startLocation()` call — CLLocationManager can still deliver an already-queued
    /// location update after `stopUpdatingLocation()` is called, which would otherwise
    /// re-satisfy `updateCount >= requiredUpdates` and fire the ready callback twice.
    private var hasFinished = false
    
    var onLocationReady: (() -> Void)?   // main trigger
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestLocationAccess() {
        manager.requestWhenInUseAuthorization()
    }

    var isLocationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    var currentAuthorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    var isPreciseLocationEnabled: Bool {
        manager.accuracyAuthorization == .fullAccuracy
    }
    
    func startLocation() {
        authorizationStatus = manager.authorizationStatus

        guard isLocationServicesEnabled else {
            onLocationError?(
                """
                Location Services are OFF

                Go to:
                Settings → Privacy & Security → Location Services → Turn ON
                """
            )
            return
        }

        guard currentAuthorizationStatus == .authorizedWhenInUse || currentAuthorizationStatus == .authorizedAlways else {
            onLocationError?(
                """
                Location permission required

                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """
            )
            return
        }

        guard isPreciseLocationEnabled else {
            onLocationError?(
                """
                Precise Location is OFF

                Go to:
                Settings → Apps → Zlyx → Location → Turn ON Precise Location
                """
            )
            return
        }

        updateCount = 0
        hasFinished = false
        latitude = ""
        longitude = ""
        address = ""
        manager.startUpdatingLocation()

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !hasFinished else { return }

        guard CLLocationManager.locationServicesEnabled() else {
            hasFinished = true
            manager.stopUpdatingLocation()
            onLocationError?(
                """
                Location Services are OFF

                Go to:
                Settings → Privacy & Security → Location Services → Turn ON
                """
            )
            return
        }

        guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else {
            hasFinished = true
            manager.stopUpdatingLocation()
            onLocationError?(
                """
                Location permission required

                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """
            )
            return
        }

        guard manager.accuracyAuthorization == .fullAccuracy else {
            hasFinished = true
            manager.stopUpdatingLocation()
            onLocationError?(
                """
                Precise Location is OFF

                Go to:
                Settings → Apps → Zlyx → Location → Turn ON Precise Location
                """
            )
            return
        }

        guard let location = locations.last else { return }
        
        updateCount += 1
        
        print("📍 Update \(updateCount), accuracy: \(location.horizontalAccuracy)")
        
        // Ignore bad accuracy
        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= 50 else { return }
        
        // Wait for 3 updates
        guard updateCount >= requiredUpdates else { return }

        hasFinished = true

        //  FINAL LOCATION
        latitude = "\(location.coordinate.latitude)"
        longitude = "\(location.coordinate.longitude)"
        
        manager.stopUpdatingLocation()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                self.address = [
                    place.name,
                    place.locality,
                    place.administrativeArea,
                    place.country
                ].compactMap { $0 }.joined(separator: ", ")
            }

            DispatchQueue.main.async {
                print("Location Ready")
                self.onLocationReady?()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !hasFinished else { return }
        hasFinished = true
        manager.stopUpdatingLocation()
        onLocationError?(error.localizedDescription)
    }
}
