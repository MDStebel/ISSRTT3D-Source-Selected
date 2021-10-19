//
//  GlobeViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/8/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Combine
import SceneKit
import SwiftUI

final class GlobeViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    @Published var earthGlobe: EarthGlobe = EarthGlobe()
    @Published var errorForAlert: ErrorCodes?
    @Published var globeMainNode: SCNNode?
    @Published var globeScene: SCNScene?
    @Published var isStartingUp: Bool                              = true
    @Published var wasError                                        = false
    
    // MARK: - Properties
    
    private let apiEndpointString                                  = ApiEndpoints.issTrackerAPIEndpointC
    private let apiKey                                             = ApiKeys.ISSLocationKey
    private let timerValue                                         = 3.0
    
    private var cancellables: Set<AnyCancellable>                  = []
    private var hubbleHeadingFactor: Float                         = 0.0
    private var hubbleLastLat: Float                               = 0.0
    private var hubbleLatitude: Float                              = 0.0
    private var hubbleLongitude: Float                             = 0.0
    private var issHeadingFactor: Float                            = 0.0
    private var issLastLat: Float                                  = 0.0
    private var issLatitude: Float                                 = 0.0
    private var issLongitude: Float                                = 0.0
    private var tssHeadingFactor: Float                            = 0.0
    private var tssLastLat: Float                                  = 0.0
    private var tssLatitude: Float                                 = 0.0
    private var tssLongitude: Float                                = 0.0
    
    
    private var subSolarPoint: (latitude: Float, longitude: Float) = (0, 0)
    private var timer: AnyCancellable?
    
    // MARK: - Methods
    
    init() {
        
        reset()
        initHelper()
        updateEarthGlobe()                  // Update the globe once before starting the timer
        start()
        
    }
    
    
    /// Reset the globe
    func reset() {
        
        earthGlobe         = EarthGlobe()
        isStartingUp       = true
        issLastLat         = 0
        tssLastLat         = 0
        
        initHelper()
        
    }
    
    
    /// Helps with initialization and reset
    private func initHelper() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [self] in       // Show the progress indicator
            self.isStartingUp = false
        }
        
        // Set up our scene
        globeMainNode = earthGlobe.cameraNode
        globeScene    = earthGlobe.scene
        earthGlobe.setupInSceneView()
        
    }
    
    
    /// Set up and start the timer
    func start() {
        
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateEarthGlobe()
            }
        
    }
 
    
    /// Stop the timer
    func stop() {
        
        timer?.cancel()
        
    }
    
    
    /// The engine that powers this view model. Updates the globe scene for the new coordinates
    private func updateEarthGlobe() {
        
        /// Helper function to remove the last child node in the nodes array
        func removeLastNode() {
            if let nodeToRemove = earthGlobe.globe.childNodes.last {
                nodeToRemove.removeFromParentNode()
            }
        }
        
        /// We need to remove each of the nodes we've added before adding them again at new coordinates, or we get an f'ng mess!
        var numberOfChildNodes = earthGlobe.getNumberOfChildNodes()
        while numberOfChildNodes > 0 {
            removeLastNode()
            numberOfChildNodes -= 1
        }
        
        // Where are the satellites right now?
        getSatellitePosition(for: .iss)
        getSatellitePosition(for: .tss)
        getSatellitePosition(for: .hubble)
        
        // Where is the subsolar point right now?
        subSolarPoint = AstroCalculations.getSubSolarCoordinates()
        
        // If we have the last coordinates, add the markers, otherwise we don't know which way the orbits are oriented
        if issLastLat != 0 && tssLastLat != 0 && hubbleLastLat != 0 {
            
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
            
            
            // MARK: Set up Hubble
            hubbleHeadingFactor = hubbleLatitude - hubbleLastLat < 0 ? -1 : 1
            earthGlobe.addOrbitTrackAroundTheGlobe(for: .hubble, lat: hubbleLatitude, lon: hubbleLongitude, headingFactor: hubbleHeadingFactor)
            
            // Add footprint
            earthGlobe.addHubbleViewingCircle(lat: hubbleLatitude, lon: hubbleLongitude)
            
            // Add satellite marker
            earthGlobe.addHubbleMarker(lat: hubbleLatitude, lon: hubbleLongitude)
            
            
            // MARK: Set up the Sun at the current subsolar point
            earthGlobe.setUpTheSun(lat: subSolarPoint.latitude, lon: subSolarPoint.longitude)
            
        }
        
        // Saves last coordinate for each track to use in calculating north or south heading vector after the second track update
        issLastLat    = issLatitude
        tssLastLat    = tssLatitude
        hubbleLastLat = hubbleLatitude
        
    }

    
    /// Get the current satellite coordinates
    /// - Parameter satellite: The satellite we're tracking as a StationAndSatellites.
    private func getSatellitePosition(for satellite: StationsAndSatellites) {
        
        /// Helper method to extract our coordinates
        func getCoordinates(from positionData: SatelliteOrbitPosition) {
            
            switch satellite {
            case .iss :
                issLatitude     = Float(positionData.positions[0].satlatitude)
                issLongitude    = Float(positionData.positions[0].satlongitude)
            case .tss :
                tssLatitude     = Float(positionData.positions[0].satlatitude)
                tssLongitude    = Float(positionData.positions[0].satlongitude)
            case .hubble :
                hubbleLatitude  = Float(positionData.positions[0].satlatitude)
                hubbleLongitude = Float(positionData.positions[0].satlongitude)
            case .none :
                break
            }
            
        }
        
        let satelliteCodeNumber = satellite.satelliteNORADCode
        
        /// Make sure we can create the URL from the endpoint and parameters
        guard let ISSAPIEndpointURL = URL(string: apiEndpointString + "\(satelliteCodeNumber)/0/0/0/1/" + "&apiKey=\(apiKey)") else { return }
        
        /// Get data using Combine's dataTaskPublisher
        URLSession.shared.dataTaskPublisher(for: ISSAPIEndpointURL)
            .receive(on: RunLoop.main)
            .map { (data: Data, response: URLResponse) in
                data
            }
            .decode(type: SatelliteOrbitPosition.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    wasError      = true
                    errorForAlert = ErrorCodes(message: "\(error.localizedDescription)")
                } else {
                    wasError      = false
                }
            }, receiveValue: { position in
                getCoordinates(from: position)
            })
            .store(in: &cancellables)
        
    }
    
}
