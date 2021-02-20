//
//  EarthGlobe.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// The 3D Interactive Earth Globe Model
class EarthGlobe {
    
    static let markerWidth: CGFloat        = 0.16                               // The size factor for the marker

    let ambientLightIntensity: CGFloat     = 100                                // The default value is 1000
    let cameraAltitude                     = Globals.cameraAltitude
    let dayNumberOfWinterStolsticeInYear   = 512.0                              // The winter solstice is on approximately Dec 21, 22, or 23
    let daysInAYear                        = Globals.numberOfDaysInAYear
    let defaultCameraFov                   = Globals.defaultCameraFov
    let distanceToISSOrbit                 = Globals.ISSOrbitAltitudeInScene
    let dragWidthInDegrees                 = 270.0                              // The amount to rotate the globe on one edge-to-edge swipe (in degrees)
    let globeDefaultRotationSpeedInSeconds = 120.0                              // 360° revolution in n-seconds
    let globeRadiusFactor                  = Globals.globeRadiusFactor
    let globeSegmentCount                  = 1024                               // The number of subdivisions along the sphere's polar & azimuth angles, similar to the latitude & longitude system on a globe of the Earth
    let markerAltitude                     = Globals.orbitalAltitudeFactor
    let maxFov                             = Globals.maxFov                     // Max zoom in degrees
    let minFov                             = Globals.minFov                     // Min zoom in degrees
    let sceneBoxSize: CGFloat              = 1000.0
    
    var camera                             = SCNCamera()
    var cameraNode                         = SCNNode()
    var earthAxisTilt                      = SCNNode()
    var globe                              = SCNNode()
    var orbitTrack                         = SCNTorus()
    var scene                              = SCNScene()
    var sun                                = SCNNode()
    var userRotation                       = SCNNode()
    var userTilt                           = SCNNode()
    
    var gestureHost : SCNView?
    var lastFovBeforeZoom : CGFloat?
    var lastPanLoc : CGPoint?
    
    
    init() {
        
        // Create the globe shape upon which we'll build our Earth model
        let globeShape                                 = SCNSphere(radius: CGFloat(globeRadiusFactor) )
        globeShape.segmentCount                        = globeSegmentCount
        
        guard let earthMaterial                        = globeShape.firstMaterial else { return }

        // The Earth's texture is revealed by diffuse light sources
        earthMaterial.diffuse.contents                 = "8081_earthmap_8190px"                 // Use the high-resolution Earth image
        
        /// Our emitter will show city lights as Earth passes into nighttime
        let emission                                   = SCNMaterialProperty()
        emission.contents                              = "8081_earthlights_8190px"              // Our high-resolution city lights map
        earthMaterial.setValue(emission, forKey: "emissionTexture")
        
        /// OpenGL/Metal lighting map C++ code that brings forth our emitter texture
        let shaderModifier                             = """
                                                         uniform sampler2D emissionTexture;
                                                         vec3 light = _lightingContribution.diffuse;
                                                         float lum = max(0.0, 1 - (0.2126 * light.r + 0.7152 * light.g + 0.0722 * light.b));
                                                         vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum * 1.0;
                                                         _output.color += emission;
                                                         """
        earthMaterial.shaderModifiers                  = [.fragment: shaderModifier]            // Apply the shader modifier code
        
        // Texture is revealed by the specular light sources
        earthMaterial.specular.contents                = "8081_earthspec_4096px"                // High-resolution specular texture map
        earthMaterial.specular.intensity               = 0.2
        
        // Earth's oceans and other watery areas are reflective
        earthMaterial.metalness.contents               = "8081_earthmetalness_4096px"           // High-resolution reflectivity map
        
        // Land areas are not reflective
        earthMaterial.roughness.contents               = "8081_earthroughness_4096px"           // High-resolution non-reflectivity map

        // Use bump map (a "normal map") to make elevated areas (e.g., mountains) appear as relief
        earthMaterial.normal.contents                  = "EarthBump_NormalMap_MDS_8190px-3"     // High-resolution normal map
        earthMaterial.normal.intensity                 = 0.52
        
        // Create a realistic specular reflection that changes its aspect based on angle
        earthMaterial.fresnelExponent                  = 1.75
        
        // Assign the shape to the globe's geometry property
        globe.geometry                                 = globeShape

        // Finally, we set up the basic globe nodes. We'll add ISS marker, and other dynamic objects later.
        scene.rootNode.addChildNode(userTilt)
        userTilt.addChildNode(userRotation)
        userRotation.addChildNode(globe)
        
    }
    
    
    /// Set up our scene
    /// - Parameters:
    ///   - theScene: The scene view to use
    ///   - pinchGestureIsEnabled: True if we're rendering the full globe and want to pinch to zoom
    func setupInSceneView(_ theScene: SCNView, customPinchGestureIsEnabled: Bool ) {
        
        theScene.scene                      = scene
        theScene.autoenablesDefaultLighting = false
        theScene.showsStatistics            = false
        
        theScene.allowsCameraControl        = true
        
//        gestureHost                         = theScene
//        if customPinchGestureIsEnabled {    // Overrides build-in scene kit gesture handlers
//            let pan                         = UIPanGestureRecognizer(target: self, action:#selector(EarthGlobe.onPanGesture(pan:)))
//            theScene.addGestureRecognizer(pan)
//            let pinch                       = UIPinchGestureRecognizer(target: self, action: #selector(EarthGlobe.onPinchGesture(pinch:)))
//            theScene.addGestureRecognizer(pinch)
//        } else {                            // Handle pinch gestures with default handler, but use the following code for panning gesture handling
//            let pan                         = UIPanGestureRecognizer(target: self, action:#selector(EarthGlobe.onPanGesture(pan:)))
//            theScene.addGestureRecognizer(pan)
//        }
        
        completeTheSetup()
        
    }
    
    
    private func completeTheSetup() {

        // Let's give the Earth a bit of ambient light to illuminate the globe when its in nighttime
        let ambientLight            = SCNLight()
        ambientLight.type           = .ambient
        ambientLight.intensity      = ambientLightIntensity
        
        // Add the camera
        camera.fieldOfView          = defaultCameraFov
        camera.zFar                 = 10000
        
        let adjustedCameraAltitude  = globeRadiusFactor + cameraAltitude
        cameraNode.position         = SCNVector3(x: 0, y: 0, z: adjustedCameraAltitude)
        
        cameraNode.constraints      = [SCNLookAtConstraint(target: globe)]
        cameraNode.light            = ambientLight
        cameraNode.camera           = camera
        
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
            panHandler(loc, viewSize: sceneView.frame.size)
        }
        
    }
    
    
    @objc fileprivate func onPinchGesture(pinch: UIPinchGestureRecognizer) {
        
        // Update the camera's field of view
        if pinch.state == .began {
            lastFovBeforeZoom = camera.fieldOfView
        } else {
            if let lastFov = lastFovBeforeZoom {
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
    
    
    public func panHandler(_ loc: CGPoint, viewSize: CGSize) {
        
        guard let lastPanLoc = lastPanLoc else { return }
        
        // Determine the movement change
        let delta = CGSize(width: (lastPanLoc.x - loc.x) / viewSize.width, height: (lastPanLoc.y - loc.y) / viewSize.height)
        
        //  DeltaX = amount of rotation to apply (around the Earth's axis)
        //  DeltaY = amount of tilt to apply (to the Earth's axis)
        if delta.width != 0.0 || delta.height != 0.0 {
            
            // As the user zooms in (smaller fieldOfView value), reduce finger travel
            let fovProportion        = (camera.fieldOfView - minFov) / (maxFov - minFov)
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
