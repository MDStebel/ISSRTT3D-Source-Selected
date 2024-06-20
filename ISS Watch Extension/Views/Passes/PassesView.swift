//
//  PassesView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 6/5/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct PassesView: View {
    
    // Get the current phase of the scene
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var currentIndex: Int     = 0
    @State private var displayedText         = ""
    @State private var isAnimating           = false
    @State private var locationVm            = LocationViewModel()
    @State private var vm                    = PassesViewModel()

    var station: StationsAndSatellites
    
    private var sidebarColor: Color {
        switch station {
        case .iss:
            return .ISSRTT3DRed
        case .tss:
            return .ISSRTT3DGold
        case .hst:
            return .hubbleBlue
        default:
            return .ISSRTT3DRed
        }
    }
    
    var body: some View {
        ZStack {
            if vm.isComputing {
                progressIndicator
            } else {
                navigationContent
            }
        }
        .onAppear {
            if locationVm.authorizationStatus == .authorizedWhenInUse || locationVm.authorizationStatus == .authorizedAlways {
            vm.getPasses(for: station.satelliteNORADCode, latitude: locationVm.latitude, longitude: locationVm.longitude)
            }
        }
    }
    
    // MARK: - Views
    
    private var progressIndicator: some View {
        VStack {
            Spacer()
            let fullText = "Computing \(station.satelliteName) passes for your location over next 30 days."
            let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
            VStack(alignment: .leading) {
                Text(displayedText)
                    .font(.footnote)
                    .opacity(0.75)
                    .minimumScaleFactor(0.7)
                    .onReceive(timer) { _ in                // Animate the text one character at a time upon receiving updates from the timer we have set
                        if currentIndex < fullText.count {
                            let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                            displayedText.append(fullText[index])
                            currentIndex += 1
                        }
                    }
                    .onAppear {
                        displayedText = ""
                        currentIndex = 0
                }
            }
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center) // Scale the ProgressView
        }
    }
    
    private var navigationContent: some View {
        NavigationStack {
            List {
                ForEach(vm.predictedPasses, id: \.self) { pass in
                    NavigationLink(destination: PassDetailView(pass: pass)) {
                        passRow(for: pass)
                    }
                    .cornerRadius(10.0)
                    .frame(height: 50)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listItemTint(.ISSRTT3DBackground)
                }
            }
            .navigationTitle("\(station.satelliteName) Passes")
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func passRow(for pass: Passes.Pass) -> some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 6)
                .foregroundStyle(sidebarColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(Date(timeIntervalSince1970: pass.startUTC).formatted(date: .numeric, time: .shortened))
                    .font(.caption).fontWeight(.semibold)
                    .minimumScaleFactor(0.80)
                    .lineLimit(1)
                if station == .iss {
                    passQualityView(for: pass)
                } else {
                    noQualityAvailableView()
                }
            }
        }
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
    }
    
    /// Return 1-4 stars in a view based on the magnitude of the pass
    /// - Parameter pass: The pass
    /// - Returns: A view consisting of an HStack of stars
    private func passQualityView(for pass: Passes.Pass) -> some View {
        HStack(spacing: 3) {
            Text("Pass quality:")
                .font(.footnote).fontWeight(.regular)
                .opacity(0.7)
                .minimumScaleFactor(0.90)
                .lineLimit(1)
            HStack(spacing: 2) {
                ForEach(0..<4) { star in
                    Image(star < (vm.getNumberOfStars(forMagnitude: pass.mag) ?? 0) ? .icons8StarFilled : .starUnfilled)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                }
            }
        }
    }
    
    private func noQualityAvailableView() -> some View {
        HStack {
            Text("Pass quality N/A")
                .font(.footnote).fontWeight(.regular)
                .opacity(0.7)
                .minimumScaleFactor(0.90)
                .lineLimit(1)
        }
    }
}


#Preview {
    PassesView(station: .iss)
}
