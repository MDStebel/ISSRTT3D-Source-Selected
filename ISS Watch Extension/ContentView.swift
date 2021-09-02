//
//  ContentView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    // Get the subsolar point coordinates
    @State private var subsolarPoint = AstroCalculations.getSubSolarCoordinates()
    
    var body: some View {
        LazyVStack(spacing: 10) {
            // Convert decimal coordinates to degrees, minutes format
            let coordinatesString = CoordinateConversions.decimalCoordinatesToDegMin(latitude: Double(subsolarPoint.latitude), longitude: Double(subsolarPoint.longitude), format: Globals.coordinatesStringFormatShortForm)
            
            Text("Subsolar Point")
                .font(.custom(Theme.nasa, size: 15.0))
                .foregroundColor(.ISSRTT3DRed)
                .padding()
            Divider()
            Text(coordinatesString)
                .font(.custom(Theme.appFontBold, size: 14.0))
            Divider()
            Text("Tap to update")
                .font(.custom(Theme.appFont, size: 10.0))
                .foregroundColor(.gray)
                .padding()
        }
        .multilineTextAlignment(.center)
        // Update the coordinates when the watch screen is tapped
        .onTapGesture {
            subsolarPoint = AstroCalculations.getSubSolarCoordinates()
        }
    }
    
}
    

extension Color {
    // Add global ISSRTT3D theme colors
    static let ISSRTT3DRed = Color(Theme.tint)
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

