//
//  CrewRowView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 4/13/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

/// Custom row view for crew list
struct CrewRowView: View {
    
    let country: String
    let name: String
    let station: String
    let title: String
    let colorKey: Color
    
    var body: some View {
        HStack {
            Rectangle()                                             // Sidebar with color key indicator
                .frame(width: 6)
                .foregroundStyle(colorKey)
            VStack {
                HStack {
                    Text(name)
                        .withCoordinatesTextModifier
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(getFlag(for: country))
                    Text(title)
                        .withMDSDataLabelModifier
                        .opacity(0.7)
                    Spacer()
                }
            }
            .padding([.vertical], 1)
            .padding([.leading], 1)
            .padding([.trailing], 1)
        }
        .cornerRadius(10.0)
    }
    
    /// Helper method to get a flag emoji
    /// - Parameter country: String
    /// - Returns: Emoji as String or the country name
    private func getFlag(for country: String) -> String {
        Globals.countryFlags[country] ?? country.uppercased()
    }
}

#Preview {
    CrewRowView(country: "USA", name: "Joe Astro", station: "Tiangong", title: "Flight Engineer", colorKey: .ISSRTT3DRed)
}

