//
//  EarthGlobeProtocol.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/26/2021.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
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
            scene.backgroundColor     = UIColor(named: Theme.popupBgd)?.withAlphaComponent(0.60)        // Tinted for map view overlay mode
            scene.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            scene.backgroundColor     = UIColor(red: 0, green: 0, blue: 0, alpha: 0)                    // Transparent background for full-screen mode
        }
        
        scene.layer.masksToBounds     = true
        
    }
    
    
    /// Add the ISS position marker, orbital track, and current Sun position to the globe
    /// - Parameters:
    ///   - globe: The globe instance to use
    ///   - latitude: The latitude
    ///   - longitude: The longitude
    ///   - lastLat: The last latitude saved as a mutating parameter
    func updateEarthGlobeScene(in globe: EarthGlobe, latitude: String, longitude: String, lastLat: inout Float ) {
        
        var headingFactor: Float = 1
        var showOrbitNow = false
        
        globe.removeLastNode()                      // Remove the last marker node, so we don't smear them together
        globe.removeLastNode()                      // Remove the last orbit track, so we don't smear them together as they precess
        globe.removeLastNode()                      // Remove the viewing circle
        
        let lat = Float(latitude) ?? 0.0
        let lon = Float(longitude) ?? 0.0
        
        // Determine if we have a prior latitude saved, as we don't know which way the orbit is oriented unless we do
        if lastLat != 0 {
            showOrbitNow = true
            headingFactor = lat - lastLat < 0 ? -1 : 1
        }
        lastLat = lat                               // Saves last latitude to use in calculating north or south heading vector after the second track update
        
        // Get the current coordinates of the Sun at the subsolar point (i.e., where the Sun is at zenith)
        let coordinates = AstroCalculations.getSubSolarCoordinates()
        let subSolarLat = coordinates.latitude      // Get the latitude of the subsolar point at the current time
        let subSolarLon = coordinates.longitude     // Get the longitude of the subsolar point at the current time
        
        // Now, set up the Sun in our model at the subsolar point
        globe.setUpTheSun(lat: subSolarLat, lon: subSolarLon)
        
        // If we're ready to show the orbit track, render it now
        if showOrbitNow {
            globe.addOrbitTrackAroundTheGlobe(lat: lat, lon: lon, headingFactor: headingFactor)
        }
        
        // Update the markers now
        globe.addISSMarker(lat: lat, lon: lon)
        globe.addViewingCircle(lat: lat, lon: lon)
        
        // Autorotate the globe if autorotation is enabled in Settings
        globe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)
        
    }
    
}
