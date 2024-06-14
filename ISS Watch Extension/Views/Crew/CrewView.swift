//
//  CrewView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 4/13/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct CrewView: View {
    
    // Get the current phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var viewModel = CrewViewModel()
    
    private var crews = [Crews.People]()
    
    private var issCrewFiltered: [Crews.People] {
        let list = viewModel.crews.filter { $0.location == Stations.ISS.rawValue }
        return list.sorted { $0.name < $1.name }
    }
    
    private var tiangongCrewFiltered: [Crews.People] {
        let list = viewModel.crews.filter { $0.location == Stations.Tiangong.rawValue }
        return list.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        
        NavigationStack {
            
            List {
                
                // ISS Section
                StationCrewView(crew: issCrewFiltered, station: .ISS, colorKey: .ISSRTT3DRed)
                
                // Tiangong Section
                StationCrewView(crew: tiangongCrewFiltered, station: .Tiangong, colorKey: .ISSRTT3DGold)
                
                // Pop up an alert if there was an error fetching data
                    .alert(isPresented: $viewModel.wasError) {
                        Alert(title: Text(viewModel.errorForAlert?.title ?? "Oops!"),
                              message: Text(viewModel.errorForAlert?.message ?? "Can't get data.")
                        )
                    }
            }
            .navigationTitle("Crews").navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea(edges: .bottom)

//        .onAppear() {
//            viewModel.start()
//        }
        
        // Respond to lifecycle phases
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                // The scene has become active, so start updating
                viewModel.start()
            case .inactive:
                // The app has become inactive, so stop updating
                break
            case .background:
                // The app has moved to the background, so stop updating
                viewModel.stop()
            @unknown default:
                fatalError("The app has entered an unknown state.")
            }
        }
    }
}


#Preview {
    CrewView()
}
