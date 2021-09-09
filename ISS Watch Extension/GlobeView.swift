//
//  GlobeView.swift
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
    @StateObject private var globeViewModel = GlobeViewModel()
    @State private var globeNode            = GlobeViewModel().globeMainNode
    @State private var globeScene           = GlobeViewModel().globeScene
    
    var body: some View {
        NavigationView {
            VStack {
                SceneView(scene: globeScene, pointOfView: globeNode, options: [.allowsCameraControl])
                
                NavigationLink(
                    destination: SubSolarPointView()
                ) {
                    Text("Subsolar")
                }
                .withISSNavigationLinkFormatting()
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Globe")
        }
        // Update the coordinates when this view appears
        .onAppear() {
            globeViewModel.startTimer()
        }
        // Respond to lifecycle phases
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // The scene has become active, so update the subsolar point
                globeViewModel.startTimer()
            case .inactive:
                // The app has become inactive.
                globeViewModel.stop()
            case .background:
                // The app has moved to the background.
                globeViewModel.stop()
            @unknown default:
                fatalError("The app has entered an unknown state.")
            }
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
