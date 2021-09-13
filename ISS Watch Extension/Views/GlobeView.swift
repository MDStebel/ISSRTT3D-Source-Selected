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
                VStack {
                    
                    // Presents the globe
                    SceneView(scene: globeViewModel.globeScene,
                              pointOfView: globeViewModel.globeMainNode,
                              options: [.allowsCameraControl])
                    Spacer(minLength: 40)
                }
                
                VStack {
                    Spacer()
                    NavigationLink(
                        destination: DetailView()
                    ) {
                        Text("Details")
                    }
                    .withISSNavigationLinkFormatting()
                    .padding()
                }
            }
            .navigationTitle("Globe")
            .ignoresSafeArea(edges: [.bottom])
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
