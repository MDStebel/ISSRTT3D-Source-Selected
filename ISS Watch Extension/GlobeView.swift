//
//  SubSolarPointView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct GlobeView: View {
    // Get the phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // Get the subsolar point coordinates
    @State private var globeNode  = GlobeViewModel().globeMainNode
    @State private var globeScene = GlobeViewModel().globeScene
    
    var body: some View {
        NavigationView {
            VStack {
                SceneView(scene: globeScene, pointOfView: globeNode, options: [.allowsCameraControl])
                
                NavigationLink(
                    destination: SubSolarPointView()
                ) {
                    Text("Details")
                }
                .withISSNavigationLinkFormatting()
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Globe")
        }
    }
}
    
struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GlobeView()
        }
    }
}
