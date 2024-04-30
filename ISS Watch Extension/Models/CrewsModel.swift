//
//  CrewsModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/25/24.
//  Copyright © 2024 ISS Real-Time Tracker, LLC. All rights reserved.
//

import Foundation

struct Crews: Decodable, Hashable {
    
    let number: Int
    let people: [People]
    
    struct People: Decodable, Hashable {
        let name: String
        let biophoto: String
        let country: String
        let launchdate, title: String
        let location: String
        let bio: String
        let biolink, twitter: String
        let mission: String
        let launchvehicle: String
        let expedition: String
    }
}


enum Stations: String {
    case ISS = "International Space Station"
    case Tiangong = "Tiangong"
}


struct Flags {
    static var countryFlags = [
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
    
    static func getFlag(for country: String) -> String {
        countryFlags[country] ?? country.uppercased()
    }
}
