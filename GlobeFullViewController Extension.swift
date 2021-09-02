//
//  GlobeFullViewController Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension GlobeFullViewController {
    
    
    fileprivate func updateGlobeForPositionsOfStations() {
        
        DispatchQueue.main.async {
            self.updateEarthGlobeScene(in: self.fullGlobe, ISSLatitude: self.iLat, ISSLongitude: self.iLon, TSSLatitude: self.tLat, TSSLongitude: self.tLon, ISSLastLat: &self.ISSLastLat, TSSLastLat: &self.TSSLastLat)
            self.isRunningLabel?.text = "Running"
        }
        
    }
    
    
    /// Method to get current ISS and TSS coordinates from the API and update the globe. Can be called by a timer.
    @objc func earthGlobeLocateStations() {
        
        // Make sure we can create the URL
        guard let ISSAPIEndpointURL = URL(string: Constants.ISSAPIEndpointString) else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: ISSAPIEndpointURL) { [ weak self ] (data, response, error) -> Void in
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                if let parsedISSOrbitalPosition = ISSOrbitalPosition.parseLocationSpeedAndAltitude(from: urlContent) {
                    
                    // Background image may have been changed by user in Settings. If so, change it.
                    if Globals.globeBackgroundWasChanged {
                        DispatchQueue.main.async {
                            self?.setGlobeBackgroundImage()
                        }
                        Globals.globeBackgroundWasChanged = false
                    }
                    
                    // Get current ISS location
                    self?.iLat = String(parsedISSOrbitalPosition.latitude)
                    self?.iLon = String(parsedISSOrbitalPosition.longitude)
                    
                    // Get the current TSS location
                    self?.earthGlobeLocateTSS()
                    
                    // Update positions of all space stations, or satellites
                    self?.updateGlobeForPositionsOfStations()
                    
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
    
    
    /// Method to get current TSS coordinates from the API and update the globe.
    func earthGlobeLocateTSS() {
        
        // Make sure we can create the URL
        let URLString = URL(string: Constants.TSSAPIEndpointString + "&apiKey=\(Constants.TSSAPIKey)")
        guard let TSSAPIEndpointURL = URLString else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for TSS data, and then display TSS position, etc.
        let globeUpdateTaskForTSS = URLSession.shared.dataTask(with: TSSAPIEndpointURL) { [ weak self ] (data, response, error) in
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    // Parse JSON
                    let parsedTSSOrbitalPosition = try decoder.decode(TSSOrbitalPosition.self, from: urlContent)
                    
                    // Get current TSS coordinates
                    self?.TSSCoordinates         = parsedTSSOrbitalPosition.positions
                    self?.TSSLatitude            = self?.TSSCoordinates[0].satlatitude ?? 0.0
                    self?.TSSLongitude           = self?.TSSCoordinates[0].satlongitude ?? 0.0
                    
                    self?.tLat                   = String((self?.TSSLatitude)!)
                    self?.tLon                   = String((self?.TSSLongitude)!)
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        // self?.alert(for: "Can't get TSS location", message: "Will automatically start again when available.")
                        self?.isRunningLabel?.text = "Can't get TSS location"
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    // self?.alert(for: "Can't get TSS location", message: "Will automatically start again when available.")
                    self?.isRunningLabel?.text = "Can't get TSS location"
                }
                
            }
            
        }
        
        globeUpdateTaskForTSS.resume()
        
    }
    
}
