//
//  ISSMarkerForEarthGlobe.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//


import SceneKit


/// Model for the markers to be added to the Earth model
class ISSMarkerForEarthGlobe {
    
    var image: String
    
    // The SceneKit node for this marker
    var node: SCNNode!
    
    init(using image: String, lat: Float, lon: Float, isInOrbit: Bool) {
        
        self.image = image
        let adjustedLon = lon + 90                                                                                      // Textures are centered on 0,0, so adjust by 90 degrees
        let widthAndHeight = isInOrbit ? EarthGlobe.markerWidth : EarthGlobe.markerWidth * 2.25                         // Fudge the approximate diameter of the sighting circle
        
        node = SCNNode(geometry: SCNPlane(width: widthAndHeight, height: widthAndHeight))
        node.geometry!.firstMaterial!.diffuse.contents   = image
        node.geometry!.firstMaterial!.diffuse.intensity  = 1.0                                                          // Appearance in daylight areas
        node.geometry!.firstMaterial!.emission.contents  = image
        node.geometry!.firstMaterial!.emission.intensity = 0.75                                                         // Appearance in nighttime areas (a bit less bright)
        node.geometry!.firstMaterial!.isDoubleSided      = true
        node.castsShadow                                 = false
        
        let altitude = isInOrbit ? Globals.ISSAltitudeFactor : Globals.globeRadiusFactor * 0.949                        // If not in orbit, then this is the sighting circle and place it flush with the surface
        let position = EarthGlobe.convertLatLonCoordinatesToXYZ(lat: lat, lon: adjustedLon, alt: altitude)              // Map lat and lon to xyz coodinates on globe
        self.node.position = position
        
        // Compute the normal pitch, yaw & roll, where pitch is the rotation about the node's x-axis in radians
        let pitch = -lat * Float(Globals.degreesToRadians)
       
        // Yaw is the rotation about the node's y-axis in radians
        let yaw = lon * Float(Globals.degreesToRadians)
       
        // Roll is the rotation about the node's z-axis in radians
        let roll: Float = 0.0
        
        node.eulerAngles = SCNVector3(x: pitch, y: yaw, z: roll )
        
    }
    
    
    /// Method to add a pulsing effect to the marker
    func addPulseAnimation() {
        
        let scaleMin: Float      = 0.80
        let scaleMax: Float      = 1.05
        let animation            = CABasicAnimation(keyPath: "scale")
        animation.fromValue      = SCNVector3(x: scaleMin, y: scaleMin, z: scaleMin)
        animation.toValue        = SCNVector3(x: scaleMax, y: scaleMax, z: scaleMax)
        animation.duration       = 0.25
        animation.autoreverses   = true
        animation.repeatCount    = Float.infinity
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        node.addAnimation(animation, forKey: nil)
        
    }
    
}
