//
//  SubSolarPointView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021-2022 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    
    // Get the phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // Publisher we're observing for position data
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                DataCellView(title: "ISS Position",
                             altitude: vm.issAltitude,
                             altitudeInKm: vm.issAltitudeInKm,
                             altitudeInMi: vm.issAltitudeInMi,
                             latitude: vm.issFormattedLatitude,
                             longitude: vm.issFormattedLongitude,
                             sidebarColor: .ISSRTT3DRed
                )
                
                DataCellView(title: "Tiangong Position",
                             altitude: vm.tssAltitude,
                             altitudeInKm: vm.tssAltitudeInKm,
                             altitudeInMi: vm.tssAltitudeInMi,
                             latitude: vm.tssFormattedLatitude,
                             longitude: vm.tssFormattedLongitude,
                             sidebarColor: .ISSRTT3DGold
                )
                
                DataCellView(title: "Hubble Position",
                             altitude: vm.hubbleAltitude,
                             altitudeInKm: vm.hubbleAltitudeInKm,
                             altitudeInMi: vm.hubbleAltitudeInMi,
                             latitude: vm.hubbleFormattedLatitude,
                             longitude: vm.hubbleFormattedLongitude,
                             sidebarColor: .hubbleColor
                )
                
                DataCellView(title: "Subsolar Point",
                             altitude: nil,
                             altitudeInKm: nil,
                             altitudeInMi: nil,
                             latitude: vm.subsolarLatitude,
                             longitude: vm.subsolarLongitude,
                             sidebarColor: .subsolorColor
                )
                
                // Show version and copyright
                if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
                    Text("Version: \(versionNumber)  Build: \(buildNumber)\(Globals.newLine)\(copyright)")
                        .font(.system(size: 10, weight: .regular))
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
    
    private func start() {
        vm.start()
    }
    
    private func stop() {
        vm.stop()
    }
    
    private func getAppCurrentVersion() -> (version: String, build: String, copyright: String)? {
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let currentBuild   = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let copyright      = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as! String
        
        return (currentVersion, currentBuild, copyright)
        
    }
    
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView(vm: ViewModel())
        }
    }
}
