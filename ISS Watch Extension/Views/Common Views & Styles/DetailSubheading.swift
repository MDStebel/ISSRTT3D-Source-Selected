//
//  DetailSubheading.swift
//  ISS Watch
//
//  Created by Michael Stebel on 5/1/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

/// Displays heading for detail view
struct DetailSubheading: View {
    
    var heading: String
    
    var body: some View {
        Text(heading)
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.5))
            .textCase(.uppercase)
            .bold()
            .padding(EdgeInsets(top: 3, leading: 2, bottom: 1, trailing: 2))
    }
}

#Preview {
    DetailSubheading(heading: "Stuff")
}
