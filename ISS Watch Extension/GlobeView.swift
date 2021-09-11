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
    @ObservedObject private var globeViewModel = GlobeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    SceneView(scene: globeViewModel.globeScene, pointOfView: globeViewModel.globeMainNode, options: [.allowsCameraControl])
                    Spacer(minLength: 45)
                }
                
                VStack {
                    Spacer()
                    NavigationLink(
                        destination: SubSolarPointView()
                    ) {
                        Text("Subsolar")
                    }
                    .withISSNavigationLinkFormatting()
                    .padding()
                }
            }
            .navigationTitle("Globe")
            .ignoresSafeArea(edges: [.bottom])
            
            // Update the scene when this view appears
            .onAppear() {
                globeViewModel.startTimer()
            }
            
            // Stop updating when this view disappears
            .onDisappear() {
                globeViewModel.stop()
            }
            
            // Respond to lifecycle phases
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    // The scene has become active, so start the timer
                    globeViewModel.startTimer()
                case .inactive:
                    // The app has become inactive, so stop the timer
                    globeViewModel.stop()
                case .background:
                    // The app has moved to the background, so stop the timer
                    globeViewModel.stop()
                @unknown default:
                    globeViewModel.stop()
                }
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
