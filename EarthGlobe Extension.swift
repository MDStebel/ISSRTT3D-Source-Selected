//
//  EarthGlobe Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// Handles the objects we're adding to the globe as well as coordinate transforms
extension EarthGlobe {
    
    //    #if !os(watchOS)
    
    /// Adds the ISS position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSMarker(lat: Float, lon: Float) {
        
        let ISS = EarthGlobeMarkers(for: .iss, using: Globals.ISSIconFor3DGlobeView, lat: lat, lon: lon, isInOrbit: true)
        
#if !os(watchOS)
        let pulse = true
#else
        let pulse = false
#endif
        self.addMarker(ISS, shouldPulse: pulse)
    }
    
    
    /// Adds the TSS position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addTSSMarker(lat: Float, lon: Float) {
        
        let TSS = EarthGlobeMarkers(for: .tss, using: Globals.TSSIconFor3DGlobeView, lat: lat, lon: lon, isInOrbit: true)
        
#if !os(watchOS)
        let pulse = true
#else
        let pulse = false
#endif
        self.addMarker(TSS, shouldPulse: pulse)
    }
    
    
    /// Adds the satellite's viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = EarthGlobeMarkers(for: .none, using: Globals.ISSViewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
        self.addMarker(viewingCircle, shouldPulse: false)
    }
    
    
    /// Adds the satellite's viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addTSSViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = EarthGlobeMarkers(for: .none, using: Globals.TSSViewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
        self.addMarker(viewingCircle, shouldPulse: false)
    }
    
    
    /// Create an orbital track around the globe at the station's precise orbital inclination and location, heading, and altitude
    ///
    /// This is my empirical algorithm that keeps the orientation of the track at the right angle even though the position of the globe in the scene uses different coordinate system.
    /// - Parameters:
    ///   - station: Type of satellite as a SatelliteID type
    ///   - lat: Latitude as a decimal value as a Float
    ///   - lon: Longitude as a decimal value as a Float
    ///   - headingFactor: Indicates whether the statellite is heading generally north or south as a Float
    public func addOrbitTrackAroundTheGlobe(for station: StationsAndSatellites, lat: Float, lon: Float, headingFactor: Float) {
        
        // Create a hi-res torus geometry with a small pipeRadius to be used as our orbital track around the globe
        let orbitTrack                                 = SCNTorus()
        
        var orbitInclination: Float
        var multiplier: Float
        
        switch station {
        case .iss :
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dRedCGColor
            orbitTrack.ringRadius                      = CGFloat(Globals.ISSOrbitAltitudeInScene)
            orbitInclination                           = Globals.ISSOrbitInclinationInRadians
            multiplier                                 = 2.5
        case .tss :
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dGoldCGColor
            orbitTrack.ringRadius                      = CGFloat(Globals.TSSOrbitAltitudeInScene)
            orbitInclination                           = Globals.TSSOrbitInclinationInRadians
            multiplier                                 = 2.8
        case .none :
            return
        }
        
        orbitTrack.pipeRadius                          = pipeRadius
        orbitTrack.ringSegmentCount                    = ringSegmentCount
        orbitTrack.pipeSegmentCount                    = pipeSegmentCount
        
        // Assign the torus as a node and add it as a child of globe
        let orbitTrackNode                             = SCNNode(geometry: orbitTrack)
        globe.addChildNode(orbitTrackNode)
        
        // Set the lat, lon, and inclination corrections that are be needed to align orbital properly to the satellite and its heading
        var orbitalCorrectionForInclination: Float
        
        let adjustedLat                                = lat + Float(Globals.oneEightyDegrees)
        let adjustedLon                                = lon - Float(Globals.oneEightyDegrees)
        let orbitalCorrectionForLon                    = adjustedLon * Float(Globals.degreesToRadians)  // lon & lat used as angular displacement from the origin (lon-origin=lon-0=lon)
        let orbitalCorrectionForLat                    = adjustedLat * Float(Globals.degreesToRadians)
        let absLat                                     = abs(lat)
        let exponent                                   = Float.pi / multiplier + absLat * Float(Globals.degreesToRadians) / orbitInclination  // Adjustment to the inclination (z-axis) as we approach max latitudes
        
        switch station {
        case .iss :
            switch absLat {   // Apply a power function to the adjustment (exponent) based on the latitude
            case _ where absLat <= 25.0 :
                orbitalCorrectionForInclination        = exponent
            case _ where absLat <= 35.0 :
                orbitalCorrectionForInclination        = pow(exponent, 1.5)
            case _ where absLat <= 45.0 :
                orbitalCorrectionForInclination        = pow(exponent, 2.0)
            case _ where absLat <= 49.0 :
                orbitalCorrectionForInclination        = pow(exponent, 2.5)
            case _ where absLat <= 51.0 :
                orbitalCorrectionForInclination        = pow(exponent, 3.0)
            default :
                orbitalCorrectionForInclination        = pow(exponent, 4.0)
            }
        case .tss  :
            switch absLat {   // Apply a power function to the adjustment (exponent) based on the latitude
            case _ where absLat <= 20.0 :
                orbitalCorrectionForInclination        = exponent
            case _ where absLat <= 27.0 :
                orbitalCorrectionForInclination        = pow(exponent, 1.0)
            case _ where absLat <= 35.5 :
                orbitalCorrectionForInclination        = pow(exponent, 1.5)
            case _ where absLat <= 39.0 :
                orbitalCorrectionForInclination        = pow(exponent, 2.0)
            case _ where absLat <= 41.0 :
                orbitalCorrectionForInclination        = pow(exponent, 2.5)
            default :
                orbitalCorrectionForInclination        = pow(exponent, 3.0)
            }
        case .none :
            return
        }
        
        let orbitInclinationInRadiansCorrected         = pow(orbitInclination, orbitalCorrectionForInclination) * headingFactor
        
        // Create 4x4 transform matrices for each rotation and initialize them as the identity matrix
        var rotationMatrix1                            = SCNMatrix4Identity
        var rotationMatrix2                            = SCNMatrix4Identity
        var rotationMatrix3                            = SCNMatrix4Identity
        
        // Create the rotation matrices for the orbital inclination to align relative to the globe and the current satellite position
        rotationMatrix1                                = SCNMatrix4RotateF(rotationMatrix1, orbitInclinationInRadiansCorrected , 0, 0, 1)      // z rotation
        rotationMatrix2                                = SCNMatrix4RotateF(rotationMatrix2, orbitalCorrectionForLon, 0, 1, 0)                  // y rotation
        rotationMatrix3                                = SCNMatrix4RotateF(rotationMatrix3, orbitalCorrectionForLat, 1, 0, 0)                  // x rotation
        
        // Multiply the matrices together to make a composite matrix and use this as the transform matrix
        let firstProduct                               = SCNMatrix4Mult(rotationMatrix3, rotationMatrix2)                                      // Note! The order of the operands is NOT cummulative in matrix multiplication
        let compositeRotationMatrix                    = SCNMatrix4Mult(rotationMatrix1, firstProduct)                                         // Note! The order of the operands is NOT cummulative in matrix multiplication
        
        // Apply the transform
        orbitTrackNode.transform                       = compositeRotationMatrix
    }
    
    
#if !os(watchOS)
    
    /// Start/stop autospinning the globe
    /// - Parameter run: Start if true. Stop if false.
    public func autoSpinGlobeRun(run: Bool) {
        
        if run && !globe.hasActions {
            let spinRotation = SCNAction.rotate(by: CGFloat(Globals.twoPi), around: SCNVector3(0, 1, 0), duration: globeDefaultRotationSpeedInSeconds)
            let spinAction   = SCNAction.repeatForever(spinRotation)
            globe.runAction(spinAction)
        } else if !run && globe.hasActions {
            globe.removeAllActions()
        }
    }
    
#endif
    
    
    /// Add a marker to the globe and make it pulse
    public func addMarker(_ marker: EarthGlobeMarkers, shouldPulse: Bool) {
        
        globe.addChildNode(marker.node)
#if !os(watchOS)
        if Globals.pulseISSMarkerForGlobe && shouldPulse {
            marker.addPulseAnimation()
        }
#endif
    }
    
    
    /// Remove the last child node in the nodes array
    public func removeLastNode() {
        
        if let nodeToRemove = globe.childNodes.last {
            nodeToRemove.removeFromParentNode()
        }
    }
    
    
    /// Get the number of child nodes in the nodes array
    /// - Returns: The number of child nodes in the scene heirarchy as an Int
    public func getNumberOfChildNodes() -> Int {
        
        return globe.childNodes.count
    }
    
    
    /// Set up the Sun
    /// - Parameters:
    ///   - lat: Subsolor point latitude in degrees
    ///   - lon: Subsolor point longitude in degrees
    public func setUpTheSun(lat: Float, lon: Float) {
        
        let adjustedLon        = lon + Globals.ninetyDegrees
        let adjustedLat        = lat
        let distanceToTheSun   = sunDistance
        let position           = EarthGlobe.transformLatLonCoordinatesToXYZ(lat: adjustedLat, lon: adjustedLon, alt: distanceToTheSun)
        sun.position           = position
        
        sun.light              = SCNLight()
        sun.light!.type        = .omni
        sun.light!.castsShadow = false
        sun.light!.temperature = sunlightTemp           // The Sun's color temp at noon in Kelvin
        sun.light!.intensity   = sunlightIntensity      // Sunlight intensity in lumens
        
        globe.addChildNode(sun)
    }
    
    
    /// Convert map coordinates from lat, lon, altitude to SceneKit x, y, z coordinates
    /// - Parameters:
    ///   - lat: Latitude as a decimal Float
    ///   - lon: Longitude as a decimal Float
    ///   - alt: altitude as a decimal Float
    /// - Returns: Position as a SCNVector3
    static func transformLatLonCoordinatesToXYZ(lat: Float, lon: Float, alt: Float) -> SCNVector3 {
        
        let cosLat    = cosf(lat * Float(Globals.degreesToRadians))
        let sinLat    = sinf(lat * Float(Globals.degreesToRadians))
        let cosLon    = cosf(lon * Float(Globals.degreesToRadians))
        let sinLon    = sinf(lon * Float(Globals.degreesToRadians))
        let x         = alt * cosLat * cosLon
        let y         = alt * cosLat * sinLon
        let z         = alt * sinLat
        
        // Map to position on a SceneKit sphere
        let sceneKitX = -x
        let sceneKitY = z
        let sceneKitZ = y
        
        let position  = SCNVector3(x: sceneKitX, y: sceneKitY, z: sceneKitZ )
        
        return position
    }
    
    
    /// Rotate a 4-vector
    /// - Parameters:
    ///   - src: 4-matrix
    ///   - angle: Angle
    ///   - x: X
    ///   - y: Y
    ///   - z: Z
    /// - Returns: A new 4-matrix
    func SCNMatrix4RotateF(_ src: SCNMatrix4, _ angle : Float, _ x : Float, _ y : Float, _ z : Float) -> SCNMatrix4 {
        
        return SCNMatrix4Rotate(src, angle, x, y, z)
    }
}
