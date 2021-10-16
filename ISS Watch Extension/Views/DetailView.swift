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
    
    //    // Get the phase of the scene
    //    @Environment(\.scenePhase) private var scenePhase
    
    // Publishers we're observing for updated position data
    @StateObject private var issPosition    = SatellitePositionViewModel(satellite: .iss)
    @StateObject private var tssPosition    = SatellitePositionViewModel(satellite: .tss)
    @StateObject private var hubblePosition = SatellitePositionViewModel(satellite: .hubble)
    @StateObject private var subSolarPoint  = SubSolarViewModel()
    
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
                
                DataCellView(title: "Hubble Position",
                             altitude: hubblePosition.altitude,
                             altitudeInKm: hubblePosition.altitudeInKm,
                             altitudeInMi: hubblePosition.altitudeInMi,
                             latitude: hubblePosition.formattedLatitude,
                             longitude: hubblePosition.formattedLongitude,
                             sidebarColor: .hubbleColor
                )
                
                DataCellView(title: "Subsolar Point",
                             altitude: nil,
                             altitudeInKm: nil,
                             altitudeInMi: nil,
                             latitude: subSolarPoint.subsolarLatitude,
                             longitude: subSolarPoint.subsolarLongitude,
                             sidebarColor: .subsolorColor
                )
                
                // Show version and copyright
                if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
                    Text("Version: \(versionNumber)  Build: \(buildNumber)\(Globals.newLine)\(copyright)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.vertical)
                }
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
        
        //        // Respond to lifecycle phases
        //        .onChange(of: scenePhase) { phase in
        //            switch phase {
        //            case .active:
        //                // The scene has become active, so start updating
        //                start()
        //            case .inactive:
        //                // The app has become inactive, so stop updating
        //                stop()
        //            case .background:
        //                // The app has moved to the background, so stop updating
        //                stop()
        //            @unknown default:
        //                fatalError("The app has entered an unknown state.")
        //            }
        //        }
        
    }
    
    private func start() {
        issPosition.startUp()
        tssPosition.startUp()
        hubblePosition.startUp()
        subSolarPoint.startUp()
    }
    
    private func stop() {
        issPosition.stop()
        tssPosition.stop()
        hubblePosition.stop()
        subSolarPoint.stop()
    }
    
    private func getAppCurrentVersion() -> (version: String, build: String, copyright: String)? {
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let currentBuild   = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let copyright      = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as! String
        
        return (currentVersion, currentBuild, copyright)
        
    }
    
}


struct SubSolarPointView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView()
        }
    }
}
