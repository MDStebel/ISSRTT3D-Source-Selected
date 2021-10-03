//
//  DataCellView.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 9/17/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

/// Custom cell view
struct DataCellView: View {
    
    let title: String
    let altValue: Float?
    let altitude: String?
    let latitude: String
    let longitude: String
    let sidebarColor: Color
    
    var body: some View {
        HStack {
            
            Rectangle()                             // Sidebar with color indicator
                .frame(width: 6)
                .foregroundColor(sidebarColor)
            
            VStack {                                // Coordinates data here
                HStack {                            // Title
                    Spacer()
                    Text(title)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack {
                    
                    // Only show the altitude indicator if there's an altitude available
                    if let alt = altValue, let altFormatted = altitude {
                        
                        // Simulate a sliding scale using a Y offset computed from the normalized actual alititude in km
                        // Otherwise, assume we're showing the subsolar point, so show an image of the Sun.
                        let computedYOffset = -CGFloat(14.0 + (alt - 410) / 2.0)
                        
                        HStack {
                            Image(systemName: "arrowtriangle.left.fill")
                                .resizable()
                                .frame(width: 9, height: 6)
                                .foregroundColor(sidebarColor)
                                .offset(x: -5)
                            
                            VStack(alignment: .leading) {
                                Text("ALT")
                                    .bold()
                                    .withMDSDataLabelModifier
                                Text(altFormatted)
                                    .font(.custom(Theme.appFont, size: 8.0))
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                            }
                            .offset(x: -6)
                        }
                        .offset(y: computedYOffset)
                        
                    } else {
                        
                        Image(systemName: "sun.max.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .offset(y: -13)
                        
                    }
                    
                    VStack {
                        
                        HStack (alignment: .firstTextBaseline) {
                            HStack {
                                Spacer()
                                Text(latitude)
                                    .font(.custom(Theme.appFont, size: 12))
                                    .fontWeight(.semibold)
                            }
                            .offset(x: -2)
                            Text("LAT")
                                .bold()
                                .withMDSDataLabelModifier
                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            HStack {
                                Spacer()
                                Text(longitude)
                                    .font(.custom(Theme.appFont, size: 12))
                                    .fontWeight(.semibold)
                            }
                            Text("LON")
                                .bold()
                                .withMDSDataLabelModifier
                        }
                    }
                }
            }
            .padding([.vertical], 2)
            .padding([.leading], 1)
            .padding([.trailing], 6)
        }
        .frame(height: 69)
        .background(Color.ISSRTT3DBackground)
        .cornerRadius(5.0)
    }
}

struct DataCellView_Previews: PreviewProvider {
    static var previews: some View {
        DataCellView(title: "Title", altValue: 400, altitude: "400 km\n(250 mi)", latitude: "50°39.73′N", longitude: "150°39.73′N", sidebarColor: .blue)
    }
}
