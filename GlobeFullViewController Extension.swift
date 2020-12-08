//
//  GlobeFullViewController Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension GlobeFullViewController {
    
    /// Method to get current ISS coordinates from the API and update the globe. Can be called by a timer.
    @objc func earthGlobeLocateISS() {
        
        // Make sure we can create the URL
        guard let apiEndpointURL = URL(string: Constants.apiEndpointAString) else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: apiEndpointURL) { [ weak self ] (data, response, error) -> Void in
            
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                if let parsedOrbitalPosition = OrbitalPosition.parseLocationSpeedAndAltitude(from: urlContent) {
                    
                    // Get current location
                    self?.latitude  = String(parsedOrbitalPosition.latitude)
                    self?.longitude = String(parsedOrbitalPosition.longitude)
                    
                    // Update globe
                    if Globals.globeBackgroundWasChanged {            // Background image may have been changed by user in Settings. If so, change it.
                        DispatchQueue.main.async {
                            self!.setGlobeBackgroundImage()
                        }
                        Globals.globeBackgroundWasChanged = false
                    }
                    DispatchQueue.main.async {
                        self?.updateEarthGlobeScene(in: self!.fullGlobe, latitude: self!.latitude, longitude: self!.longitude, lastLat: &self!.lastLat)
                        self?.isRunningLabel?.text = "Running"
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self?.alert(for: "Can't get ISS location", message: "Will automatically start again when available.")
                        self?.isRunningLabel?.text = "Not running"
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self?.alert(for: "Can't connect to Internet", message: "Will automatically start again when connected.")
                    self?.isRunningLabel?.text = "Not running"
                }
                
            }
            
        }
        
        globeUpdateTask.resume()
        
    }
    
}
