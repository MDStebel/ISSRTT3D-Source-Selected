//
//  ISSMarkerForEarthGlobe.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//


import SceneKit


/// Model for markers to be added to the Earth model
final class EarthGlobMarkers {
    
    var image: String
    var widthAndHeight: CGFloat
    var altitude: Float
    var node: SCNNode!                                                                                 // The SceneKit node for this marker
    
    /// Initialize a marker to be added to the Earth globe
    /// - Parameters:
    ///   - satellite: Type of satellite as a SatelliteID
    ///   - image: Image name to use as marker as a String
    ///   - lat: Latitude of the marker's position on Earth as a Float
    ///   - lon: Longitude of the marker's position on Earth as a Float
    ///   - isInOrbit: Flag that indicates if the marker is above Earth or on its surface as a Bool
    init(for satellite: SatelliteID, using image: String, lat: Float, lon: Float, isInOrbit: Bool) {
        
        self.image                                       = image
        let adjustedLon                                  = lon + Globals.ninetyDegrees                 // Textures are centered on 0,0, so adjust by 90 degrees
        
        // Which object does our marker represent? .none implies sighting circle (i.e., footprint)
        switch satellite {
        case .ISS :
            widthAndHeight                               = Globals.ISSMarkerWidth
        case .TSS :
            widthAndHeight                               = Globals.TSSMarkerWidth
        case .none :
            widthAndHeight                               = Globals.ISSMarkerWidth * 2.25               // Factor to approximate the ground diameter of the sighting circle
        }
        
        // Initialize and configure the marker node
        node                                             = SCNNode(geometry: SCNPlane(width: widthAndHeight, height: widthAndHeight))
        node.geometry!.firstMaterial!.diffuse.contents   = image
        node.geometry!.firstMaterial!.diffuse.intensity  = 1.0                                         // Appearance in daylight areas
        node.geometry!.firstMaterial!.emission.contents  = image
        node.geometry!.firstMaterial!.emission.intensity = 0.75                                        // Appearance in nighttime areas (a bit less bright)
        node.geometry!.firstMaterial!.isDoubleSided      = true
        node.castsShadow                                 = false
        
        switch satellite {
        case .ISS :
            altitude                                     = Globals.ISSAltitudeFactor
        case .TSS :
            altitude                                     = Globals.TSSAltitudeFactor
        case .none :
            altitude                                     = Globals.globeRadiusFactor * Globals.globeRadiusMultiplier                       // This is the sighting circle, so place it flush with the surface
        }
        
        // Map Earth coordinates (lat and lon) to xyz coodinates on globe
        let position                                     = EarthGlobe.transformLatLonCoordinatesToXYZ(lat: lat, lon: adjustedLon, alt: altitude)
        self.node.position                               = position
        
        // Compute the normal pitch, roll and yaw
        let pitch                                        = -lat * Float(Globals.degreesToRadians)                                    // Pitch is the rotation about the node's x-axis in radians
        let roll: Float                                  = Globals.zero                                                              // Roll is the rotation about the node's z-axis in radians
        let yaw                                          = lon * Float(Globals.degreesToRadians)                                     // Yaw is the rotation about the node's y-axis in radians
        
        // Set the marker's orientation using pitch, roll, and yaw
        node.eulerAngles                                 = SCNVector3(x: pitch, y: yaw, z: roll )
        
    }
    
    
    /// Method to add a pulsing effect to the marker node
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
