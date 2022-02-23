//
//  GlobeView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021-2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct GlobeView: View {
    
    // Get the current phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // We're observing our view model
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                // MARK: Globe
                
                // Render the globe. This will update continually as new coordinates are received from the view model.
                SceneView(scene: vm.globeScene,
                          pointOfView: vm.globeMainNode,
                          options: [.allowsCameraControl]
                )
                
                // Show progress indicator when starting up/resetting
                if vm.isStartingUp {
                    ProgressView()
                }
                
                // MARK: Buttons
                
                VStack {
                    Spacer() // we want the buttons at the bottom of the screen
                    
                    // Button group
                    HStack(spacing: -15) {
                        Button(action: {
                            vm.reset()
                        })
                        {
                            Image("reset")
                        }
                        .withSmallButtonModifier
                        
                        Button(action: {
                            vm.spinEnabled.toggle()
                        })
                        {
                            Image("rotate3D")
                        }
                        .withSmallButtonModifier
                        
                        NavigationLink(
                            destination: DetailView(vm: vm)         // Show detail view with data from our view model
                        )
                        {
                            Image(systemName: "tablecells.fill")
                        }
                        .withSmallButtonModifier
                    }
                    .padding([.horizontal])
                    .padding([.bottom], 3.0)
                }
                // Pop up an alert if there was an error fetching data
                .alert(isPresented: $vm.wasError) {
                    Alert(title: Text(vm.errorForAlert?.title ?? "Oops!"),
                          message: Text(vm.errorForAlert?.message ?? "Can't get data.")
                    )
                }
            }
            .ignoresSafeArea(edges: [.vertical])
            .navigationTitle("Globe")
            .navigationBarTitleDisplayMode(.inline)     // We want the small navigation title
            
            // MARK: Handle lifecycle events
            
            // Update the coordinates when this view appears
            .onAppear() {
                start()
            }
            
            // Respond to lifecycle phases
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    // The scene has become active, so start updating
                    start()
                case .inactive:
                    // The app has become inactive, so stop updating
                    stop()
                case .background:
                    // The app has moved to the background, so stop updating
                    stop()
                @unknown default:
                    fatalError("The app has entered an unknown state.")
                }
                
            }
            
        }
        
    }
    
    private func start() {
        vm.start()
    }
    
    private func stop() {
        vm.stop()
    }
    
}

    
struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GlobeView()
        }
    }
}
