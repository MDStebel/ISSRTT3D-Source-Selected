//
//  GlobeViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/8/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

final class GlobeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var earthGlobe: EarthGlobe
    @Published var globeMainNode: SCNNode?
    @Published var globeScene: SCNScene?
    @Published var hasRun: Bool
    
    private let apiEndpointString       = ApiEndpoints.issTrackerAPIEndpointC
    private let apiKey                  = ApiKeys.ISSLocationKey
    private let timerValue              = 3.0
    
    private var issHeadingFactor: Float = 0.0
    private var tssHeadingFactor: Float = 0.0
    private var issLastLat: Float
    private var tssLastLat: Float
    private var issLatitude: Float      = 0.0
    private var issLongitude: Float     = 0.0
    private var tssLatitude: Float      = 0.0
    private var tssLongitude: Float     = 0.0
    private var timer                   = Timer()
    
    
    // MARK: - Methods
    
    init() {
        
        earthGlobe         = EarthGlobe()
        hasRun             = false
        issLastLat         = 0
        tssLastLat         = 0
        
        initHelper()
        
        updateEarthGlobe()                  // Update the globe once before starting the timer
        startTimer()
    }
    
    
    /// Reset the globe
    func reset() {
        
        earthGlobe         = EarthGlobe()
        hasRun             = false
        issLastLat         = 0
        tssLastLat         = 0
        
        initHelper()
    }
    
    
    private func initHelper() {
        
        // Show the progress indicator.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            self.hasRun = true
        }
        
        globeMainNode = earthGlobe.cameraNode
        globeScene    = earthGlobe.scene
        earthGlobe.setupInSceneView()
    }
    
    
    /// Get the current ISS coordinates
    func getISSPosition() {
        
        let satelliteCodeNumber = StationsAndSatellites.iss.satelliteNORADCode
        
        // Make sure we can create the URL
        guard let ISSAPIEndpointURL = URL(string: apiEndpointString + "\(satelliteCodeNumber)/0/0/0/1/" + "&apiKey=\(apiKey)") else { return }
        
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
                        self?.issLatitude        = Float(coordinates[0].satlatitude)
                        self?.issLongitude       = Float(coordinates[0].satlongitude)
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
    
    
    /// Get the current TSS coordinates
    func getTSSPosition() {
        
        let satelliteCodeNumber = StationsAndSatellites.tss.satelliteNORADCode
        
        // Make sure we can create the URL
        guard let TSSAPIEndpointURL = URL(string: apiEndpointString + "\(satelliteCodeNumber)/0/0/0/1/" + "&apiKey=\(apiKey)") else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for TSS data, and then display TSS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: TSSAPIEndpointURL) { [ weak self ] (data, response, error) -> Void in
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                let decoder = JSONDecoder()
                do {
                    
                    // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                    let parsedTSSOrbitalPosition = try decoder.decode(SatelliteOrbitPosition.self, from: urlContent)
                    
                    // Get current TSS location
                    let coordinates              = parsedTSSOrbitalPosition.positions
                    
                    DispatchQueue.main.async {
                        self?.tssLatitude        = Float(coordinates[0].satlatitude)
                        self?.tssLongitude       = Float(coordinates[0].satlongitude)
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
    
    
    /// Update the globe scene for the new coordinates
    private func updateEarthGlobe() {
        
        // We need to remove each of the nodes we've added before adding them again at new coordinates, or we get an f'ng mess!
        var numberOfChildNodes  = earthGlobe.getNumberOfChildNodes()
        while numberOfChildNodes > 0 {
            removeLastNode()
            numberOfChildNodes -= 1
        }
        
        // Where are the satellites right now?
        getISSPosition()
        getTSSPosition()
        
        // If we have a saved last coordinate, add the markers, otherwise we don't know which way the orbit is oriented
        if issLastLat != 0 {
            
            DispatchQueue.main.async { [self] in
                
                // MARK: Set up ISS
                issHeadingFactor = issLatitude - issLastLat < 0 ? -1 : 1
                earthGlobe.addOrbitTrackAroundTheGlobe(for: .iss, lat: issLatitude, lon: issLongitude, headingFactor: issHeadingFactor)
                
                // Add footprint
                earthGlobe.addISSViewingCircle(lat: issLatitude, lon: issLongitude)
                
                // Add satellite marker
                earthGlobe.addISSMarker(lat: issLatitude, lon: issLongitude)
                
                
                // MARK: Set up TSS
                tssHeadingFactor = tssLatitude - tssLastLat < 0 ? -1 : 1
                earthGlobe.addOrbitTrackAroundTheGlobe(for: .tss, lat: tssLatitude, lon: tssLongitude, headingFactor: tssHeadingFactor)
                
                // Add footprint
                earthGlobe.addTSSViewingCircle(lat: tssLatitude, lon: tssLongitude)
                
                // Add satellite marker
                earthGlobe.addTSSMarker(lat: tssLatitude, lon: tssLongitude)
                
                
                // MARK: Set up the Sun at the current subsolar point
                let subSolarPoint = AstroCalculations.getSubSolarCoordinates()
                earthGlobe.setUpTheSun(lat: subSolarPoint.latitude, lon: subSolarPoint.longitude)
            }
        }
        
        // Saves last coordinate for each track to use in calculating north or south heading vector after the second track update
        issLastLat = issLatitude
        tssLastLat = tssLatitude
    }
    
    
    /// Remove the last child node in the nodes array
    private func removeLastNode() {
        if let nodeToRemove = earthGlobe.globe.childNodes.last {
            nodeToRemove.removeFromParentNode()
        }
    }
    
    
    /// Set up and start the timer
    func startTimer() {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    
    /// The selector that the timer calls
    @objc func update() {
        updateEarthGlobe()
    }
    
    
    /// Stop the timer
    func stop() {
        timer.invalidate()
    }
}
