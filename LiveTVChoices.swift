//
//  LiveTVChoices.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 7/23/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Live TV Channels Model
struct LiveTVChoices: Codable {
    
    /// Alternative URLs, each of which in turn contain the URLs of the video stream to use to get the JSON with the channel addresses
    enum URLAlternatives: String {
        case v1 = "---"
        case v5 = "---"
        case v6 = "---"
        case v7 = "---"
        case v8 = "---"
        case v9 = "---"
    }
    
    /// The active channels
    enum Channels: String {
        case nasaTV     = "NASA TV"
        case liveEarth  = "Earth View"
    }
    
    // The channel URLs come from the parsed JSON data
    let liveURL: String
    let nasatvURL: String
    
}
