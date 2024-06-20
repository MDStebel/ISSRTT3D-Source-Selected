//
//  LocationViewModel.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 6/16/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

final class LocationViewModel: ObservableObject {
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var latitude: Double  = 0.0
    @Published var longitude: Double = 0.0
    
    var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.authorizationStatus = locationManager.authorizationStatus
        
        locationManager.$location
            .compactMap { $0 }
            .map { $0.coordinate }
            .sink { [weak self] coordinate in
                print("Coordinate received: \(coordinate.latitude), \(coordinate.longitude)")
                self?.latitude = coordinate.latitude
                self?.longitude = coordinate.longitude
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .assign(to: \.authorizationStatus, on: self)
            .store(in: &cancellables)
    }
}
