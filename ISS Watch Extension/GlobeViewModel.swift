//
//  GlobeViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/8/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit

class GlobeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var earthGlobe: EarthGlobe
    @Published var globeMainNode: SCNNode?
    @Published var globeScene: SCNScene?

    let apiKey                  = ApiKeys.ISSLocationKey
    let timerValue              = 5.0
   
    var hasRun: Bool
    var ISSHeadingFactor: Float = 0.0
    var ISSLastLat: Float
    var latitude: Float         = 0.0
    var longitude: Float        = 0.0
    var timer                   = Timer()
    
    // MARK: - Methods
    
    init() {
        
        earthGlobe = EarthGlobe()
        hasRun     = false
        ISSLastLat = 0
        
        startTimer()
        updateEarthGlobe()
    }
    
    
    /// Get the current ISS coordinates
    private func getISSPosition() {
        let apiEndpointString = ApiEndpoints.issTrackerAPIEndpointC
        
        // Make sure we can create the URL
        guard let ISSAPIEndpointURL = URL(string: apiEndpointString + "&apiKey=\(apiKey)") else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for ISS data, and then display ISS position, etc.
        let globeUpdateTask = URLSession.shared.dataTask(with: ISSAPIEndpointURL) { [ weak self ] (data, response, error) -> Void in
            // Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
            
            if let urlContent = data {
                
                let decoder = JSONDecoder()
                
                do {
                    // Call JSON parser and if successful (i.e., doesn't return nil) map the coordinates
                    let parsedISSOrbitalPosition = try decoder.decode(ISSOrbitalPosition2.self, from: urlContent)
                        // Get current ISS location
                        let coordinates          = parsedISSOrbitalPosition.positions
                        self?.latitude           = Float(coordinates[0].satlatitude)
                        self?.longitude          = Float(coordinates[0].satlongitude)

                } catch {
                    return
                }
            } else {
                return
            }
        }
        
        globeUpdateTask.resume()
        
    }
       
    
    /// Update the globe scene
    func updateEarthGlobe() {
        
        // We have to remove the dynamic nodes (Sun, ISS, orbit track), if we've already updated them once. If not, just remove the first two that were created when we initialized.
        if hasRun {
            for _ in 1...3 {
                removeLastNode()
            }
        } else {
            for _ in 1...2 {
                removeLastNode()
            }
        }
            
        globeMainNode = earthGlobe.cameraNode
        globeScene    = earthGlobe.scene
        earthGlobe.setupInSceneView()
        
        getISSPosition()
        
        // Determine if we have a prior ISS latitude saved, as we don't know which way the orbit is oriented unless we do
        if ISSLastLat != 0 {
            ISSHeadingFactor = latitude - ISSLastLat < 0 ? -1 : 1
        }
        ISSLastLat = latitude   // Saves last latitude to use in calculating north or south heading vector after the second track update
        
        earthGlobe.addOrbitTrackAroundTheGlobe(lat: latitude, lon: longitude, headingFactor: ISSHeadingFactor)
        earthGlobe.addISSMarker(lat: latitude, lon: longitude)
        
        let subSolarPoint = AstroCalculations.getSubSolarCoordinates()
        earthGlobe.setUpTheSun(lat: subSolarPoint.latitude, lon: subSolarPoint.longitude)
        
        hasRun = true
    }
    
    
    /// Remove the last child node in the nodes array
    private func removeLastNode() {
        if let nodeToRemove = earthGlobe.globe.childNodes.last {
            nodeToRemove.removeFromParentNode()
        }
    }
    
    
    /// Setup and start the timer
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    
    /// The selector the timer calls
    @objc func update() {
       updateEarthGlobe()
    }
    
    /// Stop the timer
    func stop() {
        timer.invalidate()
    }
}
