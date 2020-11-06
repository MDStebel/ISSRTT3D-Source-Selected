//
//  TrackingViewController Extension for Globe.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/21/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// Adds EarthGlobe functionality to the tracking map
extension TrackingViewController {

    
    /// Create the context globe scene
    func setupContextGlobeScene() {
        
        globe.setupInSceneView(contextGlobeScene, pinchGestureIsEnabled: false)
        
        contextGlobeScene.backgroundColor = UIColor(named: Theme.popupBgd)?.withAlphaComponent(0.50)
        contextGlobeScene.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contextGlobeScene.layer.cornerRadius = 15
        contextGlobeScene.layer.masksToBounds = true
        
    }
    
    
    /// Add the ISS position marker, orbital track, and current Sun position to the globe
    func updateEarthGlobeScene() {

        var headingFactor: Float = 1
        var showOrbit = false
        
        globe.removeLastNode()                      // Remove the last marker node, so we don't smear them together
        globe.removeLastNode()                      // Remove the last orbit track, so we don't smear them together as they precess
        globe.removeLastNode()                      // Remove the viewing circle
        
        let lat = Float(latitude) ?? 0.0
        let lon = Float(longitude) ?? 0.0
        
        if lastLat != 0 {
            showOrbit = true
            headingFactor = lat - lastLat < 0 ? -1 : 1
        }
        
        lastLat = lat                           // Save last latitude to use in calculating north or south heading vector after the second track update
        
        // Get the latitude of the Sun at the current time
        let latitudeOfSunAtCurrentTime = CoordinateCalculations.getLatitudeOfSunAtCurrentTime()
        
        // Get the longitude of Sun at current time
        let subSolarLon = CoordinateCalculations.SubSolarLongitudeOfSunAtCurrentTime()
        
        globe.setUpTheSun(lat: latitudeOfSunAtCurrentTime, lon: subSolarLon)
        if showOrbit {
            globe.addOrbitTrackAroundTheGlobe(lat: lat, lon: lon, headingFactor: headingFactor)
        }
        globe.addISSMarker(lat: lat, lon: lon)
        globe.addViewingCircle(lat: lat, lon: lon)
        globe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)
        
    }
    
   
}
