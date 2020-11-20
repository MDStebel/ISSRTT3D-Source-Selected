//
//  EarthGlobeProtocol.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 11/10/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit
import UIKit


/// Protocol that adds EarthGlobe support to a UIViewController subclass, with properties and methods to create the scene and update it
protocol EarthGlobeProtocol: UIViewController {
    
    var lastLat: Float { get set }
    
    func setUpEarthGlobeScene(for globe: EarthGlobe, in scene: SCNView, hasTintedBackground: Bool)
    func updateEarthGlobeScene(in globe: EarthGlobe, latitude: String, longitude: String, lastLat: inout Float )
    
}


/// Default implementations
extension EarthGlobeProtocol {
    
    /// Create the context globe scene
    /// - Parameters:
    ///   - globe: Which globe instance to set up in the scene
    ///   - scene: The scene to use
    func setUpEarthGlobeScene(for globe: EarthGlobe, in scene: SCNView, hasTintedBackground: Bool) {
        
        globe.setupInSceneView(scene, customPinchGestureIsEnabled: false)
        
        if hasTintedBackground {
            scene.backgroundColor = UIColor(named: Theme.popupBgd)?.withAlphaComponent(0.50)        // Tinted for map view overlay mode
            scene.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            scene.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)                    // Transparent background for full-screen mode
        }
        
        scene.layer.cornerRadius = 15
        scene.layer.masksToBounds = true
        
    }
    
    
    /// Add the ISS position marker, orbital track, and current Sun position to the globe
    /// - Parameters:
    ///   - globe: Which globe instance to use
    ///   - latitude: The latitude
    ///   - longitude: The longitude
    ///   - lastLat: The last latitude as a mutating parameter
    func updateEarthGlobeScene(in globe: EarthGlobe, latitude: String, longitude: String, lastLat: inout Float ) {
        
        var headingFactor: Float = 1
        var showOrbitNow = false
        
        globe.removeLastNode()                      // Remove the last marker node, so we don't smear them together
        globe.removeLastNode()                      // Remove the last orbit track, so we don't smear them together as they precess
        globe.removeLastNode()                      // Remove the viewing circle
        
        let lat = Float(latitude) ?? 0.0
        let lon = Float(longitude) ?? 0.0
        
        if lastLat != 0 {
            showOrbitNow = true
            headingFactor = lat - lastLat < 0 ? -1 : 1
        }
        lastLat = lat                               // Saves last latitude to use in calculating north or south heading vector after the second track update
        
        // Get the latitude of the subsolar point at the current time
        let latitudeOfSunAtCurrentTime = AstroCalculations.getLatitudeOfSunAtCurrentTime()
        
        // Get the longitude of subsolar point at current time
        let subSolarLon = AstroCalculations.getSubSolarLongitudeOfSunAtCurrentTime()
        
        // Now, set up the Sun at the subsolar point
        globe.setUpTheSun(lat: latitudeOfSunAtCurrentTime, lon: subSolarLon)
        
        // If we're ready to show the orbit track, render it now
        if showOrbitNow {
            globe.addOrbitTrackAroundTheGlobe(lat: lat, lon: lon, headingFactor: headingFactor)
        }
        
        globe.addISSMarker(lat: lat, lon: lon)
        globe.addViewingCircle(lat: lat, lon: lon)
        globe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)     // Autorotate if enabled in Settings
        
    }
    
}
