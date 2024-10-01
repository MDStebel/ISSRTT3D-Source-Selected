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
    
    /// Generalized crew filtering and sorting
    /// - Parameter station: Station
    /// - Returns: Sorted list of crews for each station, sorted by title by name
    private func filteredCrew(for station: Stations) -> [Crews.People] {
        viewModel.crews
            .filter { $0.location == station.rawValue }
            .sorted {
                if $0.title == $1.title {
                    return $0.name < $1.name
                } else {
                    return $0.title < $1.title
                }
            }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // ISS Section
                StationCrewView(crew: filteredCrew(for: .ISS), station: .ISS, colorKey: .ISSRTT3DRed)
                
                // Tiangong Section
                StationCrewView(crew: filteredCrew(for: .Tiangong), station: .Tiangong, colorKey: .ISSRTT3DGold)
                
                // Pop up an alert if there was an error fetching data
                    .alert(isPresented: $viewModel.wasError) {
                        Alert(title: Text(viewModel.errorForAlert?.title ?? "Oops!"),
                              message: Text(viewModel.errorForAlert?.message ?? "Unable to retrieve data.")
                        )
                    }
            }
            .navigationTitle("Crews").navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea(edges: .bottom)
        
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
