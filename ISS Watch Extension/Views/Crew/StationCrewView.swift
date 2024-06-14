//
//  StationCrewView.swift
//  ISS Watch
//
//  Created by Michael Stebel on 4/29/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI


/// The view for each station's crew
struct StationCrewView: View {
    
    var crew: [Crews.People]
    var station: Stations
    var colorKey: Color
    
    var body: some View {
        Section(header: Text("\(station.rawValue): \(crew.count) people")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.gray)) {
                ForEach(crew, id: \.self) { person in
                    NavigationLink(destination: CrewDetailView(crewMember: person)) {
                        CrewRowView(
                            country: person.country,
                            name: person.name,
                            station: person.location,
                            title: person.title,
                            colorKey: colorKey
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listItemTint(.ISSRTT3DBackground)
                }
            }
    }
}


#Preview {
    StationCrewView(
        crew: [
            Crews.People(
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
            ),
            Crews.People(
                name: "Joe Astronaut",
                biophoto: "https://issrttapi.com/md.jpg",
                country: "USA",
                launchdate: "2024-04-20",
                title: "Flight Engineer",
                location: "International Space Station",
                bio: "Oleg Dmitriyevich Kononenko is a Russian cosmonaut. He has flown to the International Space Station four times. He accumulated over 736 days in orbit during his four long duration flights, the longest time in space of any currently active cosmonaut or astronaut.",
                biolink: "https://www.nasa.gov/people/jeanette-j-epps/",
                twitter: "https://www.nasa.gov/people/jeanette-j-epps/",
                mission: "Crew-9",
                launchvehicle: "Crew Dragon",
                expedition: "71"
            )
        ],
        station: Stations.ISS,
        colorKey: .ISSRTT3DRed
    )
}
