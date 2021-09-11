//
//  SubSolarPointView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct SubSolarPointView: View {
    // Get the phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    // Get the subsolar point coordinates
    @ObservedObject private var subSolarPoint = SubSolarViewModel()
    
    var body: some View {
        ZStack {
            Image(systemName: "sun.max.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .opacity(0.60)
            VStack {
                HStack {
                    Text("Sun at the Zenith")
                        .foregroundColor(.gray)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text("LAT")
                        .foregroundColor(.ISSRTT3DRed)
                    Spacer()
                    Text(subSolarPoint.subsolarLatitude)
                        .bold()
                }
                HStack {
                    Text("LON")
                        .foregroundColor(.ISSRTT3DRed)
                    Spacer()
                    Text(subSolarPoint.subsolarLongitude)
                        .bold()
                }
            }
            .font(.custom(Theme.appFont, size: 15.0))
            .foregroundColor(.white)
            .frame(minWidth: 120, idealWidth: 150, maxWidth: .infinity, minHeight: 50, idealHeight: 60, maxHeight: 60, alignment: .center)
            .padding()
            .background(Color.ISSRTT3DBackground)
            .cornerRadius(5.0)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Subsolar")
        
        // Update the coordinates when this view appears
        .onAppear() {
            subSolarPoint.startUp()
        }
        
        // Stop updating when this view disappears
        .onDisappear() {
            subSolarPoint.stop()
        }
        
        // Respond to lifecycle phases
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // The scene has become active, so update the subsolar point
                subSolarPoint.startUp()
            case .inactive:
                // The app has become inactive, so stop the timer
                subSolarPoint.stop()
            case .background:
                // The app has moved to the background
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
            SubSolarPointView()
        }
    }
}
