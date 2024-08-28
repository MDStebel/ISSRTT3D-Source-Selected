//
//  SubsolarPointDetails.swift
//  ISS Watch
//
//  Created by Michael Stebel on 6/12/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct SubsolarPointDetails: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            gradientBackground(with: [.issrttRed, .ISSRTT3DGrey])
            ScrollView {
                VStack {
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.yellow)
                        .scaleEffect(isAnimating ? 1.25 : 0.75)  // Adjust scale for animation
                        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear {
                            isAnimating = true
                        }
                    Text(
                         """
                         The subsolar point is the location on a planet or celestial body’s surface where its sun is perceived to be directly overhead at a given moment. This means its sun’s rays are hitting the surface at a 90-degree angle, and it is the point on the surface that receives the most direct sunlight. For Earth, the subsolar point moves across the surface as the Earth rotates and orbits the Sun, and it is always located somewhere between the Tropic of Cancer and the Tropic of Capricorn, depending on the time of year.
                         """
                    )
                    .font(.caption2)
                    .opacity(1.0)
                    .minimumScaleFactor(0.7)
                    .padding()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SubsolarPointDetails()
}
