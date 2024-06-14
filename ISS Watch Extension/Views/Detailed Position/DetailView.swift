//
//  DetailView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    
    // Get the phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // Publisher we're observing for position data
    @ObservedObject var vm: PositionViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                navigationLinks
                versionInfo
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(1)
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Live Positions")
        .onAppear { start() }
        .onChange(of: scenePhase) { _, phase in
            handleScenePhaseChange(phase)
        }
    }
    
    // MARK: - Views
    
    private var navigationLinks: some View {
        Group {
            navigationLink(destination: PassesView(station: .iss), title: "ISS Position", altitude: vm.issAltitude, altitudeInKm: vm.issAltitudeInKm, altitudeInMi: vm.issAltitudeInMi, latitude: vm.issFormattedLatitude, longitude: vm.issFormattedLongitude, sidebarColor: Color.ISSRTT3DRed, target: .iss)
            
            navigationLink(destination: PassesView(station: .tss), title: "Tiangong Position", altitude: vm.tssAltitude, altitudeInKm: vm.tssAltitudeInKm, altitudeInMi: vm.tssAltitudeInMi, latitude: vm.tssFormattedLatitude, longitude: vm.tssFormattedLongitude, sidebarColor: .ISSRTT3DGold, target: .tss)
            
            navigationLink(destination: PassesView(station: .hst), title: "Hubble Position", altitude: vm.hubbleAltitude, altitudeInKm: vm.hubbleAltitudeInKm, altitudeInMi: vm.hubbleAltitudeInMi, latitude: vm.hubbleFormattedLatitude, longitude: vm.hubbleFormattedLongitude, sidebarColor: .hubbleColor, target: .hst)
            
            navigationLink(destination: SubsolarPointDetails(), title: "Subsolar Point", altitude: nil, altitudeInKm: nil, altitudeInMi: nil, latitude: vm.subsolarLatitude, longitude: vm.subsolarLongitude, sidebarColor: .subsolorColor, target: .none)
        }
    }
    
    private func navigationLink(destination: some View, title: String, altitude: Float?, altitudeInKm: String?, altitudeInMi: String?, latitude: String, longitude: String, sidebarColor: Color, target: StationsAndSatellites) -> some View {
        NavigationLink(destination: destination) {
            DataCellView(
                title: title,
                altitude: altitude,
                altitudeInKm: altitudeInKm,
                altitudeInMi: altitudeInMi,
                latitude: latitude,
                longitude: longitude,
                sidebarColor: sidebarColor,
                target: target
            )
        }
    }
    
    private var versionInfo: some View {
        if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
            return AnyView(
                Text("Version: \(versionNumber)  Build: \(buildNumber)\(Globals.newLine)\(copyright)")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.vertical)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // MARK: - Methods
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            start()
        case .inactive, .background:
            stop()
        @unknown default:
            fatalError("The app has entered an unknown state.")
        }
    }
    
    private func start() {
        vm.start()
    }
    
    private func stop() {
        vm.stop()
    }
    
    private func getAppCurrentVersion() -> (version: String, build: String, copyright: String)? {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let copyright      = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String
        
        if let version = currentVersion, let build = currentBuild, let copyright = copyright {
            return (version, build, copyright)
        }
        return nil
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView(vm: PositionViewModel())
        }
    }
}
