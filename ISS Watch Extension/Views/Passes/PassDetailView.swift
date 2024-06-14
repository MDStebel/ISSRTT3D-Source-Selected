//
//  PassDetailView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 6/11/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct PassDetailView: View {
    
    var pass: Passes.Pass
    
    var body: some View {
        
        // Header info
        let dm = Date(timeIntervalSince1970: pass.startUTC).formatted(.dateTime.month(.abbreviated)) // Month
        let dw = Date(timeIntervalSince1970: pass.startUTC).formatted(.dateTime.weekday())           // Day of the week
        let dd = Date(timeIntervalSince1970: pass.startUTC).formatted(.dateTime.day())               // Day of the month
        let tm = getCountdownText()                                                                  // Minutes to pass start
        let du = pass.duration.formatted(.number) + " mins"
        let mg = pass.mag != RatingSystem.unknown.rawValue ? String(pass.mag) : "N/A"
        // Start
        let st = Date(timeIntervalSince1970: pass.startUTC).formatted(date: .omitted, time: .shortened)
        let sa = String(pass.startAz) + Globals.degreeSign
        let sc = String(pass.startAzCompass)
        let se = String(pass.startEl) + Globals.degreeSign
        // Max
        let mt = Date(timeIntervalSince1970: pass.maxUTC).formatted(date: .omitted, time: .shortened)
        let ma = String(pass.maxAz) + Globals.degreeSign
        let mc = String(pass.maxAzCompass)
        let me = String(pass.maxEl) + Globals.degreeSign
        // End
        let et = Date(timeIntervalSince1970: pass.endUTC).formatted(date: .omitted, time: .shortened)
        let ea = String(pass.endAz) + Globals.degreeSign
        let ec = String(pass.endAzCompass)
        let ee = String(pass.endEl) + Globals.degreeSign
        
        ZStack {
            Color.cyan.opacity(0.6)
                .ignoresSafeArea(edges: .all)
            
            ScrollView {
                
                VStack {
                    
                    DetailSubheading(heading: "General")
                    
                    StatView(label: "Date", stat: dw + ", " + dm + " " + dd)
                    StatView(label: "T-Minus", stat: tm)
                    StatView(label: "Duration", stat: du)
                    StatView(label: "Magnitude", stat: mg)
                    
                    DetailSubheading(heading: "Pass Start")
                    
                    StatView(label: "Time", stat: st)
                    StatView(label: "Azimuth", stat: sa)
                    StatView(label: "Compass", stat: sc)
                    StatView(label: "Elevation", stat: se)
                    
                    DetailSubheading(heading: "Max Viewing")
                    
                    StatView(label: "Time", stat: mt)
                    StatView(label: "Azimuth", stat: ma)
                    StatView(label: "Compass", stat: mc)
                    StatView(label: "Elevation", stat: me)
                    
                    DetailSubheading(heading: "Pass End")
                    
                    StatView(label: "Time", stat: et)
                    StatView(label: "Azimuth", stat: ea)
                    StatView(label: "Compass", stat: ec)
                    StatView(label: "Elevation", stat: ee)
                    
                }
                .padding(2)
            }
            .navigationTitle("Pass Viewing")
        }
    }
    
    // MARK: - Helper functions
    
    /// Compute time until the pass starts
    /// - Returns: Formatted string representation of the time remaining in mins
    private func getCountdownText() -> String {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: Date(timeIntervalSince1970: pass.startUTC))
        let diffInMinutes = (diff.day ?? 999) * 1440 + (diff.hour ?? 0) * 60 + (diff.minute ?? 0)
        return "\(diffInMinutes.formatted(.number)) mins"
    }
    
    /// Helper function to fetch image acsynchronously
    /// - Parameter url: The image URL
    /// - Returns: Image data
    private func loadImage(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    /// Helper method to calculate the number of days an astronaut has been in space (today - launch date).
    /// If there's an error in the data, this will detect it and return 0 days.
    /// - Returns: Number of days since launch.
    private func numberOfDaysInSpace(since launch: String) -> Int {
        
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Globals.outputDateFormatStringShortForm
        
        if launch != "" {
            let startDate = dateFormatter.date(from: launch)
            return Int(Float(todaysDate.timeIntervalSince(startDate!)) / Float(Globals.numberOfSecondsInADay ))
        } else {
            return 0
        }
    }
}


#Preview {
    PassDetailView(pass: Passes.Pass(startAz: 270, startAzCompass: "W", startEl: 20, startUTC: 1720659580.0, maxAz: 355, maxAzCompass: "NNE", maxEl: 50, maxUTC: 1720659585.0, endAz: 10, endAzCompass: "NNE", endEl: 25, endUTC: 1720659590.0, mag: -2.1, duration: 300))
}
