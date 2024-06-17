//
//  CoordinatesViewModel.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 6/16/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        self.location = location
        saveLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
//        print("Authorization status changed: \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    /// Save location in app group
    /// - Parameters:
    ///   - lat: The latitude as a double
    ///   - lon: The longitude as a double
    private func saveLocation(latitude lat: Double, longitude lon: Double) {
        let sharedDefaults = UserDefaults(suiteName: Globals.appSuiteName)
           sharedDefaults?.set(lat, forKey: "latitude")
           sharedDefaults?.set(lon, forKey: "longitude")
//        print("saved")
       }
}
