//
//  CrewStatView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/29/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI


/// Custom view for a stats line with a label and the stat
struct CrewStatView: View {

    var label: String
    var stat: String

    var body: some View {
        
        HStack {
            Text("\(label): ").bold() + Text("\(stat)")
                .font(.caption)
                .foregroundColor(.white.opacity(1.0))
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}


#Preview {
    CrewStatView(label: "Name", stat: "Tom Jones")
}
