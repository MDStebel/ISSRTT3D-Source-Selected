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
                            Image(systemName: "arrow.uturn.backward.square.fill")
                        }
                        .withMDSButtonModifier()
                        .shadow(color: .ISSRTT3DRed, radius: 7)
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: DetailView()
                        ) {
                            Image(systemName: "tablecells.fill")
                        }
                        .withMDSButtonModifier()
                        .shadow(color: .ISSRTT3DRed, radius: 7)
                    }
                    .padding([.leading, .trailing], 25)
                    .padding([.bottom], 3)
                }
            }
            .ignoresSafeArea(edges: [.vertical])
            .navigationTitle("Globe")
            .navigationBarTitleDisplayMode(.inline) // We want the small navigation title
            .ignoresSafeArea(edges: [.top,.bottom])
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
