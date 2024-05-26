//
//  CrewsModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/25/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
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
