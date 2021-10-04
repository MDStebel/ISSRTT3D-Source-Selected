//
//  SatellitePositionViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Combine
import SwiftUI

final class SatellitePositionViewModel: ObservableObject {
    
    
    // MARK: - Published properties
    
    @Published var errorForAlert: ErrorCodes?
    @Published var formattedAltitude: String       = ""
    @Published var formattedLatitude: String       = ""
    @Published var formattedLongitude: String      = ""
    
    // MARK: - Properties
    
    private let apiEndpointString                  = ApiEndpoints.issTrackerAPIEndpointC
    private let apiKey                             = ApiKeys.ISSLocationKey
    private let numberFormatter                    = NumberFormatter()
    private let timerValue                         = 3.0
    
    private var altitude: Float                    = 0
    private var cancellables: Set<AnyCancellable>  = []
    private var latitude: Float                    = 0
    private var longitude: Float                   = 0
    private var satellite: StationsAndSatellites
    private var timer: AnyCancellable?
    
    
    // MARK: - Methods
    
    /// Initialize for a specific satellite
    init(satellite: StationsAndSatellites) {
        
        self.satellite = satellite
        startUp()
    }
    
    
    /// Startup by calling
    func startUp() {
        
        getSatellitePosition(for: satellite)   // Get the data once before starting the timer
        start()
    }
    
    
    /// Set up and start the timer
    private func start() {
        
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.getSatellitePosition(for: self.satellite)
            }
    }
    
    
    /// Stop the timer
    func stop() {
        
        timer?.cancel()
    }
    
    
    /// Get the current satellite coordinates
    private func getSatellitePosition(for satellite: StationsAndSatellites) {
        
        /// Helper method to extract our altitude and coordinates and format them
        func getCoordinates(from positionData: SatelliteOrbitPosition) {
            
            altitude            = Float(positionData.positions[0].sataltitude)
            let altitudeInKm    = numberFormatter.string(from: NSNumber(value: Double(altitude))) ?? ""
            let altitudeInMiles = numberFormatter.string(from: NSNumber(value: Double(altitude) * Globals.kilometersToMiles)) ?? ""
            formattedAltitude   = "\(altitudeInKm) km\n(\(altitudeInMiles) mi)"
            
            latitude            = Float(positionData.positions[0].satlatitude)
            formattedLatitude   = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(latitude), format: Globals.coordinatesStringFormat, isLatitude: true)
            
            longitude           = Float(positionData.positions[0].satlongitude)
            formattedLongitude  = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(longitude), format: Globals.coordinatesStringFormat, isLatitude: false)
        }
        
        let satelliteCodeNumber = satellite.satelliteNORADCode
        
        /// Make sure we can create the URL from the endpoint and parameters
        guard let ISSAPIEndpointURL = URL(string: apiEndpointString + "\(satelliteCodeNumber)/0/0/0/1/" + "&apiKey=\(apiKey)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: ISSAPIEndpointURL)
            .receive(on: RunLoop.main)
            .map { (data: Data, response: URLResponse) in
                data
            }
            .decode(type: SatelliteOrbitPosition.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    errorForAlert = ErrorCodes(message: "\(error.localizedDescription)")
                }
            }, receiveValue: { position in
                getCoordinates(from: position)
            })
            .store(in: &cancellables)
    }
}
