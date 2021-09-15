//
//  EarthGlobe.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/22/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SceneKit


/// The 3D Interactive 3D Earth Globe Model
final class EarthGlobe: ObservableObject {
    
    // MARK: - Properties

    let ambientLightIntensity: CGFloat     = 100                                // Note: default value is 1000
    let cameraAltitude                     = Globals.cameraAltitude
    let daysInAYear                        = Globals.numberOfDaysInAYear
    let defaultCameraFov                   = Globals.defaultCameraFov
    let globeDefaultRotationSpeedInSeconds = 120.0                              // 360° revolution in n-seconds
    let globeRadiusFactor                  = Globals.globeRadiusFactor
    let globeSegmentCount                  = 1024                               // Number of subdivisions along the sphere's (Earth's) polar & azimuth angles, similar to latitude & longitude on a globe of the Earth
    let pipeRadius: CGFloat                = 0.004
    let pipeSegmentCount                   = 256                                // Number of subdivisions around the ring (orbit)
    let ringSegmentCount                   = 512                                // Number of subdivisions along the ring (orbit)
    let sceneBoxSize: CGFloat              = 1000
    let sunDistance: Float                 = 1000                               // Relative distance to the Sun
    let sunlightIntensity: CGFloat         = 3200                               // Default value is 1000 lumens
    let sunlightTemp: CGFloat              = 6000                               // Default value is 6500 Kelvin
    
    // Initialize all scenese, objects, and nodes
    var camera                             = SCNCamera()
    var cameraNode                         = SCNNode()
    var earthAxisTilt                      = SCNNode()
    var globe                              = SCNNode()
    var orbitTrack                         = SCNTorus()
    var scene                              = SCNScene()
    var sun                                = SCNNode()
    var userRotation                       = SCNNode()
    var userTilt                           = SCNNode()

    
    // MARK: - Methods
    
    /// Initializer for our Earth model
    init() {
        
        /// Create the globe shape upon which we'll build our Earth model
        let globeShape                                 = SCNSphere(radius: CGFloat(globeRadiusFactor) )
        globeShape.segmentCount                        = globeSegmentCount
        
        guard let earthMaterial                        = globeShape.firstMaterial else { return }

        /// The Earth's texture is revealed by diffuse light sources
        #if !os(watchOS)
        earthMaterial.diffuse.contents                 = "8081_earthmap_8190px"                 // Use the high-resolution Earth image
        #else
        earthMaterial.diffuse.contents                 = "8081_earthmap_2048px"                 // Use low resolution Earth image for watchOS
        #endif
        
        /// Our emitter will show city lights as Earth passes into nighttime
        let emission                                   = SCNMaterialProperty()
        #if !os(watchOS)
        emission.contents                              = "8081_earthlights_8190px"              // High-resolution city lights map
        #else
        emission.contents                              = "8081_earthlights_4096px"              // Low-resolution city lights map
        #endif
        earthMaterial.setValue(emission, forKey: "emissionTexture")
        
        /// OpenGL/Metal lighting map in C++ code that brings forth our emitter texture
        let shaderModifier                             = """
                                                         uniform sampler2D emissionTexture;
                                                         vec3 light = _lightingContribution.diffuse;
                                                         float lum = max(0.0, 1 - (0.2126 * light.r + 0.7152 * light.g + 0.0722 * light.b));
                                                         vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum * 1.0;
                                                         _output.color += emission;
                                                         """
        earthMaterial.shaderModifiers                  = [.fragment: shaderModifier]            // Apply the shader modifier code
        
        // Texture is revealed by the specular light sources
        #if !os(watchOS)
        earthMaterial.specular.contents                = "8081_earthspec_4096px"                // High-resolution specular texture map
        #else
        earthMaterial.specular.contents                = "8081_earthspec_2048px"                // Low-resolution specular texture map
        #endif
        earthMaterial.specular.intensity               = 0.2
        
        // Earth's oceans and other watery areas are reflective
        #if !os(watchOS)
        earthMaterial.metalness.contents               = "8081_earthmetalness_4096px"           // High-resolution reflectivity map
        #else
        earthMaterial.metalness.contents               = "8081_earthmetalness_2048px"           // Low-resolution reflectivity map
        #endif
        
        // Land areas are not reflective
        #if !os(watchOS)
        earthMaterial.roughness.contents               = "8081_earthroughness_4096px"           // High-resolution non-reflectivity map
        #else
        earthMaterial.roughness.contents               = "8081_earthroughness_2048px"           // Low-resolution non-reflectivity map
        #endif
        
        // The bump map (a "normal map") to make elevated areas (e.g., mountains) appear as relief
        #if !os(watchOS)
        earthMaterial.normal.contents                  = "EarthBump_NormalMap_MDS_8190px-3"     // High-resolution normal map that I created
        #else
        earthMaterial.normal.contents                  = "EarthBump_NormalMap_MDS_2048px"       // Low-resolution normal map that I created
        #endif
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
    
    #if !os(watchOS)
    /// Set up our scene
    /// - Parameters:
    ///   - theScene: The scene view to use
    ///   - pinchGestureIsEnabled: True if we're rendering the full globe and want to pinch to zoom
    func setupInSceneView(_ theScene: SCNView, customPinchGestureIsEnabled: Bool ) {
        
        theScene.scene                      = scene
        theScene.autoenablesDefaultLighting = false
        theScene.showsStatistics            = false
        theScene.allowsCameraControl        = true
              
        completeTheSetup()
    }
    
    #else
    
    /// Set up our scene
    /// - Parameters:
    ///   - theScene: The scene view to use
    ///   - pinchGestureIsEnabled: True if we're rendering the full globe and want to pinch to zoom
    func setupInSceneView() {
              
        completeTheSetup()
    }
    #endif
    
    
    /// Set up ambient lighting, camera position, FOV, etc.
    private func completeTheSetup() {

        // Let's give the Earth a bit of ambient light to illuminate the globe when it's in nighttime
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
}
