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

// MARK: - Timeline provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NextPass {
        NextPass(date: Date(), passDate: Date(), duration: 399, mag: 1.8, startAzimuth: 216.0, startAzCompass: "SW", startElevation: 18.0, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextPass) -> ()) {
        Task {
            if let apiData = await fetchData() {
                let pass = apiData.passes[0]
                let passStartDate = Date(timeIntervalSince1970: pass.startUTC)
                let currentDate = Date()
                let entry = NextPass(date: currentDate, passDate: passStartDate, duration: pass.duration, mag: pass.mag, startAzimuth: pass.startAz, startAzCompass: pass.startAzCompass, startElevation: pass.startEl, maxAzimuth: pass.maxAz, maxElevation: pass.maxEl, endAzimuth: pass.endAz)
                
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextPass>) -> ()) {
        Task {
            var entries: [NextPass] = []
            if let apiData = await fetchData() {
                let pass = apiData.passes[0]
                let passStartDate = Date(timeIntervalSince1970: pass.startUTC)
                let currentDate = Date()
                for minuteOffset in 0 ..< 5 {
                    let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
                    let entry = NextPass(date: entryDate, passDate: passStartDate, duration: pass.duration, mag: pass.mag, startAzimuth: pass.startAz, startAzCompass: pass.startAzCompass, startElevation: pass.startEl, maxAzimuth: pass.maxAz, maxElevation: pass.maxEl, endAzimuth: pass.endAz)
                    entries.append(entry)
                }
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
            // Create the API URL request from endpoint. If not succesful, then return
        let URLrequestString = endpointForPassesAPI + "\(stationID)/\(coordinates.latitude)/\(coordinates.longitude)/\(altitude)/\(numberOfDays)/\(minObservationTime)/&apiKey=\(apiKey)"
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
    }
    
    /// Get user's coordinates from the app group data store
    /// - Returns: A tuple containing the lat and lon.
    private func getUserCoordinates() -> (latitude: Double, longitude: Double) {
        let sharedDefaults = UserDefaults(suiteName: Globals.appSuiteName)
        let latitude = sharedDefaults?.double(forKey: "latitude") ?? 0.0
        let longitude = sharedDefaults?.double(forKey: "longitude") ?? 0.0
        return (latitude, longitude)
    }
}

/// Simplfied pass model
struct NextPass: TimelineEntry {
    var date: Date
    let passDate: Date
    let duration: Int
    let mag: Double
    let startAzimuth: Double
    let startAzCompass: String
    let startElevation: Double
    let maxAzimuth: Double
    let maxElevation: Double
    let endAzimuth: Double
}

// MARK: - View

/// Widget view
struct ISS_Real_Time_Tracker_3D_WidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .fill(.black)
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Image(.issrttNewIconWhite)
                    Text("\(entry.passDate.formatted(.dateTime.month(.abbreviated)).uppercased()) \(entry.passDate.formatted(.dateTime.day()))")
                        .font(.subheadline).fontWidth(.condensed).fontWeight(.bold)
                        .minimumScaleFactor(0.90)
                    Text("\(entry.passDate.formatted(date: .omitted, time: .shortened))")
                        .font(.caption).fontWidth(.condensed)
                        .minimumScaleFactor(0.90)
                    Spacer()
                }
            }
        default:
            ZStack {
                ContainerView()
                VStack(spacing: family == .systemMedium ? 3 : 5) {
                    HeaderView()
                    Spacer()
                    DateView(date: entry.passDate, entry: entry)
                    Spacer()
                    InfoCardView(entry: entry)
                        .offset(y: -45)
                }
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
                    colors: [.issrttRed, .issrttRed, .issrttWhite],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.35)
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
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            smallView()
        case .systemMedium:
            mediumView(with: entry)
        default:
            smallView()
        }
    }
    
    @ViewBuilder
    private func smallView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                dateText
                Spacer()
                monthDayText
                Spacer(minLength: 10)
            }
            .minimumScaleFactor(0.90)
            .foregroundColor(.issrttWhite)
            .offset(x: 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func mediumView(with data: Provider.Entry) -> some View {
        let mag = data.mag
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                dateText
                Spacer()
                monthDayText
                Spacer(minLength: 15)
            }
            VStack(alignment: .leading, spacing: 3) {
                Spacer(minLength: 25)
                VStack(alignment: .leading, spacing: -45) {
                    passQualityView(for: mag)
                    countdownText
                    Spacer()
                }
                Spacer(minLength: 5)
            }
            Spacer()
        }
        .foregroundColor(.issrttWhite)
        .offset(x: 16)
        Spacer()
    }
    
    private var dateText: some View {
        Text(date.formatted(.dateTime.weekday(.wide)).uppercased())
            .font(.caption).fontWeight(.heavy)
            .opacity(0.70)
            .offset(y: 20)
    }
    
    private var monthDayText: some View {
        Text("\(date.formatted(.dateTime.month(.abbreviated)).uppercased()) \(date.formatted(.dateTime.day()))")
            .font(.largeTitle).fontWeight(.black)
    }
    
    private var countdownText: some View {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: date)
        let diffInMinutes = (diff.day ?? 999) * 1440 + (diff.hour ?? 0) * 60 + (diff.minute ?? 0)
        return Text("T-minus \(diffInMinutes) mins")
            .font(.subheadline).fontWeight(.bold)
            .opacity(0.70)
            .offset(y: 46)
            .minimumScaleFactor(0.60)
    }
}

struct InfoCardView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        let azi     = Text("\(entry.startAzimuth, format: .number.precision(.fractionLength(0)))\(Globals.degreeSign)")
        let cp      = Text(entry.startAzCompass)
        let date    = Text("\(entry.passDate.formatted(date: .omitted, time: .shortened))")
        let dur     = Text("\(entry.duration) min")
        let elev    = Text("\(entry.startElevation, format: .number.precision(.fractionLength(1)))\(Globals.degreeSign)")
        let mag     = Text("\(entry.mag, format: .number.precision(.fractionLength(1)))")
        
        let azLabel = family == .systemMedium ? "  Azimuth:  "   : " Az: "
        let cpLabel = family == .systemMedium ? "  Compass:  "   : " Cp: "
        let duLabel = family == .systemMedium ? "  Duration:  "  : " Du: "
        let elLabel = family == .systemMedium ? "  Elevation:  " : " El: "
        let mgLabel = family == .systemMedium ? "  Magnitude:  " : " Mg: "
        let tmLabel = family == .systemMedium ? "  Start:  "     : " St: "
        let spacing = family == .systemMedium ? 0.0 : 0.0
        
        ZStack {
            Rectangle()
                .foregroundColor(.issrttWhite)
                .cornerRadius(8)
                .frame(height: 55)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {       // Column 1
                    InfoRow(icon: "clock", label: tmLabel, value: date, spacing: spacing)
                    InfoRow(icon: "safari", label: azLabel, value: azi, spacing: spacing)
                    InfoRow(icon: "dot.arrowtriangles.up.right.down.left.circle", label: cpLabel, value: cp, spacing: spacing)
                }
                .foregroundColor(.issrttRed)
                .padding(.horizontal, 5)
                if family == .systemMedium {                    // Column 2 (Show this column only if in the medium size widget)
                    VStack(alignment: .leading, spacing: 0) {
                        InfoRow(icon: "paperplane.circle", label: elLabel, value: elev, spacing: spacing)
                        InfoRow(icon: "stopwatch", label: duLabel, value: dur, spacing: spacing)
                        InfoRow(icon: "sun.max.circle", label: mgLabel, value: mag, spacing: spacing)
                    }
                    .foregroundColor(.issrttRed)
                    .padding(.horizontal, 0)
                }
                Spacer()
            }
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

/// Return 1-4 stars in a view based on the magnitude of the pass
/// - Parameter pass: The pass
/// - Returns: A view consisting of an HStack of rating stars
private func passQualityView(for magnitude: Double) -> some View {
    HStack(spacing: 3) {
        Text("Pass quality:")
            .font(.subheadline).fontWeight(.bold)
            .opacity(0.7)
            .minimumScaleFactor(0.90)
            .lineLimit(1)
        HStack(spacing: 2) {
            ForEach(0..<4) { star in
                Image(star < (getNumberOfStars(forMagnitude: magnitude) ?? 0) ? .icons8StarFilledWhite : .starUnfilledForWidgets)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15)
            }
        }
    }
}

/// Get the number of stars from the rating system enum
/// If no magnitude was returned by the API, return nil
/// - Parameters:
///   - magnitude: pass magnitude
/// - Returns: optional Int
private func getNumberOfStars(forMagnitude magnitude: Double) -> Int? {
    if magnitude != RatingSystem.unknown.rawValue {
        return RatingSystem.numberOfRatingStars(for: magnitude)
    } else {
        return nil
    }
}

// MARK: - Widget configuration

struct ISS_Real_Time_Tracker_3D_Widget: Widget {
    let kind: String = "ISS_Real_Time_Tracker_3D_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ISS_Real_Time_Tracker_3D_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("ISSRTT3D Widget")
        .description("Displays the next ISS pass for your location.")
        
#if os(watchOS)
        .supportedFamilies([.accessoryCircular])
#else
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
#endif
    }
}

#Preview(as: .systemMedium) {
    ISS_Real_Time_Tracker_3D_Widget()
} timeline: {
    NextPass(date: Date(), passDate: Date(), duration: 399, mag: -1.2, startAzimuth: 350.8, startAzCompass: "NNW", startElevation: 22, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0)
    NextPass(date: Date(), passDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!, duration: 401, mag: -0.9, startAzimuth: 216.3, startAzCompass: "SW", startElevation: 18.7, maxAzimuth: 270.0, maxElevation: 60.0, endAzimuth: 30.0)
}
