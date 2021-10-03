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
        
        let issAltitude            = issPosition.altitude
        let issAltitudeFormatted   = issPosition.formattedAltitude
        let issLatitudeFormatted   = issPosition.formattedLatitude
        let issLongitudeFormatted  = issPosition.formattedLongitude
        
        let tssAltitude            = tssPosition.altitude
        let tssAltitudeFormatted   = tssPosition.formattedAltitude
        let tssLatitudeFormatted   = tssPosition.formattedLatitude
        let tssLongitudeFormatted  = tssPosition.formattedLongitude
        
        let subsolarPointLatitude  = subSolarPoint.subsolarLatitude
        let subsolarPointLongitude = subSolarPoint.subsolarLongitude
        
        ScrollView {
            
            VStack {
                
                DataCellView(title: "ISS Position",
                             altValue: issAltitude,
                             altitude: issAltitudeFormatted,
                             latitude: issLatitudeFormatted,
                             longitude: issLongitudeFormatted,
                             sidebarColor: .ISSRTT3DRed)
                
                DataCellView(title: "TSS Position",
                             altValue: tssAltitude,
                             altitude: tssAltitudeFormatted,
                             latitude: tssLatitudeFormatted,
                             longitude: tssLongitudeFormatted,
                             sidebarColor: .ISSRTT3DGold)
                
                DataCellView(title: "Subsolar Point",
                             altValue: nil,
                             altitude: nil,
                             latitude: subsolarPointLatitude,
                             longitude: subsolarPointLongitude,
                             sidebarColor: .white)
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
