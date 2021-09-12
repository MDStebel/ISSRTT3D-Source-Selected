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
    @StateObject private var issPosition   = ISSPositionViewModel()
    @StateObject private var subSolarPoint = SubSolarViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                
                DataCellView(title: "ISS Position",
                             latitude: issPosition.issLatitude,
                             longitude: issPosition.issLongitude)
                
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

/// Custom cell view
struct DataCellView: View {
    
    let title: String
    let latitude: String
    let longitude: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
            HStack (alignment: .top) {
                HStack {
                    Spacer()
                    Text(latitude)
                        .font(.custom(Theme.appFont, size: 17))
                        .bold()
                }
                Text("LAT")
                    .font(.subheadline)
                    .foregroundColor(.ISSRTT3DRed)
                    .bold()
            }
            HStack(alignment: .top) {
                HStack {
                    Spacer()
                    Text(longitude)
                        .font(.custom(Theme.appFont, size: 17))
                        .bold()
                }
                Text("LON")
                    .font(.subheadline)
                    .foregroundColor(.ISSRTT3DRed)
                    .bold()
            }
        }
        .padding()
        .background(Color.ISSRTT3DBackground)
        .cornerRadius(5.0)
    }
}

struct SubSolarPointView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView()
        }
    }
}
