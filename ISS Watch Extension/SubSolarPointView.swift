//
//  ContentView.swift
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
    @State private var subsolarPoint = AstroCalculations.getSubSolarCoordinates()
    
    var body: some View {
        
        // Convert decimal coordinates to degrees, minutes format
        let coordinatesString = CoordinateConversions.decimalCoordinatesToDegMin(latitude: Double(subsolarPoint.latitude), longitude: Double(subsolarPoint.longitude), format: Globals.coordinatesStringFormatShortForm)
        
        VStack(spacing: 10) {
            Text("Subsolar Point")
                .font(.ISSRTT3DFont)
                .foregroundColor(.ISSRTT3DRed)
                .padding()
            Divider()
            Text(coordinatesString)
                .font(.custom(Theme.appFontBold, size: 14.0))
                // Detect change in phase of the scene
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        // The scene has become active, so update the subsolar point
                        subsolarPoint = AstroCalculations.getSubSolarCoordinates()
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
            Divider()
            Spacer()
            Text("Tap to update")
                .font(.custom(Theme.appFont, size: 10.0))
                .foregroundColor(.ISSRTT3DGrey)
                .padding()
        }
        .multilineTextAlignment(.center)
        
        // Update the coordinates when the watch screen is tapped
        .onTapGesture {
            subsolarPoint = AstroCalculations.getSubSolarCoordinates()
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SubSolarPointView()
        }
    }
}
