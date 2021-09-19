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
    
    // View models we're responding to
    @StateObject private var issPosition   = SatellitePositionViewModel(satellite: .iss)
    @StateObject private var tssPosition   = SatellitePositionViewModel(satellite: .tss)
    @StateObject private var subSolarPoint = SubSolarViewModel()
    
    var body: some View {
        
        let issLatitudeFormatted  = issPosition.formattedLatitude
        let issLongitudeFormatted = issPosition.formattedLongitude
        let tssLatitudeFormatted  = tssPosition.formattedLatitude
        let tssLongitudeFormatted = tssPosition.formattedLongitude
        
        ScrollView {
            VStack {
                
                DataCellView(title: "ISS Position",
                             latitude: issLatitudeFormatted,
                             longitude: issLongitudeFormatted)
                
                DataCellView(title: "TSS Position",
                             latitude: tssLatitudeFormatted,
                             longitude: tssLongitudeFormatted)
                
                DataCellView(title: "Subsolar Point",
                             latitude: subSolarPoint.subsolarLatitude,
                             longitude: subSolarPoint.subsolarLongitude)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Details")
        
        // Update the coordinates when this view appears
        .onAppear() {
            issPosition.startUp()
            subSolarPoint.startUp()
        }

        // Stop updating when this view disappears
        .onDisappear() {
            issPosition.stop()
            subSolarPoint.stop()
        }

        // Respond to lifecycle phases
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // The scene has become active, so update the subsolar point
                issPosition.startUp()
                subSolarPoint.startUp()
            case .inactive:
                // The app has become inactive, so stop the timer
                issPosition.stop()
                subSolarPoint.stop()
            case .background:
                // The app has moved to the background
                issPosition.stop()
                subSolarPoint.stop()
            @unknown default:
                fatalError("The app has entered an unknown state.")
            }
        }
    }
}

struct SubSolarPointView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView()
        }
    }
}
