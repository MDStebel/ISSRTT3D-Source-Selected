//
//  ISS_Real_Time_Tracker_3D_Widget.swift
//  ISS Real-Time Tracker 3D Widget
//
//  Created by Michael Stebel on 5/17/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import CoreLocation
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NextPass {
        NextPass(date: Date(), passDate: Date(), startAzimuth: 216.0, startAzCompass: "SW", startElevation: 18.0, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0, endElevation: 20.0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextPass) -> ()) {
        Task {
            if let apiData = await fetchData() {
                let pass = apiData.passes[0]
                let passStartDate = Date(timeIntervalSince1970: Double(pass.startUTC))
                let currentDate = Date()
                let entry = NextPass(date: currentDate, passDate: passStartDate, startAzimuth: pass.startAz, startAzCompass: pass.startAzCompass, startElevation: pass.startEl, maxAzimuth: pass.maxAz, maxElevation: pass.maxEl, endAzimuth: pass.endAz, endElevation: pass.endEl)
                
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextPass>) -> ()) {
        Task {
            var entries: [NextPass] = []
            if let apiData = await fetchData() {
                let pass = apiData.passes[0]
                let passStartDate = Date(timeIntervalSince1970: Double(pass.startUTC))
                let currentDate = Date()
                let entry = NextPass(date: currentDate, passDate: passStartDate, startAzimuth: pass.startAz, startAzCompass: pass.startAzCompass, startElevation: pass.startEl, maxAzimuth: pass.maxAz, maxElevation: pass.maxEl, endAzimuth: pass.endAz, endElevation: pass.endEl)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    /// Get the next pass
    /// - Returns: An arrray of Passes
    private func fetchData() async -> Passes? {
        let altitude             = 0
        let apiKey               = ApiKeys.passesApiKey
        let endpointForPassesAPI = ApiEndpoints.passesAPIEndpoint
        let minObservationTime   = 300
        let numberOfDays         = 30
        let stationID            = StationsAndSatellites.iss.satelliteNORADCode
        
        // Get user's coordinates
        let coordinates = getUserCoordinates()
        if let userLatitude = coordinates.latitude, let userLongitude = coordinates.longitude {
            
            // Create the API URL request from endpoint. If not succesful, then return
            let URLrequestString = endpointForPassesAPI + "\(stationID)/\(userLatitude)/\(userLongitude)/\(altitude)/\(numberOfDays)/\(minObservationTime)/&apiKey=\(apiKey)"
            guard let url = URL(string: URLrequestString) else {
                return nil
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let apiData = try decoder.decode(Passes.self, from: data)
                return apiData
            } catch {
                print("Error getting passes: \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Get user's coordinates
    /// - Returns: A tuple containing the lat and lon.
    private func getUserCoordinates() -> (latitude: Double?, longitude: Double?) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let lat = locationManager.location?.coordinate.latitude
        let lon = locationManager.location?.coordinate.longitude
        
        return (lat, lon)
    }
}

/// Simplfied pass model
struct NextPass: TimelineEntry {
    var date: Date
    let passDate: Date
    let startAzimuth: Double
    let startAzCompass: String
    let startElevation: Double
    let maxAzimuth: Double
    let maxElevation: Double
    let endAzimuth: Double
    let endElevation: Double
}

/// Widget view
struct ISS_Real_Time_Tracker_3D_WidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            ContainerView()
            VStack(spacing: 5) {
                HeaderView()
                Spacer()
                DateView(date: entry.passDate)
                Spacer()
                InfoCardView(entry: entry)
                    .offset(y: -45)
            }
        }
    }
}

struct ContainerView: View {
    var body: some View {
        ContainerRelativeShape()
            .fill(Color.issrttRed)
            .overlay(
                LinearGradient(
                    colors: [Color.issrttRed, Color.issrttWhite],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.25)
            )
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Next ISS Pass")
                .font(.caption).bold()
                .foregroundColor(.white)
            Spacer()
            Image(.issrttNewIconWhite)
        }
        .padding()
        .offset(y: 40)
    }
}

struct DateView: View {
    var date: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(.caption).fontWeight(.heavy)
                    .opacity(0.60)
                    .offset(y: 20)
                Spacer()
                Text("\(date.formatted(.dateTime.month(.abbreviated)).uppercased()) \(date.formatted(.dateTime.day()))")
                    .font(.largeTitle).fontWeight(.black)
                Spacer()
            }
            .foregroundColor(.issrttWhite)
            .offset(x: 16)
            Spacer()
        }
    }
}

struct InfoCardView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let date = Text("\(entry.passDate.formatted(date: .omitted, time: .shortened))")
        let azi = Text("\(entry.startAzimuth, format: .number.precision(.fractionLength(0)))°")
        let elev = Text("\(entry.startElevation, format: .number.precision(.fractionLength(1)))°")

        let tmLabel = family == .systemMedium ? "  Start Time:  " : " Tm: "
        let azLabel = family == .systemMedium ? "  Azimuth:  " : " Az: "
        let elLabel = family == .systemMedium ? " Elevation:  " : "El: "
        let spacing = family == .systemMedium ? 5.0 : 0.0
        
        ZStack {
            Rectangle()
                .foregroundColor(.issrttWhite)
                .cornerRadius(5)
                .frame(maxWidth: .infinity, maxHeight: 50)
            VStack(alignment: .leading, spacing: 0) {
                InfoRow(icon: "clock", label: tmLabel, value: date, spacing: spacing)
                InfoRow(icon: "safari", label: azLabel, value: azi + Text(" ") + Text(entry.startAzCompass), spacing: spacing)
                InfoRow(icon: "angle", label: elLabel, value: elev, spacing: spacing)
            }
            .foregroundColor(.issrttRed)
            .padding(.horizontal, 5)
        }
        .padding()
    }
}

struct InfoRow: View {
    var icon: String
    var label: String
    var value: Text
    var spacing: CGFloat
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: icon)
                .font(.caption).fontWeight(.bold)
            Text(label)
                .font(.caption).fontWeight(.black)
            value
                .font(.caption).fontWeight(.semibold)
            Spacer()
        }
        .offset(x: spacing * 10)
    }
}

struct ISS_Real_Time_Tracker_3D_Widget: Widget {
    let kind: String = "ISS_Real_Time_Tracker_3D_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ISS_Real_Time_Tracker_3D_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("ISSRTT3D Widget")
        .description("Displays the next ISS pass for your location.")
    }
}

#Preview(as: .systemSmall) {
    ISS_Real_Time_Tracker_3D_Widget()
} timeline: {
    NextPass(date: Date(), passDate: Date(), startAzimuth: 216.3, startAzCompass: "SW", startElevation: 18.7, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0, endElevation: 20.0)
    NextPass(date: Date(), passDate: Date(), startAzimuth: 350, startAzCompass: "NNW", startElevation: 22, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0, endElevation: 20.0)
}