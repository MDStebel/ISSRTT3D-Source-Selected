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
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    
                    // Only show the altitude indicator if there's an altitude available
                    // If not, we'll assume we're showing the subsolar point, so show the Sun
                    if let alt = altitude {
                        
                        HStack {
//                            Image(systemName: "arrowtriangle.left.fill")
//                                .resizable()
//                                .frame(width: 9, height: 6)
//                                .foregroundColor(sidebarColor)
//                                .offset(x: -5)
                            
                            VStack(alignment: .leading) {
                                Text("ALT")
                                    .bold()
                                    .withMDSDataLabelModifier
                                Text(alt)
                                    .font(.custom(Theme.appFont, size: 9.0))
                                    .foregroundColor(.white)
                                    .bold()
                                    .lineLimit(2)
                            }
                            .offset(y: -1)
                        }
                        
                    } else {
                        
                        Image(systemName: "sun.max.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .offset(y: -2)
                    }
                    
                    VStack {
                        
                        HStack (alignment: .firstTextBaseline) {
                            HStack {
                                Spacer()
                                Text(latitude)
                                    .font(.custom(Theme.appFont, size: 13))
                                    .bold()
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
                                    .font(.custom(Theme.appFont, size: 13))
                                    .bold()
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
        .frame(height: 62)
        .background(Color.ISSRTT3DBackground)
        .cornerRadius(5.0)
    }
}

struct DataCellView_Previews: PreviewProvider {
    static var previews: some View {
        DataCellView(title: "Title", altitude: "400 km\n(250 mi)", latitude: "test", longitude: "test", sidebarColor: .blue)
    }
}
