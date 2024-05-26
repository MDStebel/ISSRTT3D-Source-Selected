//
//  EarthGlobe Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020-2024 ISS Real-Time Tracker. All rights reserved.
//

import SceneKit
import UIKit

/// Handles the objects we're adding to the globe as well as coordinate and orbital transforms
extension EarthGlobe {
    
    /// This method adds the ISS position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSMarker(lat: Float, lon: Float) {
        
        let ISS = EarthGlobeMarkers(for: .iss, using: Globals.issIconFor3DGlobeView, lat: lat, lon: lon, isInOrbit: true)
        
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
        
        let TSS = EarthGlobeMarkers(for: .tss, using: Globals.tssIconFor3DGlobeView, lat: lat, lon: lon, isInOrbit: true)
        
#if !os(watchOS)
        let pulse = true
#else
        let pulse = false
#endif
        self.addMarker(TSS, shouldPulse: pulse)
        
    }
    
    /// Adds the Hubble position marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addHubbleMarker(lat: Float, lon: Float) {
        
        let hubble = EarthGlobeMarkers(for: .hst, using: Globals.hubbleIconFor3DGlobeView, lat: lat, lon: lon, isInOrbit: true)
        
#if !os(watchOS)
        let pulse = true
#else
        let pulse = false
#endif
        self.addMarker(hubble, shouldPulse: pulse)
        
    }
    
    /// Adds the satellite's viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addISSViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = EarthGlobeMarkers(for: .iss, using: Globals.issViewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
        self.addMarker(viewingCircle, shouldPulse: false)
        
    }
    
    /// Adds the satellite's viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addTSSViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = EarthGlobeMarkers(for: .tss, using: Globals.tssViewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
        self.addMarker(viewingCircle, shouldPulse: false)
        
    }
    
    /// Adds the satellite's viewing circle marker at the precise latitude and longitude to our globe scene
    /// - Parameters:
    ///   - lat: The current latitude as a decimal value
    ///   - lon: The current longitude as a decimal value
    public func addHubbleViewingCircle(lat: Float, lon: Float) {
        
        let viewingCircle = EarthGlobeMarkers(for: .hst, using: Globals.hubbleViewingCircleGraphic, lat: lat, lon: lon, isInOrbit: false)
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
        let orbitTrack = createOrbitTrack(for: station)
        guard let orbitTrackNode = orbitTrack else { return }
        
        globe.addChildNode(orbitTrackNode)
        
        let adjustedCoordinates = adjustCoordinates(lat: lat, lon: lon)
        let orbitalCorrectionForLon = adjustedCoordinates.lon * Float(Globals.degreesToRadians)
        let orbitalCorrectionForLat = adjustedCoordinates.lat * Float(Globals.degreesToRadians)
        let absLat = abs(lat)
        
        let orbitInclination = getOrbitInclination(for: station)
        let multiplier = getMultiplier(for: station)
        let exponent = calculateExponent(absLat: absLat, orbitInclination: orbitInclination, multiplier: multiplier)
        
        let orbitalCorrectionForInclination = calculateOrbitalCorrectionForInclination(for: station, absLat: absLat, exponent: exponent)
        let orbitInclinationInRadiansCorrected = pow(orbitInclination, orbitalCorrectionForInclination) * headingFactor
        
        let compositeRotationMatrix = createCompositeRotationMatrix(orbitInclinationInRadiansCorrected: orbitInclinationInRadiansCorrected, orbitalCorrectionForLon: orbitalCorrectionForLon, orbitalCorrectionForLat: orbitalCorrectionForLat)
        
        orbitTrackNode.transform = compositeRotationMatrix
    }

    private func createOrbitTrack(for station: StationsAndSatellites) -> SCNNode? {
        let orbitTrack = SCNTorus()
        
        switch station {
        case .iss:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dRedCGColor
            orbitTrack.ringRadius = CGFloat(Globals.issOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .tss:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dGoldCGColor
            orbitTrack.ringRadius = CGFloat(Globals.tssOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .hst:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.hubbleOrbitalCGColor
            orbitTrack.ringRadius = CGFloat(Globals.hubbleOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .none:
            return nil
        }
        
        return SCNNode(geometry: orbitTrack)
    }

    private func adjustCoordinates(lat: Float, lon: Float) -> (lat: Float, lon: Float) {
        let adjustedLat = lat + Float(Globals.oneEightyDegrees)
        let adjustedLon = lon - Float(Globals.oneEightyDegrees)
        return (lat: adjustedLat, lon: adjustedLon)
    }

    private func getOrbitInclination(for station: StationsAndSatellites) -> Float {
        switch station {
        case .iss:
            return Globals.issOrbitInclinationInRadians
        case .tss:
            return Globals.tssOrbitInclinationInRadians
        case .hst:
            return Globals.hubbleOrbitInclinationInRadians
        case .none:
            return 0.0
        }
    }

    private func getMultiplier(for station: StationsAndSatellites) -> Float {
        switch station {
        case .iss:
            return 2.5
        case .tss:
            return 2.8
        case .hst:
            return 3.1
        case .none:
            return 0.0
        }
    }

    private func calculateExponent(absLat: Float, orbitInclination: Float, multiplier: Float) -> Float {
        return .pi / multiplier + absLat * Float(Globals.degreesToRadians) / orbitInclination
    }

    private func calculateOrbitalCorrectionForInclination(for station: StationsAndSatellites, absLat: Float, exponent: Float) -> Float {
        switch station {
        case .iss:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [12.0, 17.0, 25.0, 33.0, 40.0, 45.0, 49.0, 51.0], powers: [0.80, 0.85, 1.00, 1.25, 1.60, 2.00, 2.50, 3.20, 4.00])
        case .tss:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [15.0, 20.0, 25.0, 30.0, 35.0, 38.0, 40.0, 41.0, 41.5], powers: [0.75, 0.85, 1.00, 1.20, 1.45, 1.70, 2.00, 2.30, 2.50, 2.80])
        case .hst:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [10.0, 15.0, 18.0, 20.0, 22.0, 24.0, 26.0, 27.0], powers: [0.35, 0.50, 0.65, 0.80, 1.00, 1.30, 1.75, 2.10, 3.00])
        case .none:
            return 0.0
        }
    }

    private func calculateOrbitalCorrection(absLat: Float, exponent: Float, thresholds: [Float], powers: [Float]) -> Float {
        for (index, threshold) in thresholds.enumerated() {
            if absLat <= threshold {
                return pow(exponent, powers[index])
            }
        }
        return pow(exponent, powers.last ?? 1.0)
    }

    private func createCompositeRotationMatrix(orbitInclinationInRadiansCorrected: Float, orbitalCorrectionForLon: Float, orbitalCorrectionForLat: Float) -> SCNMatrix4 {
        var rotationMatrix1 = SCNMatrix4Identity
        var rotationMatrix2 = SCNMatrix4Identity
        var rotationMatrix3 = SCNMatrix4Identity
        
        rotationMatrix1 = SCNMatrix4RotateF(rotationMatrix1, orbitInclinationInRadiansCorrected, 0, 0, 1)
        rotationMatrix2 = SCNMatrix4RotateF(rotationMatrix2, orbitalCorrectionForLon, 0, 1, 0)
        rotationMatrix3 = SCNMatrix4RotateF(rotationMatrix3, orbitalCorrectionForLat, 1, 0, 0)
        
        let firstProduct = SCNMatrix4Mult(rotationMatrix3, rotationMatrix2)
        return SCNMatrix4Mult(rotationMatrix1, firstProduct)
    }
    
    
//#if !os(watchOS)
    
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
    
//#endif
    
    
    /// Add a marker to the globe and make it pulse
    public func addMarker(_ marker: EarthGlobeMarkers, shouldPulse: Bool) {
        
        globe.addChildNode(marker.node)
        
#if !os(watchOS)
        if Globals.pulseSatelliteMarkerForGlobe && shouldPulse {
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
