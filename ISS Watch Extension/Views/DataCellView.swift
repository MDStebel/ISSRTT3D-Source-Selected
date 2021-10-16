//
//  DataCellView.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 9/17/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

/// Custom cell view for coordinates data
struct DataCellView: View {
    
    let title: String
    let altitude: Float?
    let altitudeInKm: String?
    let altitudeInMi: String?
    let latitude: String
    let longitude: String
    let sidebarColor: Color
    
    private let max: Float        = Globals.hubbleAltitudeInKM        // Scale max
    private let min: Float        = Globals.TSSAltitudeInKM           // Scale min
    private let multiplier: Float = 20
    
    var body: some View {
        HStack {
            
            Rectangle()                             // Sidebar with color indicator
                .frame(width: 6)
                .foregroundColor(sidebarColor)
            
            VStack {
                
                HStack {                            // Title
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                Spacer()
                
                // MARK: - Data area
                HStack {
                    
                    // MARK: - Conditional view
                    // Only show the altitude indicator if there's an altitude available
                    // If not, we'll assume we're showing the subsolar point, so show the Sun
                    if let altKm = altitudeInKm, let altMi = altitudeInMi, let alt = altitude {
                        
                        let range             = max - min                   // Scale range
                        let boundedAlt        = fmin(fmax(alt, min), max)   // Keep within scale range
                        let normalizedAlt     = (boundedAlt - min) / range
                        let yOffsetComputed   = -CGFloat(normalizedAlt * multiplier) + 6
                        
                        // Show the altitude scale
                        Image("Y-Axis")
                            .offset(x: -4, y: -4)
                        
                        // Movable indicator with values
                        HStack(spacing: -4) {
                            
                            Image(systemName: "arrowtriangle.left.fill")
                                .resizable()
                                .frame(width: 7, height: 6)
                                .foregroundColor(sidebarColor)
                                .offset(x: -7.5)
                            
                            VStack(alignment: .leading, spacing: -3) {
                                
                                Text("ALT")
                                    .bold()
                                    .withMDSDataLabelModifier
                                Text(altKm)
                                    .font(.custom(Theme.appFont, size: 10.0))
                                    .foregroundColor(.white)
                                    .bold()
                                    .lineLimit(1)
                                Text(altMi)
                                    .font(.custom(Theme.appFont, size: 10.0))
                                    .foregroundColor(.white)
                                    .bold()
                                    .lineLimit(1)
                                
                            }
                            .offset(x: -3, y: 1.0)
                            
                        }
                        .offset(y: yOffsetComputed) // This will position the alt on the scale
                        
                        // Show the Sun icon if this is not a satellite
                    } else {
                        
                        Image(systemName: "sun.max.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .offset(x: 1, y: -5)
                            .frame(width: 40, height: 40, alignment: .leading)
                        
                    }
                    
                    // MARK: - Coordinates area
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text(latitude)
                                .bold()
                                .minimumScaleFactor(0.9)
                                .font(.custom(Theme.appFont, size: 15))
                        }
                        .offset(x: 0)
                        
                        HStack {
                            Spacer()
                            Text(longitude)
                                .bold()
                                .minimumScaleFactor(0.9)
                                .font(.custom(Theme.appFont, size: 15))
                        }
                        .offset(x: 0)
                        
                    }
                    
                }
                
            }
            .padding([.vertical], 2)
            .padding([.leading], 1)
            .padding([.trailing], 6)
        }
        .frame(height: 70)
        .background(Color.ISSRTT3DBackground)
        .cornerRadius(5.0)
    }
    
}


struct DataCellView_Previews: PreviewProvider {
    static var previews: some View {
        DataCellView(title: "Title", altitude: 435, altitudeInKm: "400 km", altitudeInMi: "249 mi", latitude: "155°55'55\"N", longitude: "177°48'48\"E", sidebarColor: .blue)
    }
}
