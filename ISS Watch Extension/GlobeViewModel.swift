//
//  EarthViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/8/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit
import WatchKit

class GlobeViewModel: ObservableObject {
    @Published var globeMainNode: SCNNode?
    @Published var globeScene: SCNScene?
    
    var gestureHost: WKInterfaceSCNScene?
    
    let earthGlobe       = EarthGlobe()
    var latitude: Float  = -20.0
    var longitude: Float = -50.0
    
    init() {
        updateUpEarthGlobe()
    }
    
    private func getISSPosition() {
        
    }
    
    func updateUpEarthGlobe() {
        globeMainNode = earthGlobe.cameraNode
        globeScene    = earthGlobe.scene
        earthGlobe.setupInSceneView()
        
        getISSPosition()
        earthGlobe.addOrbitTrackAroundTheGlobe(lat: latitude, lon: longitude, headingFactor: 1.0)
        earthGlobe.addISSMarker(lat: latitude, lon: longitude)
        
        let subSolarPoint = AstroCalculations.getSubSolarCoordinates()
        earthGlobe.setUpTheSun(lat: subSolarPoint.latitude, lon: subSolarPoint.longitude)
    }
    
}
