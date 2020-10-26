//
//  ISSMarkerForEarthGlobe.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.

//  Portions Copyright © 2017 David Mojdehi
//


import Foundation
import SceneKit


// Encapsulate individual glow points
// Extend this to get different glow effects
class ISSMarkerForEarthGlobe {
    
    
    var latitude: Float
    var longitude: Float
    
    let image = "iss_4_white"

    // The SceneKit node for this point
    internal var node: SCNNode!
    

    init(lat: Float, lon: Float) {
        
        latitude = lat
        longitude = lon
        let adjustedLon = longitude + 90       // The textures are centered on 0,0, so adjust by 90 degrees
        
        self.node = SCNNode(geometry: SCNPlane(width: kGlowPointWidth, height: kGlowPointWidth) )
        self.node.geometry!.firstMaterial!.diffuse.contents = image
        // Appear in daylight areas
        self.node.geometry!.firstMaterial!.diffuse.intensity = 1.0
        self.node.geometry!.firstMaterial!.emission.contents = image
        // Appear in dark areas
        self.node.geometry!.firstMaterial!.emission.intensity = 1.0
        self.node.castsShadow = false

        
        let position = CoordinateConversions.convertLatLonCoordinatesToXYZ(lat, adjustedLon, alt: Globals.ISSAltitudeFactor)
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
    
    
    func addPulseAnimation() {
        
        let scaleMin: Float = 0.80
        let scaleMax: Float = 1.20
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
