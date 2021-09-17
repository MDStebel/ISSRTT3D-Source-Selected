//
//  ISSPositionViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

final class ISSPositionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var issLatitude: String  = ""
    @Published var issLongitude: String = ""
    
    private let apiEndpointString       = ApiEndpoints.issTrackerAPIEndpointC
    private let apiKey                  = ApiKeys.ISSLocationKey
    private let timerValue              = 3.0
    
    private var timer                   = Timer()
    private var latitude: Float         = 0
    private var longitude: Float        = 0
    
    
    // MARK: - Methods
    
    init() {
        startUp()
    }
    
    
    func startUp() {
        
        updateISSPosition()   // Get the data once before starting the timer
        startISSTimer()
    }
    
    
    private func updateISSPosition() {
        getISSPosition()
    }
    
    
    /// Get the current ISS coordinates
    private func getISSPosition() {
        
        // Make sure we can create the URL
        guard let ISSAPIEndpointURL = URL(string: apiEndpointString + "&apiKey=\(apiKey)") else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: ISSAPIEndpointURL) { [ weak self ] (data, response, error) -> Void in
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                let decoder = JSONDecoder()
                do {
                    // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                    let parsedISSOrbitalPosition = try decoder.decode(SatelliteOrbitPosition.self, from: urlContent)
                    // Get current ISS location
                    let coordinates              = parsedISSOrbitalPosition.positions
                    
                    DispatchQueue.main.async {
                        self?.latitude           = Float(coordinates[0].satlatitude)
                        self?.longitude          = Float(coordinates[0].satlongitude)
                        self?.issLatitude        = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(self!.latitude), format: Globals.coordinatesStringFormat, isLatitude: true)
                        self?.issLongitude       = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(self!.longitude), format: Globals.coordinatesStringFormat, isLatitude: false)
                    }
                } catch {
                    return
                }
            } else {
                return
            }
        }
        
        globeUpdateTask.resume()
    }
    
    
    /// Set up and start the timer
    private func startISSTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(updateISS), userInfo: nil, repeats: true)
        
    }
    
    
    /// The selector the timer calls
    @objc func updateISS() {
        updateISSPosition()
    }
    
    
    /// Stop the timer
    func stop() {
        timer.invalidate()
    }
}
