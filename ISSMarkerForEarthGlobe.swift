//
//  ISSMarkerForEarthGlobe.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//


import Foundation
import SceneKit


// Encapsulates individual markers
class ISSMarkerForEarthGlobe {
    
    var latitude: Float
    var longitude: Float
    var image: String
    
    // The SceneKit node for this marker
    internal var node: SCNNode!
    
    init(using image: String, lat: Float, lon: Float, isInOrbit: Bool) {
        
        self.image = image
        latitude = lat
        longitude = lon
        let adjustedLon = longitude + 90                                                            // The textures are centered on 0,0, so adjust by 90 degrees
        
        let widthAndHeight = isInOrbit ? glowPointWidth : glowPointWidth * 2.25                     // Fudge the approximate diameter of the sighting circle
        
        self.node = SCNNode(geometry: SCNPlane(width: widthAndHeight, height: widthAndHeight) )
        self.node.geometry!.firstMaterial!.diffuse.contents = image
        self.node.geometry!.firstMaterial!.diffuse.intensity = 1.0                                  // Appearance in daylight areas
        self.node.geometry!.firstMaterial!.emission.contents = image
        self.node.geometry!.firstMaterial!.emission.intensity = 1.0                                 // Appearance in nighttime areas
        self.node.geometry!.firstMaterial!.isDoubleSided = true
        self.node.castsShadow = false
        
        let altitude = isInOrbit ? Globals.ISSAltitudeFactor : Globals.globeRadiusFactor * 0.949    // If not in orbit, then this is the sighting circle and place it flush with the surface
        let position = CoordinateCalculations.convertLatLonCoordinatesToXYZ(lat: lat, lon: adjustedLon, alt: altitude)
        self.node.position = position
        
        
        // Compute the normal pitch, yaw & roll (facing away from the globe)
        // Pitch (the x component) is the rotation about the node's x-axis (in radians)
        let pitch = -lat * Float(Globals.degreesToRadians)
        // Yaw (the y component) is the rotation about the node's y-axis (in radians)
        let yaw = lon * Float(Globals.degreesToRadians)
        // Roll (the z component) is the rotation about the node's z-axis (in radians)
        let roll : Float = 0.0
        
        self.node.eulerAngles = SCNVector3(x: pitch, y: yaw, z: roll )
        
    }
    
    /// Method to add a pulsing effect to the marker
    func addPulseAnimation() {
        
        let scaleMin: Float = 0.85
        let scaleMax: Float = 1.15
        let animation = CABasicAnimation(keyPath: "scale")
        animation.fromValue = SCNVector3(x: scaleMin, y: scaleMin, z: scaleMin)
        animation.toValue = SCNVector3(x: scaleMax, y: scaleMax, z: scaleMax)
        animation.duration = 0.25
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        node.addAnimation(animation, forKey: "throb")
        
    }
    
}
