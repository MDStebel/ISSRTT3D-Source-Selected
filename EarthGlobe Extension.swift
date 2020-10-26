//
//  EarthGlobe Extension.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//


import SceneKit


extension EarthGlobe {
    
    
    /// Adds the ISS position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSMarker(lat: Float, lon: Float) {
                
        let ISS = ISSMarkerForEarthGlobe(lat: lat, lon: lon)
        ISS.addPulseAnimation()
        self.addMarker(ISS)
                
    }
    
    
    /// Create an orbital track around the globe at the exact ISS orbital inclination and current ISS location, heading, and altitude
    /// - Parameters:
    ///   - lat: Latitude as a decimal value
    ///   - lon: Longitude as a decimal value
    ///   - heading: Indicates whether the ISS is heading generally north or south
    public func addOrbitTrackAroundTheGlobe(lat: Float, lon: Float, headingFactor: Float) {
        
        // Create a torus geometry with a small pipeRadius to be used as our orbital track around the globe
        let orbitTrack = SCNTorus()
        orbitTrack.firstMaterial?.diffuse.contents = UIColor(named: Theme.tint)
        orbitTrack.ringRadius = CGFloat(Globals.ISSOrbitAltitudeInScene)
        orbitTrack.pipeRadius = 0.008
        
        // Assign the torus as a node and add it as a child of globe
        let orbitTrackNode = SCNNode(geometry: orbitTrack)
        globe.addChildNode(orbitTrackNode)
        
        // Set the lat and lon corrections that are be needed to align orbital properly to the ISS and its heading
        let adjustedLat = lat + 180
        let adjustedLon = lon - 180
        let orbitalCorrectionForLon = adjustedLon * Globals.degreesToRadians                                    // lon & lat are used here as the angular displacement from the origin (lon - origin = lon - 0 = lon)
        let orbitalCorrectionForLat = adjustedLat * Globals.degreesToRadians
        let ISSOrbitInclinationInRadiansCorrected = Globals.ISSOrbitInclinationInRadians * headingFactor * 1.0 // Flip the orbital direction based on if it's heading generally north or south
        
        // Create 4x4 matrices for each rotation to be used below as rotation matrices and initialize each as the identity matrix
        var rotationMatrix1 = SCNMatrix4Identity
        var rotationMatrix2 = SCNMatrix4Identity
        var rotationMatrix3 = SCNMatrix4Identity
        
        // Create the rotations for the orbital inclination to align relative to the globe and the current ISS position
        rotationMatrix1 = SCNMatrix4RotateF(rotationMatrix1, ISSOrbitInclinationInRadiansCorrected , 0, 0, 1)   // Z rotation
        rotationMatrix2 = SCNMatrix4RotateF(rotationMatrix2, orbitalCorrectionForLon, 0, 1, 0)                  // y rotation
        rotationMatrix3 = SCNMatrix4RotateF(rotationMatrix3, orbitalCorrectionForLat, 1, 0, 0)                  // x rotation
        
        // Multiply the matrices together to make a composite matrix and use this as the transform matrix
        let firstProduct = SCNMatrix4Mult(rotationMatrix3, rotationMatrix2)                                     // Note! The order of the matrix operands is NOT cummulative in multiplication
        let compositeRotationMatrix = SCNMatrix4Mult(rotationMatrix1, firstProduct)                             // Note! The order of the matrix operands is NOT cummulative in multiplication
        orbitTrackNode.transform = compositeRotationMatrix                                                      // Apply the transform
        
    }
    
    
    /// Set up the Sun
    /// - Parameters:
    ///   - lat: Latitude in degrees
    ///   - lon: Longitude in degress
    public func setupTheSun(lat: Float, lon: Float) {

        let adjustedLon = lon + 90
        let adjustedLat = lat
        let distanceToTheSun = Float(10000)
        let position = CoordinateConversions.convertLatLonCoordinatesToXYZ(adjustedLat, adjustedLon, alt: distanceToTheSun)
        sun.position = position
        
        sun.light = SCNLight()
        sun.light!.type = .omni
        sun.light!.castsShadow = false
        
        globe.addChildNode(sun)

        sun.light!.temperature = 5600                       // Sun color temp at noon is 5600. White is 6500. Anything above 5000 is daylight.
        sun.light!.intensity = 2500                         // The default is 1000
        
    }
    
    
    /// Start/stop autospinning the globe
    /// - Parameter run: Start if true. Stop if false.
    public func autoSpinGlobeRun(run: Bool) {
        
        if run && !globe.hasActions {
            let spinRotation = SCNAction.rotate(by: 2 * .pi, around: SCNVector3(0, 1, 0), duration: kGlobeDefaultRotationSpeedSeconds)
            let spinAction = SCNAction.repeatForever(spinRotation)
            globe.runAction(spinAction)
        } else if !run && globe.hasActions {
            globe.removeAllActions()
        }
        
    }
    

    /// Add a marker to the globe and make it pulse
    public func addMarker(_ marker: ISSMarkerForEarthGlobe) {
        
        globe.addChildNode(marker.node)
        marker.addPulseAnimation()
        
    }
    
    
    /// Remove the last node in the childNodes array
    public func removeLastNode() {
        
        if let nodeToRemove = globe.childNodes.last {
            nodeToRemove.removeFromParentNode()
        }
        
    }
    
    
    public func goToPointOnGlobe(node: SCNNode, lat: Float, lon: Float) {
        
        let position = CoordinateConversions.convertLatLonCoordinatesToXYZ(lat, lon, alt: Globals.orbitalAltitudeFactor)
        
        // Determine how much we've moved
        let currentPosition = node.position
        let delta = CGSize(width: Double((currentPosition.x - position.x)) / 225.0, height: Double((currentPosition.y - position.y)) / 225.0 )
        
        //  DeltaX = amount of rotation to apply (about the world axis)
        //  DelyaY = amount of tilt to apply (to the axis itself)
        if delta.width != 0.0 || delta.height != 0.0 {

            let rotationAboutAxis = Float(delta.width) * 2 * .pi
            let tiltOfAxisItself = Float(delta.height) * 2 * .pi
            
            // First, apply the rotation
            let rotate = SCNMatrix4RotateF(userRotation.worldTransform, -rotationAboutAxis, 0.0, 1.0, 0.0)
            node.setWorldTransform(rotate)
            
            // Now, apply the tilt
            let tilt = SCNMatrix4RotateF(userTilt.worldTransform, -tiltOfAxisItself, 1.0, 0.0, 0.0)
            node.setWorldTransform(tilt)
            
        }
        
    }

    
}
