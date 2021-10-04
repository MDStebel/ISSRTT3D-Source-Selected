//
//  SubSolarPointView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct DetailView: View {
    
    // Get the phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // Publishers we're observing for updated position data
    @StateObject private var issPosition   = SatellitePositionViewModel(satellite: .iss)
    @StateObject private var tssPosition   = SatellitePositionViewModel(satellite: .tss)
    @StateObject private var subSolarPoint = SubSolarViewModel()
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                DataCellView(title: "ISS Position",
                             altitude: issPosition.altitude,
                             altitudeInKm: issPosition.altitudeInKm,
                             altitudeInMi: issPosition.altitudeInMi,
                             latitude: issPosition.formattedLatitude,
                             longitude: issPosition.formattedLongitude,
                             sidebarColor: .ISSRTT3DRed
                )
                
                DataCellView(title: "Tiangong Position",
                             altitude: tssPosition.altitude,
                             altitudeInKm: tssPosition.altitudeInKm,
                             altitudeInMi: tssPosition.altitudeInMi,
                             latitude: tssPosition.formattedLatitude,
                             longitude: tssPosition.formattedLongitude,
                             sidebarColor: .ISSRTT3DGold
                )
                
                DataCellView(title: "Subsolar Point",
                             altitude: nil,
                             altitudeInKm: nil,
                             altitudeInMi: nil,
                             latitude: subSolarPoint.subsolarLatitude,
                             longitude: subSolarPoint.subsolarLongitude,
                             sidebarColor: .yellow
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Details")
        
        // Update the coordinates when this view appears
        .onAppear() {
            start()
        }
        
        // Stop updating when this view disappears
        .onDisappear() {
            stop()
        }
        
        // Respond to lifecycle phases
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // The scene has become active, so update the subsolar point
                start()
            case .inactive:
                // The app has become inactive, so stop the timer
                stop()
            case .background:
                // The app has moved to the background
                stop()
            @unknown default:
                fatalError("The app has entered an unknown state.")
            }
        }
    }
    
    private func start() {
        issPosition.startUp()
        tssPosition.startUp()
        subSolarPoint.startUp()
    }
    
    private func stop() {
        issPosition.stop()
        tssPosition.stop()
        subSolarPoint.stop()
    }
}


struct SubSolarPointView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView()
        }
    }
}
