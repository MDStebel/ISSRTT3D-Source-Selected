//
//  EarthGlobe Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// Handles the objects we're adding to the globe
extension EarthGlobe {
    
    /// Adds the ISS position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSMarker(lat: Float, lon: Float) {
        
        let ISS = ISSMarkerForEarthGlobe(using: Globals.ISSIcon, lat: lat, lon: lon, isInOrbit: true)
        self.addMarker(ISS, shouldPulse: true)
        
    }
    
    
    /// Adds the ISS viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = ISSMarkerForEarthGlobe(using: Globals.viewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
        self.addMarker(viewingCircle, shouldPulse: false)
        
    }
    
    
    /// Create an orbital track around the globe at the exact ISS orbital inclination and current ISS location, heading, and altitude
    /// - Parameters:
    ///   - lat: Latitude as a decimal value
    ///   - lon: Longitude as a decimal value
    ///   - heading: Indicates whether the ISS is heading generally north or south
    public func addOrbitTrackAroundTheGlobe(lat: Float, lon: Float, headingFactor: Float) {
        
        // Create a hi-res torus geometry with a small pipeRadius to be used as our orbital track around the globe
        let orbitTrack                             = SCNTorus()
        orbitTrack.firstMaterial?.diffuse.contents = UIColor(named: Theme.tint)
        orbitTrack.ringRadius                      = CGFloat(Globals.ISSOrbitAltitudeInScene)
        orbitTrack.pipeRadius                      = pipeRadius
        orbitTrack.ringSegmentCount                = ringSegmentCount
        orbitTrack.pipeSegmentCount                = pipeSegmentCount
        
        // Assign the torus as a node and add it as a child of globe
        let orbitTrackNode                         = SCNNode(geometry: orbitTrack)
        globe.addChildNode(orbitTrackNode)
        
        // Set the lat, lon, and inclination corrections that are be needed to align orbital properly to the ISS and its heading
        var orbitalCorrectionForInclination: Float
        
        let adjustedLat                            = lat + Float(Globals.oneEightyDegrees)
        let adjustedLon                            = lon - Float(Globals.oneEightyDegrees)
        let orbitalCorrectionForLon                = adjustedLon * Float(Globals.degreesToRadians)  // lon & lat used as angular displacement from the origin (lon-origin=lon-0=lon)
        let orbitalCorrectionForLat                = adjustedLat * Float(Globals.degreesToRadians)
        let absLat                                 = abs(lat)
        let exponent                               = Float.pi / 2.5 + absLat * Float(Globals.degreesToRadians) / Globals.ISSOrbitInclinationInRadians  // Adjustment to the inclination (z-axis) as we approach max latitudes.
        
        switch absLat {  // Apply a power function to the adjustment (an exponent) based on the latitude.
        case _ where absLat <= 25.0 :
            orbitalCorrectionForInclination = exponent
        case _ where absLat <= 35.0 :
            orbitalCorrectionForInclination = pow(exponent, 1.5)
        case _ where absLat <= 45.0 :
            orbitalCorrectionForInclination = pow(exponent, 2.0)
        case _ where absLat <= 49.0 :
            orbitalCorrectionForInclination = pow(exponent, 2.5)
        case _ where absLat <= 51.0 :
            orbitalCorrectionForInclination = pow(exponent, 3.0)
        default :
            orbitalCorrectionForInclination = pow(exponent, 4.0)
        }
        let ISSOrbitInclinationInRadiansCorrected = pow(Globals.ISSOrbitInclinationInRadians, orbitalCorrectionForInclination) * headingFactor
        
        // Create 4x4 transform matrices for each rotation and initialize them as the identity matrix
        var rotationMatrix1         = SCNMatrix4Identity
        var rotationMatrix2         = SCNMatrix4Identity
        var rotationMatrix3         = SCNMatrix4Identity
        
        // Create the rotation matrices for the orbital inclination to align relative to the globe and the current ISS position
        rotationMatrix1             = SCNMatrix4RotateF(rotationMatrix1, ISSOrbitInclinationInRadiansCorrected , 0, 0, 1)   // z rotation
        rotationMatrix2             = SCNMatrix4RotateF(rotationMatrix2, orbitalCorrectionForLon, 0, 1, 0)                  // y rotation
        rotationMatrix3             = SCNMatrix4RotateF(rotationMatrix3, orbitalCorrectionForLat, 1, 0, 0)                  // x rotation
        
        // Multiply the matrices together to make a composite matrix and use this as the transform matrix
        let firstProduct            = SCNMatrix4Mult(rotationMatrix3, rotationMatrix2)                          // Note! The order of the matrix operands is NOT cummulative in multiplication
        let compositeRotationMatrix = SCNMatrix4Mult(rotationMatrix1, firstProduct)                             // Note! The order of the matrix operands is NOT cummulative in multiplication
        
        // Apply the transform
        orbitTrackNode.transform    = compositeRotationMatrix
        
    }
    
    
    /// Set up the Sun
    /// - Parameters:
    ///   - lat: Subsolor point latitude in degrees
    ///   - lon: Subsolor point longitude in degrees
    public func setUpTheSun(lat: Float, lon: Float) {

        let adjustedLon        = lon + Globals.ninetyDegrees
        let adjustedLat        = lat
        let distanceToTheSun   = sunDistance
        let position           = EarthGlobe.convertLatLonCoordinatesToXYZ(lat: adjustedLat, lon: adjustedLon, alt: distanceToTheSun)
        sun.position           = position
        
        sun.light              = SCNLight()
        sun.light!.type        = .omni
        sun.light!.castsShadow = false
        sun.light!.temperature = sunlightTemp           // The Sun's color temp at noon in Kelvin
        sun.light!.intensity   = sunlightIntensity      // Sunlight intensity in lumens
        
        globe.addChildNode(sun)

    }
    
    
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
    

    /// Add a marker to the globe and make it pulse
    public func addMarker(_ marker: ISSMarkerForEarthGlobe, shouldPulse: Bool) {
        
        globe.addChildNode(marker.node)
        if Globals.pulseISSMarkerForGlobe && shouldPulse {
            marker.addPulseAnimation()
        }
        
    }
    
    
    /// Remove the last node in the childNodes array
    public func removeLastNode() {
        
        if let nodeToRemove = globe.childNodes.last {
            nodeToRemove.removeFromParentNode()
        }
        
    }
    
    
    /// Convert map coordinates from lat, lon, altitude to SceneKit x, y, z coordinates
    /// - Parameters:
    ///   - lat: Latitude as a decimal
    ///   - lon: Longitude as a decimal
    ///   - alt: altitude as a decimal
    /// - Returns: Position as a SCNVector3
    static func convertLatLonCoordinatesToXYZ(lat: Float, lon: Float, alt: Float) -> SCNVector3 {
        
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
    
    
    public func goToPointOnGlobe(node: SCNNode, lat: Float, lon: Float) {
        
        let position = EarthGlobe.convertLatLonCoordinatesToXYZ(lat: lat, lon: lon, alt: Globals.orbitalAltitudeFactor)
        
        // Determine how much we've moved
        let currentPosition       = node.position
        let delta                 = CGSize(width: Double((currentPosition.x - position.x)) / 225.0, height: Double((currentPosition.y - position.y)) / 225.0 )
        
        if delta.width != 0.0 || delta.height != 0.0 {

            let rotationAboutAxis = Float(delta.width) * Float(Globals.twoPi)
            let tiltOfAxisItself  = Float(delta.height) * Float(Globals.twoPi)
            
            // First, apply the rotation
            let rotate            = SCNMatrix4RotateF(userRotation.worldTransform, -rotationAboutAxis, 0.0, 1.0, 0.0)
            node.setWorldTransform(rotate)
            
            // Now, apply the tilt
            let tilt              = SCNMatrix4RotateF(userTilt.worldTransform, -tiltOfAxisItself, 1.0, 0.0, 0.0)
            node.setWorldTransform(tilt)
            
        }
        
    }
    
    
    /// Move camera to a given latitude and longitude
    public func moveCameraToPointOnGlobe(lat: Float, lon: Float) {
        
        let newPosition     = EarthGlobe.convertLatLonCoordinatesToXYZ(lat: lat, lon: lon, alt: Globals.ISSOrbitAltitudeInScene)
        let x               = newPosition.x
        let y               = newPosition.y
        cameraNode.position = SCNVector3(x: x, y: y, z: globeRadiusFactor + cameraAltitude)
        
    }
    
    
    func SCNMatrix4RotateF(_ src: SCNMatrix4, _ angle : Float, _ x : Float, _ y : Float, _ z : Float) -> SCNMatrix4 {
        
        return SCNMatrix4Rotate(src, angle, x, y, z)
        
    }
    
}
