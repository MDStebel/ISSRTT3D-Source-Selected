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
    
    var ISSLastLat: Float { get set }
    var TSSLastLat: Float { get set }
    
    func setUpEarthGlobeScene(for globe: EarthGlobe, in scene: SCNView, hasTintedBackground: Bool)
    func updateEarthGlobeScene(in globe: EarthGlobe, ISSLatitude: String, ISSLongitude: String, TSSLatitude: String?, TSSLongitude: String?, ISSLastLat: inout Float, TSSLastLat: inout Float)
    
}


// MARK: - Default implementations


extension EarthGlobeProtocol {
    
    /// Create the context globe scene
    /// - Parameters:
    ///   - globe: Which globe instance to set up in the scene
    ///   - scene: The scene to use
    ///   - hasTintedBackground: Bool that is True if we're settin up the overlay globe on the tracking screen, or False if we're setting up the fullscreen globe
    func setUpEarthGlobeScene(for globe: EarthGlobe, in scene: SCNView, hasTintedBackground: Bool) {
        
        globe.setupInSceneView(scene, customPinchGestureIsEnabled: false)
        
        if hasTintedBackground {
            scene.backgroundColor     = UIColor(named: Theme.popupBgd)?.withAlphaComponent(0.60)        // Tinted for map view overlay mode
            scene.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            scene.layer.cornerRadius  = 10
            scene.layer.masksToBounds = true
        } else {
            scene.backgroundColor     = UIColor(red: 0, green: 0, blue: 0, alpha: 0)                    // Transparent background for full-screen mode
        }

    }
    
    
    /// Add the statellite/station position marker(s), orbital track(s), footprint(s), and current Sun position to the globe.
    /// Since we are not always plotting the TSS, the coordinates parameters are optional
    /// - Parameters:
    ///   - globe: The globe instance to use
    ///   - ISSLatitude: ISS latitude as a string
    ///   - ISSLongitude: ISS longitude as a string
    ///   - TSSLatitude: TSS latitude as an optional string
    ///   - TSSLongitude: TSS longitude as an optional string
    ///   - ISSLastLat: The last ISS latitude saved as a mutating parameter
    ///   - TSSLastLat: The last TSS latitude saved as a mutating parameter
    func updateEarthGlobeScene(in globe: EarthGlobe, ISSLatitude: String, ISSLongitude: String, TSSLatitude: String?, TSSLongitude: String?, ISSLastLat: inout Float, TSSLastLat: inout Float ) {
        
        var ISSHeadingFactor: Float = 1
        var TSSHeadingFactor: Float = 1
        var showISSOrbitNow         = false
        var showTSSOrbitNow         = false
        var addTSS                  = false
        var iLat, iLon: Float
        var tLat: Float?            = nil
        var tLon: Float?            = nil
        
        // Process coordinates
        iLat = Float(ISSLatitude) ?? 0.0
        iLon = Float(ISSLongitude) ?? 0.0
        
        if TSSLatitude != nil && TSSLongitude != nil {  // Make sure we have valid TSS coordinates
            tLat = Float(TSSLatitude!) ?? 0.0
            tLon = Float(TSSLongitude!) ?? 0.0
            if (tLat! + tLon!) != 0.0 {
                addTSS = true
            } else {
                addTSS = false
            }
        } else {
            addTSS = false
        }
        
        // We need to remove all each of the nodes we've added before adding them again at new coordinates
        var numberOfChildNodes  = globe.getNumberOfChildNodes()
        while numberOfChildNodes > 0 {
            globe.removeLastNode()
            numberOfChildNodes -= 1
        }
        
        // Determine if we have a prior ISS latitude saved, as we don't know which way the orbit is oriented unless we do
        if ISSLastLat != 0 {
            showISSOrbitNow     = true
            ISSHeadingFactor = iLat - ISSLastLat < 0 ? -1 : 1
        }
        ISSLastLat = iLat                                       // Saves last latitude to use in calculating north or south heading vector after the second track update
        
        // Determine if we have a prior TSS latitude saved, as we don't know which way the orbit is oriented unless we do
        if TSSLastLat != 0 {
            showTSSOrbitNow     = true
            TSSHeadingFactor = tLat! - TSSLastLat < 0 ? -1 : 1
        }
        TSSLastLat = tLat ?? 0
        
        // Get the current coordinates of the Sun at the subsolar point (i.e., where the Sun is at zenith)
        let coordinates = AstroCalculations.getSubSolarCoordinates()
        let subSolarLat = coordinates.latitude                  // Get the latitude of the subsolar point at the current time
        let subSolarLon = coordinates.longitude                 // Get the longitude of the subsolar point at the current time
        globe.setUpTheSun(lat: subSolarLat, lon: subSolarLon)   // Now, set up the Sun in our model at the subsolar point
        
        // If we're ready to show the orbital tracks, render them now
        if showISSOrbitNow {
            globe.addOrbitTrackAroundTheGlobe(for: .ISS, lat: iLat, lon: iLon, headingFactor: ISSHeadingFactor)
        }
        if addTSS && showTSSOrbitNow {
            globe.addOrbitTrackAroundTheGlobe(for: .TSS, lat: tLat!, lon: tLon!, headingFactor: TSSHeadingFactor)
        }
        
        // Add the ISS
        globe.addISSMarker(lat: iLat, lon: iLon)
        
        // Add footprint
        globe.addISSViewingCircle(lat: iLat, lon: iLon)
        
        // Add the TSS if valid
        if addTSS {
            globe.addTSSMarker(lat: tLat!, lon: tLon!)
            globe.addTSSViewingCircle(lat: tLat!, lon: tLon!)
        }
        
        // Autorotate the globe if autorotation is enabled in Settings
        globe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)
        
    }
}
