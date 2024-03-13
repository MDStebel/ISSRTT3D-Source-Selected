//
//  Astronaut.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 7/9/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// Model that encapsulates an astronaut.
///
/// Initialize an Astronaut instance with member-wise initializer: Astronaut(name: name, title: title, country: country, countryFlag: countryFlag, spaceCraft: spaceCraft, launchDate: launchDate, bio: bio, shortBioBlurb: shortBioBlurb, image: image, twitter: twitter, mission: mission, launchVehicle: launchVehicle).
struct Astronaut: Decodable {
    
    // MARK: - Properties
    
    let name: String
    let title: String
    let country: String
    let spaceCraft: String
    let launchDate: String
    let bio: String
    let launchVehicle: String
    let shortBioBlurb: String
    let image: String
    let twitter: String
    let mission: String
    let expedition: String
    
    /// Dictionary of flag emoji for each nationality
    private var countryFlags = [
        "Austria": "🇦🇹",
        "Belarus": "🇧🇾",
        "Belgium": "🇧🇪",
        "Brazil": "🇧🇷",
        "CHINA": "🇨🇳",
        "Canada": "🇨🇦",
        "China": "🇨🇳",
        "Czech Republic": "🇨🇿",
        "Czech": "🇨🇿",
        "Denmark": "🇩🇰",
        "England": "🇬🇧",
        "Estonia": "🇪🇪",
        "Finland": "🇫🇮",
        "France": "🇫🇷",
        "Germany": "🇩🇪",
        "Greece": "🇬🇷",
        "Hungary": "🇭🇺",
        "India": "🇮🇳",
        "Ireland": "🇮🇪",
        "Israel": "🇮🇱",
        "Italy": "🇮🇹",
        "Japan": "🇯🇵",
        "Luxembourg": "🇱🇺",
        "Netherlands": "🇳🇱",
        "Nigeria": "🇳🇬",
        "Norway": "🇳🇴",
        "PRC": "🇨🇳",
        "Poland": "🇵🇱",
        "Portugal": "🇵🇹",
        "Romainia": "🇷🇴",
        "Russia": "🇷🇺",
        "Saudi Arabia": "🇸🇦",
        "Spain": "🇪🇸",
        "Sweden": "🇸🇪",
        "Switz": "🇨🇭",
        "Switzerland": "🇨🇭",
        "The Netherlands": "🇳🇱",
        "Turkey": "🇹🇷",
        "Türkiye": "🇹🇷",
        "U.A.E.": "🇦🇪",
        "UAE": "🇦🇪",
        "UK": "🇬🇧",
        "USA": "🇺🇸",
        "United Arab Emirates": "🇦🇪",
        "United Kingdom": "🇬🇧",
        "United States": "🇺🇸",
        "austria": "🇦🇹",
        "belgium": "🇧🇪",
        "brazil": "🇧🇷",
        "canada": "🇨🇦",
        "china": "🇨🇳",
        "czech republic": "🇨🇿",
        "czech": "🇨🇿",
        "denmark": "🇩🇰",
        "england": "🇬🇧",
        "estonia": "🇪🇪",
        "finland": "🇫🇮",
        "france": "🇫🇷",
        "germany": "🇩🇪",
        "greece": "🇬🇷",
        "hungary": "🇭🇺",
        "india": "🇮🇳",
        "ireland": "🇮🇪",
        "israel": "🇮🇱",
        "italy": "🇮🇹",
        "japan": "🇯🇵",
        "luxembourg": "🇱🇺",
        "netherlands": "🇳🇱",
        "norway": "🇳🇴",
        "poland": "🇵🇱",
        "portugal": "🇵🇹",
        "prc": "🇨🇳",
        "romainia": "🇷🇴",
        "russia": "🇷🇺",
        "saudi arabia": "🇸🇦",
        "spain": "🇪🇸",
        "sweden": "🇸🇪",
        "switz": "🇨🇭",
        "switzerland": "🇨🇭",
        "the netherlands": "🇳🇱",
        "uae": "🇦🇪",
        "uk": "🇬🇧",
        "united arab emirates": "🇦🇪",
        "united kingdom": "🇬🇧",
        "united states": "🇺🇸",
        "usa": "🇺🇸",
    ]
    
    
    /// This computed property returns the uppercase string of the country
    private var countryFormatted: String {
        country.uppercased()
    }
    
    
    /// This computed property returns a flag representing the country, if available. If there's no flag, return the flag image, or else return the country name.
    var flag: String {
        countryFlags[country] ?? countryFormatted
    }
    
    
    var shortAstronautDescription: String {
        name + "  " + (flag)
    }
    
    
    /// This computed property returns a date formatted according to output date format string in Globals. If not successful, return an empty string
    var launchDateFormatted: String {
        DateFormatter().convert(from: launchDate, fromStringFormat: Globals.dateFormatStringEuropeanForm, toStringFormat: Globals.outputDateFormatStringShortForm) ?? ""
    }
    
    
    // MARK: - Methods
    
    
    /// Method to calculate the number of days an astronaut has been in space (today - launch date).
    /// If there's an error in the JSON data, this will detect it and return 0 days.
    /// - Returns: Number of days since launch.
    func numberOfDaysInSpace() -> Int {
        
        let todaysDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Globals.outputDateFormatStringShortForm
        let launchedOn = launchDateFormatted
        
        if launchedOn != "" {
            let startDate = dateFormatter.date(from: launchedOn)
            return Int(Float(todaysDate.timeIntervalSince(startDate!)) / Float(Globals.numberOfSecondsInADay ))
        } else {
            return 0
        }
        
    }
    
    
    /// Parses JSON file with current crew names from my API and returns an optional array of Astronauts.
    /// - Parameter data: The data returned from API.
    /// - Returns: Optional array of Astronauts.
    static func parseCurrentCrew(from data: Data?) -> [Astronaut]? {
        
        /// Type alias for a dictionary to make code easier to read
        typealias JSONDictionary = [String: Any]
        
        var crew = [Astronaut]()    // Create an empty array of Astronauts
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? JSONDictionary,
               let numberOfAstronauts = json["number"] as? Int,
               let astronauts = json["people"] as? [JSONDictionary]
            {
                for astronaut in astronauts  {
                    
                    let name          = astronaut["name"] as! String
                    let title         = astronaut["title"] as! String
                    let country       = astronaut["country"] as! String
                    let spaceCraft    = astronaut["location"] as! String
                    let launchDate    = astronaut["launchdate"] as! String
                    let bio           = astronaut["biolink"] as! String
                    let shortBioBlurb = astronaut["bio"] as! String
                    let image         = astronaut["biophoto"] as! String
                    let twitter       = astronaut["twitter"] as! String
                    let mission       = astronaut["mission"] as! String
                    let launchVehicle = astronaut["launchvehicle"] as! String
                    let expedition    = astronaut["expedition"] as! String
                    
                    crew.append(Astronaut(name: name, title: title, country: country, spaceCraft: spaceCraft, launchDate: launchDate, bio: bio, launchVehicle: launchVehicle, shortBioBlurb: shortBioBlurb, image: image, twitter: twitter, mission: mission, expedition: expedition))
                    
                }
                
                guard crew.count == numberOfAstronauts else { return nil }      // Ensures there's no discrepancy in the number of crew returned
                return crew
                
            } else {
                return nil
            }
            
        }
        
        catch {
            return nil
        }
        
    }
    
}


extension Astronaut: CustomStringConvertible, Comparable {
    
    static func < (lhs: Astronaut, rhs: Astronaut) -> Bool {
        lhs.name < rhs.name
    }
    
    static func == (lhs: Astronaut, rhs: Astronaut) -> Bool {
        lhs.name == rhs.name
    }
    
    /// Returns comma delimited string
    var description: String {
        "\(name), \(title), \(flag)"
    }
    
}
