//
//  EarthGlobe.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.

//  Portions Copyright © 2017 David Mojdehi
//


import SceneKit
import QuartzCore


let kAffectedBySpring = 1 << 1
let kAmbientLightIntensity = CGFloat(200)                       // The default value is 1000
let kCameraAltitude = Float(1.85)
let kDayOfWinterStolsticeInYear = 356.0                         // The winter solstice is on approximately Dec 21, 22, or 23
let kDaysInAYear = Globals.numberOfDaysInAYear
let kDefaultCameraFov = CGFloat(30.0)
let kDistanceToISSOrbit = Globals.ISSOrbitAltitudeInScene
let kDragWidthInDegrees = 180.0                                 // The amount to rotate the globe on one edge-to-edge swipe (in degrees)
let kGlobeDefaultRotationSpeedSeconds = 60.0                    // The speed of the default spin: 1 revolution in 60 seconds
let kGlobeRadius = Globals.globeRadiusFactor
let kGlowPointAltitude = Globals.orbitalAltitudeFactor
let kGlowPointWidth = CGFloat(0.16)                             // The size factor for the marker
let kMaxFov = CGFloat(40.0)                                     // Max zoom in degrees
let kMaxLatLonPerUnity = 1.1
let kMinFov = CGFloat(4.0)                                      // Min zoom in degrees
let kMinLatLonPerUnity = -0.1
let kSkyboxSize = CGFloat(1000.0)
let kTiltOfEarthsAxisInDegrees = Globals.earthTiltInDegrees
let kTiltOfEarthsAxisInRadians = Globals.earthTiltInRadians
let kTiltOfEclipticFromGalacticPlaneDegrees = 60.2
let kTiltOfEclipticFromGalacticPlaneRadians = Float(kTiltOfEclipticFromGalacticPlaneDegrees) * Globals.degreesToRadians


/// The Earth Globe Model
class EarthGlobe {
    
    var camera = SCNCamera()
    var cameraNode = SCNNode()
    var gestureHost : SCNView?
    var globe = SCNNode()
    var lastFovBeforeZoom : CGFloat?
    var lastPanLoc : CGPoint?
    var orbitTrack = SCNTorus()
    var scene = SCNScene()
    var seasonalTilt = SCNNode()
    var skybox = SCNNode()
    var sun = SCNNode()
    var userRotation = SCNNode()
    var userTilt = SCNNode()
    
    
    internal init() {
        
        // Create the globe
        let globeShape = SCNSphere(radius: CGFloat(kGlobeRadius) )
        globeShape.segmentCount = 30
        // Texture revealed by diffuse light sources
        
        // Use the high resolution image
        guard let earthMaterial = globeShape.firstMaterial else { return }
        earthMaterial.diffuse.contents = "world-ultra.jpg"
        
        let emission = SCNMaterialProperty()
        emission.contents = "earth-emissive.jpg"
        earthMaterial.setValue(emission, forKey: "emissionTexture")
        let shaderModifier =    """
                                uniform sampler2D emissionTexture;

                                vec3 light = _lightingContribution.diffuse;
                                float lum = max(0.0, 1 - 16.0 * (0.2126*light.r + 0.7152*light.g + 0.0722*light.b));
                                vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum * 0.5;
                                _output.color += emission;
                                """
        earthMaterial.shaderModifiers = [.fragment: shaderModifier]
        
        // Texture revealed by specular light sources
        //earthMaterial.specular.contents = "earth_lights.jpg"
        //earthMaterial.shininess = 0.1
        earthMaterial.specular.contents = "earth-specular.jpg"
        earthMaterial.specular.intensity = 0.2
        
        // Oceans are reflective and land is matte
        if #available(macOS 10.12, iOS 10.0, *) {
            earthMaterial.metalness.contents = "metalness.png"
            earthMaterial.roughness.contents = "roughness.png"
        }
        
        // Make the mountains appear taller
        // (gives them shadows from point lights, but doesn't make them stick up beyond the edges)
        earthMaterial.normal.contents = "earth-bump.png"
        earthMaterial.normal.intensity = 0.3
        
        //earthMaterial.reflective.contents = "envmap.jpg"
        //earthMaterial.reflective.intensity = 0.75
        earthMaterial.fresnelExponent = 2
        globe.geometry = globeShape
        
        // Globe spins once per minute
        let spinRotation = SCNAction.rotate(by: 2 * .pi, around: SCNVector3(0, 1, 0), duration: kGlobeDefaultRotationSpeedSeconds)
        let spinAction = SCNAction.repeatForever(spinRotation)
        globe.runAction(spinAction)
        
        
        // Set up the Sun (i.e., the light source at the default position)
        setupTheSun(lat: 0, lon: 0)
        
        
        // Set up the nodes
        scene.rootNode.addChildNode(userTilt)
        userTilt.addChildNode(userRotation)
        userRotation.addChildNode(globe)
        
    }
    
    
    /// Move camera to given latitude and longitude
    public func moveCameraToPointOnGlobe(lat: Float, lon: Float) {
        
        let newPosition = CoordinateConversions.convertLatLonCoordinatesToXYZ(lat, lon, alt: Globals.ISSOrbitAltitudeInScene)
        let x = newPosition.x
        let y = newPosition.y
        cameraNode.position = SCNVector3(x: x, y: y, z: kGlobeRadius + kCameraAltitude)
        
    }
    
    
    internal func setupInSceneView(_ v: SCNView, forARKit : Bool ) {
        
        v.scene = self.scene
        v.autoenablesDefaultLighting = false
        v.showsStatistics = false
        
        self.gestureHost = v
        
        if forARKit {
            
            v.allowsCameraControl = true
            skybox.removeFromParentNode()
            
        } else {
            
            finishNonARSetup()
            
            v.allowsCameraControl = false
            
            let pan = UIPanGestureRecognizer(target: self, action:#selector(EarthGlobe.onPanGesture(pan:) ) )
            //            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(SwiftGlobe.onPinchGesture(pinch:) ) )
            v.addGestureRecognizer(pan)
            //            v.addGestureRecognizer(pinch)
            
        }
        
    }
    
    
    
    private func finishNonARSetup() {
        //----------------------------------------
        // Add the galaxy skybox
        // We make a custom skybox instead of using scene.background, so we can control the galaxy tilt
        //        let cubemapTextures = ["eso0932a_front.png","eso0932a_right.png",
        //                               "eso0932a_back.png", "eso0932a_left.png",
        //                               "eso0932a_top.png", "eso0932a_bottom.png"]
        //        let cubemapMaterials = cubemapTextures.map { (name) -> SCNMaterial in
        //            let material = SCNMaterial()
        //            material.diffuse.contents = name
        //            material.isDoubleSided = true
        //            material.lightingModel = .constant
        //            return material
        //        }
        //        skybox.geometry = SCNBox(width: kSkyboxSize, height: kSkyboxSize, length: kSkyboxSize, chamferRadius: 0.0)
        //        skybox.geometry!.materials = cubemapMaterials
        //        skybox.eulerAngles = SCNVector3(x: kTiltOfEclipticFromGalacticPlaneRadians, y: 0.0, z: 0.0 )
        //        scene.rootNode.addChildNode(skybox)
        
        // Give us some ambient light (to light the rest of the model)
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = kAmbientLightIntensity // default is 1000!
        
        //---------------------------------------
        // Create and add a camera to the scene
        // Set up a 'telephoto' shot (to avoid any fisheye effects)
        // (telephoto: narrow field of view at a long distance
        camera.fieldOfView = kDefaultCameraFov
        camera.zFar = 10000
        cameraNode.position = SCNVector3(x: 0, y: 0, z:  kGlobeRadius + kCameraAltitude )
        cameraNode.constraints = [ SCNLookAtConstraint(target: self.globe) ]
        cameraNode.light = ambientLight
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
    }
    
    
    private func addPanGestures() {
        
    }
    
    
    @objc fileprivate func onPanGesture(pan : UIPanGestureRecognizer) {
        // we get here on a tap!
        guard let sceneView = pan.view else { return }
        let loc = pan.location(in: sceneView)
        
        if pan.state == .began {
            handlePanBegan(loc)
        } else {
            guard pan.numberOfTouches == 1 else { return }
            self.handlePanCommon(loc, viewSize: sceneView.frame.size)
        }
    }
    
    
    @objc fileprivate func onPinchGesture(pinch: UIPinchGestureRecognizer){
        // Update the FOV of the camera
        if pinch.state == .began {
            self.lastFovBeforeZoom = self.camera.fieldOfView
        } else {
            if let lastFov = self.lastFovBeforeZoom {
                var newFov = lastFov / CGFloat(pinch.scale)
                if newFov < kMinFov {
                    newFov = kMinFov
                } else if newFov > kMaxFov {
                    newFov = kMaxFov
                }
                
                self.camera.fieldOfView =  newFov
            }
        }
    }
    
    
    // A simple zoom interface (for the watch)
    public var zoomFov : CGFloat {
        get {
            return self.camera.fieldOfView
        }
        set(newFov) {
            if newFov < kMinFov {
                self.camera.fieldOfView = kMinFov
            } else if newFov > kMaxFov {
                self.camera.fieldOfView = kMaxFov
            } else {
                self.camera.fieldOfView = newFov
            }
        }
    }
    
    
    public func handlePanBegan(_ loc: CGPoint) {
        
        lastPanLoc = loc
        
    }
    
    
    public func handlePanCommon(_ loc: CGPoint, viewSize: CGSize) {
        guard let lastPanLoc = lastPanLoc else { return }
        
        // Measure the movement change
        let delta = CGSize(width: (lastPanLoc.x - loc.x) / viewSize.width, height: (lastPanLoc.y - loc.y) / viewSize.height)
        
        //  DeltaX = amount of rotation to apply (about the world axis)
        //  DeltaY = amount of tilt to apply (to the axis itself)
        if delta.width != 0.0 || delta.height != 0.0 {
            
            // As the user zooms in (smaller fieldOfView value), the finger travel is reduced
            let fovProportion = (self.camera.fieldOfView - kMinFov) / (kMaxFov - kMinFov)
            let fovProportionRadians = Float(fovProportion * CGFloat(kDragWidthInDegrees) ) * (.pi / 180)
            let rotationAboutAxis = Float(delta.width) * fovProportionRadians
            let tiltOfAxisItself = Float(delta.height) * fovProportionRadians
            
            // First, apply the rotation
            let rotate = SCNMatrix4RotateF(userRotation.worldTransform, -rotationAboutAxis, 0.0, 1.0, 0.0)
            userRotation.setWorldTransform(rotate)
            
            // Now, apply the tilt
            let tilt = SCNMatrix4RotateF(userTilt.worldTransform, -tiltOfAxisItself, 1.0, 0.0, 0.0)
            userTilt.setWorldTransform(tilt)
            
        }
        
        self.lastPanLoc = loc
        
    }
    
}


func SCNMatrix4RotateF(_ src: SCNMatrix4, _ angle : Float, _ x : Float, _ y : Float, _ z : Float) -> SCNMatrix4 {
    
    return SCNMatrix4Rotate(src, angle, x, y, z)
    
}
