//
//  CrewDetailView.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/13/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI

struct CrewDetailView: View {
    
    // MARK: - Properties
    
    let crewMember: Crews.People
    
    @State private var image: Image? = nil    
    
    private let corner   = 15.0
    
    var body: some View {
        
        ZStack {
            Color.cyan.opacity(0.6)
                .ignoresSafeArea(edges: .all)
            
            ScrollView {
                
                ZStack {
                    Circle()
                        .fill(Gradient(colors: [.blue, .green]))
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    if let image {
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                    } else {
                        ProgressView()
                    }
                }
                
                VStack {
                    
                    // Date calculations
                    let launchdate = DateFormatter().convert(from:  crewMember.launchdate, fromStringFormat: Globals.dateFormatStringEuropeanForm, toStringFormat: Globals.outputDateFormatStringShortForm) ?? ""
                    let numDays = numberOfDaysInSpace(since: launchdate)
                    
                    CrewDetailSubheading(heading: "General")
                    
                    CrewStatView(label: "Name", stat: crewMember.name)
                    CrewStatView(label: "Country", stat: crewMember.country)
                    
                    CrewDetailSubheading(heading: "On Station")
                    
                    CrewStatView(label: "Title", stat: crewMember.title)
                    CrewStatView(label: "Expediiton", stat: crewMember.expedition)
                    CrewStatView(label: "Days in space", stat: "\(numDays)")
                    
                    CrewDetailSubheading(heading: "Launch")
                    
                    CrewStatView(label: "Date", stat: launchdate)
                    CrewStatView(label: "Mission", stat: crewMember.mission)
                    CrewStatView(label: "Vehicle", stat: crewMember.launchvehicle)

                    CrewDetailSubheading(heading: "Biography")
                    
                    Text(crewMember.bio)
                        .font(.caption)
                        .foregroundColor(.white.opacity(1))
                        .padding(EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 1))
                }
                .padding(2)
            }
            .navigationTitle(crewMember.name)
            
            .onAppear {
                Task {
                    do {
                        let urlString = crewMember.biophoto
                        guard let url = URL(string: urlString) else {
                            self.image = Image(.astronautPlaceholder)
                            return
                        }
                        let imageData = try await loadImage(from: url)
                        DispatchQueue.main.async {
                            if let imageFromData = UIImage(data: imageData) {
                                self.image = Image(uiImage: imageFromData)
                            } else {
                                self.image = Image(.astronautPlaceholder)
                            }
                        }
                    } catch {
                        self.image = Image(.astronautPlaceholder)
                        print("Error loading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper functions
    
    /// Helper function to fetch image acsynchronously
    /// - Parameter url: The image URL
    /// - Returns: Image data
    func loadImage(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    /// Helper method to calculate the number of days an astronaut has been in space (today - launch date).
    /// If there's an error in the data, this will detect it and return 0 days.
    /// - Returns: Number of days since launch.
    func numberOfDaysInSpace(since launch: String) -> Int {
        
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
    CrewDetailView(
        crewMember: Crews.People(
            name: "Oleg Kononenko",
            biophoto: "https://issrttapi.com/kononenko.jpeg",
            country: "Russia",
            launchdate: "2023-09-15",
            title: "Commander",
            location: "International Space Station",
            bio: "Oleg Dmitriyevich Kononenko is a Russian cosmonaut. He has flown to the International Space Station four times. He accumulated over 736 days in orbit during his four long duration flights, the longest time in space of any currently active cosmonaut or astronaut.",
            biolink: "https://en.wikipedia.org/wiki/Oleg_Kononenko",
            twitter: "",
            mission: "Soyuz MS-24",
            launchvehicle: "Soyuz",
            expedition: "71"
        )
    )
}