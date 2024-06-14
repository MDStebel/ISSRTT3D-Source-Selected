//
//  StatView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 4/29/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI


/// Custom view for a line of stats with a label and the stat itself on a single line
struct StatView: View {

    var label: String
    var stat: String

    var body: some View {
        
        HStack(alignment: .top) {
            Text("\(label): ")
                .font(.caption)
                .fontWeight(.bold)
            Text("\(stat)")
                .font(.caption)
                .foregroundColor(.white.opacity(1.0))
                .minimumScaleFactor(0.6)
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}


#Preview {
    StatView(label: "Name", stat: "Tom Jones")
}
