//
//  GlobeFullViewController Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension GlobeFullViewController {
    
    /// Method to get current ISS coordinates from JSON file and show it on the globe. Called by timer selector.
    @objc func earthGlobeLocateISS() {
        
        
        // Make sure we can create the URL
        guard let apiEndpointURL = URL(string: Constants.apiEndpointAString) else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: apiEndpointURL) { [ weak self ] (data, response, error) -> Void in
            
            // Uses a capture list to capture a weak reference to self
            // This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                if let parsedOrbitalPosition = OrbitalPosition.parseLocationSpeedAndAltitude(from: urlContent) {
                    
                    // Get current location
                    self?.latitude  = String(parsedOrbitalPosition.latitude)
                    self?.longitude = String(parsedOrbitalPosition.longitude)
                    
                    
                    // Update globe
                    DispatchQueue.main.async {
                        self?.updateEarthGlobeScene(in: self!.fullGlobe, latitude: self!.latitude, longitude: self!.longitude, lastLat: &self!.lastLat)
                        self?.isRunningLabel?.text = "Running"
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self?.alert(for: "Can't get ISS location", message: "Wait a few minutes\nand then tap ▶︎ again.")
                        self?.isRunningLabel?.text = "Not Running"
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self?.cannotConnectToInternetAlert()
                    self?.isRunningLabel?.text = "Not Running"
                }
                
            }
            
        }
        
        globeUpdateTask.resume()
        
    }
    
}
