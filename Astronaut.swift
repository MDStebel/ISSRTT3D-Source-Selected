//
//  Astronaut.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 7/9/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Model that encapsulates an astronaut.
///
/// Initialize an Astronaut instance with member-wise initializer: Astronaut(name: name, title: title, country: country, countryFlag: countryFlag, spaceCraft: spaceCraft, launchDate: launchDate, bio: bio, shortBioBlurb: shortBioBlurb, image: image, twitter: twitter, mission: mission, launchVehicle: launchVehicle).
struct Astronaut {
    
    // MARK: - Properties
    
    
    let name: String
    let title: String
    let country: String
    let countryFlag: String?
    let spaceCraft: String
    let launchDate: String
    let bio: String
    let shortBioBlurb: String?
    let image: String?
    let twitter: String?
    let mission: String?
    let expedition: String?
    let launchVehicle: String
    
    var shortAstronautDescription: String {
        return name + "  " + (flag)
    }

    
    /// Dictionary of flag emoji for each nationality
    private let countryFlags = [ "usa": "🇺🇸", "USA": "🇺🇸", "united states": "🇺🇸", "United States": "🇺🇸","russia": "🇷🇺", "Russia": "🇷🇺", "italy": "🇮🇹", "Italy": "🇮🇹", "united kingdom": "🇬🇧", "United Kingdom": "🇬🇧", "uk": "🇬🇧", "UK": "🇬🇧", "england": "🇬🇧", "England": "🇬🇧", "canada": "🇨🇦", "Canada": "🇨🇦", "japan": "🇯🇵", "Japan": "🇯🇵", "germany": "🇩🇪", "Germany": "🇩🇪", "israel": "🇮🇱", "Israel": "🇮🇱", "france": "🇫🇷", "France": "🇫🇷", "netherlands": "🇳🇱", "Netherlands": "🇳🇱", "the netherlands": "🇳🇱", "The Netherlands": "🇳🇱","belgium": "🇧🇪", "Belgium": "🇧🇪", "denmark": "🇩🇰", "Denmark": "🇩🇰", "norway": "🇳🇴", "Norway": "🇳🇴", "china": "🇨🇳", "China": "🇨🇳", "spain": "🇪🇸", "Spain": "🇪🇸", "india": "🇮🇳", "India": "🇮🇳", "brazil": "🇧🇷", "Brazil": "🇧🇷","sweden": "🇸🇪", "Sweden": "🇸🇪", "greece": "🇬🇷", "Greece": "🇬🇷", "estonia": "🇪🇪", "Estonia": "🇪🇪", "austria": "🇦🇹", "Austria": "🇦🇹", "czech republic": "🇨🇿", "Czech Republic": "🇨🇿", "czech": "🇨🇿", "Czech": "🇨🇿", "switzerland": "🇨🇭", "Switzerland": "🇨🇭", "switz": "🇨🇭", "Switz": "🇨🇭", "finland": "🇫🇮", "Finland": "🇫🇮", "hungary": "🇭🇺", "Hungary": "🇭🇺", "poland": "🇵🇱", "Poland": "🇵🇱", "luxembourg": "🇱🇺", "Luxembourg": "🇱🇺", "romainia": "🇷🇴", "Romainia": "🇷🇴", "portugal": "🇵🇹", "Portugal": "🇵🇹", "ireland": "🇮🇪", "Ireland": "🇮🇪", "UAE": "🇦🇪", "uae": "🇦🇪", "U.A.E.": "🇦🇪", "United Arab Emirates": "🇦🇪", "united arab emirates": "🇦🇪"]
    
    
    /// This computed property returns a flag representing the country, if available. If there's no flag, return the flag image, or else return the country name.
    var flag: String {
        return countryFlags[country] ?? countryFormatted
    }
    
    
    /// This computed property returns the flag image URL as a string
    private var countryFlagImage: String {
        return countryFlag ?? flag
    }
    
    
    /// This computed property returns the uppercase string of the country
    private var countryFormatted: String {
        return country.uppercased()
    }
    
    
    /// This computed property returns a date formatted according to output date format string in Globals. If not successful, return an empty string
    var launchDateFormatted: String {
        return DateFormatter().convert(from: launchDate, fromStringFormat: Globals.dateFormatStringEuropeanForm, toStringFormat: Globals.outputDateFormatStringShortForm) ?? ""
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
            return Int(Double(todaysDate.timeIntervalSince(startDate!)) / Globals.numberOfSecondsInADay )
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
        
        var crew = [Astronaut]()    // An array of Astronauts
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? JSONDictionary,
                let numberOfAstronauts = json["number"] as? Int,
                let astronauts = json["people"] as? [JSONDictionary]
            {
                for astronaut in astronauts  {
                    
                    let name = astronaut["name"] as! String
                    let title = astronaut["title"] as! String
                    let country = astronaut["country"] as! String
                    let countryFlag = astronaut["countryflag"] as! String
                    let spaceCraft = astronaut["location"] as! String
                    let launchDate = astronaut["launchdate"] as! String
                    let bio = astronaut["biolink"] as! String
                    let shortBioBlurb = astronaut["bio"] as! String
                    let image = astronaut["biophoto"] as! String
                    let twitter = astronaut["twitter"] as! String
                    let mission = astronaut["mission"] as? String
                    let expedition = astronaut["expedition"] as? String
                    let launchVehicle = astronaut["launchvehicle"] as! String
                    
                    crew.append(Astronaut(name: name, title: title, country: country, countryFlag: countryFlag, spaceCraft: spaceCraft, launchDate: launchDate, bio: bio, shortBioBlurb: shortBioBlurb, image: image, twitter: twitter, mission: mission, expedition: expedition, launchVehicle: launchVehicle))
                    
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
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Astronaut, rhs: Astronaut) -> Bool {
        return lhs.name == rhs.name
    }
    
    /// Returns comma delimited string
    var description: String {
        return "\(name), \(title), \(flag)"
    }
    
}
