//
//  EarthGlobe.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// The 3D Interactive Earth Globe Model
class EarthGlobe {
    
    static let glowPointWidth: CGFloat     = 0.16                               // The size factor for the marker

    let ambientLightIntensity: CGFloat     = 100                                // The default value is 1000
    let cameraAltitude                     = Globals.cameraAltitude
    let dayNumberOfWinterStolsticeInYear   = 512.0                              // The winter solstice is on approximately Dec 21, 22, or 23
    let daysInAYear                        = Globals.numberOfDaysInAYear
    let defaultCameraFov                   = Globals.defaultCameraFov
    let distanceToISSOrbit                 = Globals.ISSOrbitAltitudeInScene
    let dragWidthInDegrees                 = 270.0                              // The amount to rotate the globe on one edge-to-edge swipe (in degrees)
    let globeDefaultRotationSpeedInSeconds = 90.0                               // 360° revolution in 90 seconds
    let globeRadius                        = Globals.globeRadiusFactor
    let glowPointAltitude                  = Globals.orbitalAltitudeFactor
    let maxFov                             = Globals.maxFov                     // Max zoom in degrees
    let maxLatLonPerUnity                  = 1.1
    let minFov                             = Globals.minFov                     // Min zoom in degrees
    let minLatLonPerUnity                  = -0.1
    let sceneBoxSize: CGFloat              = 1000.0
    let tiltOfEarthAxisInDegrees           = Globals.earthTiltInDegrees
    let tiltOfEarthAxisInRadians           = Globals.earthTiltInRadians
    
    var camera                             = SCNCamera()
    var cameraNode                         = SCNNode()
    var globe                              = SCNNode()
    var globeSegmentCount                  = 540
    var orbitTrack                         = SCNTorus()
    var scene                              = SCNScene()
    var seasonalTilt                       = SCNNode()
    var skybox                             = SCNNode()
    var sun                                = SCNNode()
    var userRotation                       = SCNNode()
    var userTilt                           = SCNNode()
    
    var gestureHost : SCNView?
    var lastFovBeforeZoom : CGFloat?
    var lastPanLoc : CGPoint?
    
    internal init() {
        
        // Create the globe shape
        let globeShape                 = SCNSphere(radius: CGFloat(globeRadius) )
        globeShape.segmentCount        = globeSegmentCount
        
        guard let earthMaterial        = globeShape.firstMaterial else { return }

        // Earth's texture is revealed by diffuse light sources
        earthMaterial.diffuse.contents = "8081_earthmap_8190px.jpg"         // Use the high-resolution Earth image
        
        let emission                   = SCNMaterialProperty()
        emission.contents              = "8081_earthlights_8190px"
        earthMaterial.setValue(emission, forKey: "emissionTexture")
        
        /// OpenGL lighting map code
        let shaderModifier =    """
                                uniform sampler2D emissionTexture;
                                vec3 light = _lightingContribution.diffuse;
                                float lum = max(0.0, 1 - (0.2126 * light.r + 0.7152 * light.g + 0.0722 * light.b));
                                vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum * 1.0;
                                _output.color += emission;
                                """
        earthMaterial.shaderModifiers     = [.fragment: shaderModifier]
        
        // Texture is revealed by specular light sources
        earthMaterial.specular.contents   = "8081_earthspec_512px.jpg"
        earthMaterial.specular.intensity  = 0.2
        
        // Water is reflective and land is not
        earthMaterial.metalness.contents  = "metalness-1.png"
        earthMaterial.roughness.contents  = "roughness-1.png"

        // Make the mountains appear taller
        earthMaterial.normal.contents     = "earth-bump-1.png"
        earthMaterial.normal.intensity    = 0.5
        
        // Creates a realistic specular reflection that changes its aspect based on angle
        earthMaterial.fresnelExponent     = 1.75
        
        // Assign the shape to the globe's geometry property
        globe.geometry = globeShape

        // Set up the basic globe nodes
        scene.rootNode.addChildNode(userTilt)
        userTilt.addChildNode(userRotation)
        userRotation.addChildNode(globe)
        
    }
    
    
    /// Set up our scene
    /// - Parameters:
    ///   - theScene: The scene view to use
    ///   - pinchGestureIsEnabled: True if we're rendering the full globe and want to pinch to zoom
    func setupInSceneView(_ theScene: SCNView, pinchGestureIsEnabled : Bool ) {
        
        theScene.scene                      = self.scene
        theScene.autoenablesDefaultLighting = false
        theScene.showsStatistics            = false
        
        theScene.allowsCameraControl        = true
        self.gestureHost                    = theScene
        
        if pinchGestureIsEnabled {
            let pan                         = UIPanGestureRecognizer(target: self, action:#selector(EarthGlobe.onPanGesture(pan:)))
            theScene.addGestureRecognizer(pan)
            let pinch                       = UIPinchGestureRecognizer(target: self, action: #selector(EarthGlobe.onPinchGesture(pinch:)))
            theScene.addGestureRecognizer(pinch)
        } else {                            // Handle pinch gestures with default handler, but use the following code for panning gesture handling
            let pan                         = UIPanGestureRecognizer(target: self, action:#selector(EarthGlobe.onPanGesture(pan:)))
            theScene.addGestureRecognizer(pan)
        }
        
        completeTheSetup()
        
    }
    
    
    private func completeTheSetup() {

        // Give the world some ambient light to illuminate the globe a bit in nighttime
        let ambientLight       = SCNLight()
        ambientLight.type      = .ambient
        ambientLight.intensity = ambientLightIntensity
        
        // Add the camera
        camera.fieldOfView     = defaultCameraFov
        camera.zFar            = 10000
        cameraNode.position    = SCNVector3(x: 0, y: 0, z:  globeRadius + cameraAltitude )
        cameraNode.constraints = [ SCNLookAtConstraint(target: self.globe) ]
        cameraNode.light       = ambientLight
        cameraNode.camera      = camera
        scene.rootNode.addChildNode(cameraNode)
        
    }

    
    @objc fileprivate func onPanGesture(pan : UIPanGestureRecognizer) {
        
        // Handle panning and rotating
        guard let sceneView = pan.view else { return }
        let loc = pan.location(in: sceneView)
        
        if pan.state == .began {
            handlePanBegan(loc)
        } else {
            guard pan.numberOfTouches == 1 else { return }
            self.handlePanCommon(loc, viewSize: sceneView.frame.size)
        }
        
    }
    
    
    @objc fileprivate func onPinchGesture(pinch: UIPinchGestureRecognizer) {
        
        // Update the FOV of the camera
        if pinch.state == .began {
            self.lastFovBeforeZoom = self.camera.fieldOfView
        } else {
            if let lastFov = self.lastFovBeforeZoom {
                var newFov = lastFov / CGFloat(pinch.scale)
                if newFov < minFov {
                    newFov = minFov
                } else if newFov > maxFov {
                    newFov = maxFov
                }
                self.camera.fieldOfView = newFov
            }
        }
        
    }
    
    
    public func handlePanBegan(_ loc: CGPoint) {
        
        lastPanLoc = loc
        
    }
    
    
    public func handlePanCommon(_ loc: CGPoint, viewSize: CGSize) {
        guard let lastPanLoc = lastPanLoc else { return }
        
        // Determine the movement change
        let delta = CGSize(width: (lastPanLoc.x - loc.x) / viewSize.width, height: (lastPanLoc.y - loc.y) / viewSize.height)
        
        //  DeltaX = amount of rotation to apply (about the Earth's axis)
        //  DeltaY = amount of tilt to apply (to the Earth's axis)
        if delta.width != 0.0 || delta.height != 0.0 {
            
            // As the user zooms in (smaller fieldOfView value), reduce finger travel
            let fovProportion        = (self.camera.fieldOfView - minFov) / (maxFov - minFov)
            let fovProportionRadians = Float(fovProportion * CGFloat(dragWidthInDegrees)) * Globals.degreesToRadians
            let rotationAboutAxis    = Float(delta.width) * fovProportionRadians
            let tiltOfAxisItself     = Float(delta.height) * fovProportionRadians
            
            // Apply the rotation
            let rotate               = SCNMatrix4RotateF(userRotation.worldTransform, -rotationAboutAxis, 0.0, 1.0, 0.0)
            userRotation.setWorldTransform(rotate)
            
            // Now, apply the tilt
            let tilt                 = SCNMatrix4RotateF(userTilt.worldTransform, -tiltOfAxisItself, 1.0, 0.0, 0.0)
            userTilt.setWorldTransform(tilt)
            
        }
        
        self.lastPanLoc = loc
        
    }
    
}
