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
    
    // We're observing our view model
    @StateObject private var globeViewModel = GlobeViewModel()
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                // Present the globe
                SceneView(scene: globeViewModel.globeScene,
                          pointOfView: globeViewModel.globeMainNode,
                          options: [.allowsCameraControl])
                
                // Show progress indicator when starting up/resetting
                if globeViewModel.isStartingUp {
                    ProgressView()
                }
                
                // Buttons
                VStack {
                    Spacer()
                    
                    // Button group
                    HStack {
                        Button(action: {
                            globeViewModel.reset()
                        }) {
                            Image(systemName: "arrowshape.turn.up.backward.fill")
                        }
                        .withMDSButtonModifier
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: DetailView()
                        ) {
                            Image(systemName: "tablecells.fill")
                        }
                        .withMDSButtonModifier
                    }
                    .padding([.horizontal], 25)
                    .padding([.bottom], 7)
                }
            }
            .ignoresSafeArea(edges: [.vertical])
            .navigationTitle("Globe")
            .navigationBarTitleDisplayMode(.inline) // We want the small navigation title
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
