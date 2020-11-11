//
//  Locate ISS TrackingViewController Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 7/9/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import MapKit


extension TrackingViewController {
    
    /// Update the info box data 
    private func updateCoordinatesDisplay() {
        
        altitudeLabel?.text = altString
        coordinatesLabel?.text = positionString
        velocityLabel?.text = velString
        
    }
    
    
    /// Draw orbit ground track line overlay
    private func drawOrbitGroundTrackLine() {
        
        listOfCoordinates.append(CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!, CLLocationDegrees(longitude)!))
        let index = listOfCoordinates.count
        
        // Plot the orbit ground track line, if enabled and only when we have at least two coordinates
        if Globals.orbitGroundTrackLineEnabled && index >= 2  {
            let aPolyLine = MKPolyline(coordinates: [listOfCoordinates[index-2], listOfCoordinates[index-1]], count: 2)
            map.addOverlay(aPolyLine)
        }
        
        // Remove first n coordinates, as we only need the last two (keeps array small)
        let maxCoordinatesInArray = 4
        if index == maxCoordinatesInArray {
            listOfCoordinates.removeFirst(maxCoordinatesInArray - 1)
        }
        
    }
    
    
    /// Set up the overlays and any buttons that depend on settings
    fileprivate func setupAllOverlaysAndButtons() {
        
        DispatchQueue.main.async {
            
            self.setUpDisplayConfiguration()
            
            if Globals.zoomFactorWasResetInSettings {           // If reset was pressed in Settings, or if the zoom scale factor was changed, this flag will be set.
                // So, reset zoom to default values for the selected scale factor and call zoomValueChanged method.
                self.setUpZoomSlider(usingSavedZoomFactor: false)
                self.zoomValueChanged(self.zoomSlider)
            }
            
            if Globals.showCoordinatesIsOn {
                self.displayInfoBoxAndLandsatButton(true)
            } else {
                self.displayInfoBoxAndLandsatButton(false)
            }
            
            if Globals.displayZoomFactorBelowMarkerIsOn {
                self.zoomFactorLabel.isHidden = false
                self.setupZoomFactorLabel(self.timerValue)
            } else {
                self.zoomFactorLabel.isHidden = true
            }
            
            if Globals.orbitGroundTrackLineEnabled {
                self.clearOrbitTrackButton.alpha = 1.0
                self.clearOrbitTrackButton.isEnabled = true
            } else {
                self.clearOrbitTrackButton.alpha = 0.65
                self.clearOrbitTrackButton.isEnabled = false
            }
            
            self.cursor.isHidden = false                        // Now, show the marker
            
        }
        
    }
    
    
    /// Method to get current ISS coordinates from JSON file and animate its display on map. Called by timer selector.
    @objc func locateISS() {
        
        setupAllOverlaysAndButtons()
        
        // Make sure we can create the URL
        guard let apiEndpointURL = URL(string: Constants.apiEndpointAString) else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let locateAndDisplayISSPositionTask = URLSession.shared.dataTask(with: apiEndpointURL) { [ weak self ] (data, response, error) -> Void in
            
            // Uses a capture list to capture a weak reference to self
            // This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                if let parsedOrbitalPosition = OrbitalPosition.parseLocationSpeedAndAltitude(from: urlContent) {
                    
                    // Get current location
                    self?.latitude = String(parsedOrbitalPosition.latitude)
                    self?.longitude = String(parsedOrbitalPosition.longitude)
                    self?.atDateAndTime = String(parsedOrbitalPosition.time)
                    self?.altitude = String(parsedOrbitalPosition.altitude)
                    self?.velocity = String(parsedOrbitalPosition.velocity)
                    
                    // Update map and overlays in the main queue
                    DispatchQueue.main.async {
                        
                        // Update map position
                        self?.map.setRegion(self!.region, animated: true)
                        
                        // Update the coordinates in the info box, if enabled
                        if Globals.showCoordinatesIsOn {
                            self?.updateCoordinatesDisplay()
                        }
                        
                        // Draw ground track, if enabled
                        self?.drawOrbitGroundTrackLine()
                        
                        // Update globe with ISS position and orbital track, if enabled
                        if Globals.displayGlobe {
                            self?.setUpCoordinatesLabel(withTopCorners: false)
                            self?.globeScene.isHidden = false
                            self?.globeExpandButton.isHidden = false
                            self?.updateEarthGlobeScene(in: self!.globe, latitude: self!.latitude, longitude: self!.longitude, lastLat: &self!.lastLat)
                        } else {
                            self?.setUpCoordinatesLabel(withTopCorners: true)
                            self?.globeScene.isHidden = true
                            self?.globeExpandButton.isHidden = true
                        }
                        
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self?.stopAction()
                        self!.alert(for: "Can't get ISS location", message: "Wait a few minutes\nand then tap ▶︎ again.")
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self?.stopAction()
                    self!.cannotConnectToInternetAlert()
                }
                
            }
            
        }
        
        // Start task
        locateAndDisplayISSPositionTask.resume()
        
    }
    
}
