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
    @StateObject private var subSolarPoint = SubSolarViewModel()
    
    var body: some View {
        ZStack {
            Image(systemName: "sun.max.fill")
                .resizable()
                .scaledToFit()
                //                    .rotationEffect(.degrees(22.5))
                .foregroundColor(.yellow)
                .opacity(0.6)
            VStack {
                Spacer()
                Text(subSolarPoint.subSolarPointString)
                    .font(.custom(Theme.nasa, size: 16.0))
                    .fontWeight(.regular)
                    .bold()
                Text("Tap to update")
                    .font(.custom(Theme.appFont, size: 10.0))
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Details")
        }
        
        // Update the coordinates when this view appears
        .onAppear() {
            subSolarPoint.updateSubSolarPoint()
        }
        // Respond to lifecycle phases
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // The scene has become active, so update the subsolar point
                subSolarPoint.updateSubSolarPoint()
            case .inactive:
                // The app has become inactive.
                break
            case .background:
                // The app has moved to the background.
                break
            @unknown default:
                fatalError("The app has entered an unknown state.")
            }
        }
        // Update the coordinates when the watch screen is tapped
        .onTapGesture {
            subSolarPoint.updateSubSolarPoint()
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
