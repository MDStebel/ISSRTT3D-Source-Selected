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
        case v1 = "https://issrttapi.com/EHDC-Video-Location.json"
        case v5 = "https://truvisibility.com/file/get/f1054605-3d5c-4c9e-aaaa-a8fa005ac9ac/issrtt-hdev.json"
        case v6 = "https://truvisibility.com/file/get/0b38bbb2-137d-4356-95c3-a90301212362/issrtt-hdev.json"
        case v7 = "http://www.ustream.tv/embed/17074538?v=3&wmode=direct"
        case v8 = "https://www.ustream.tv/embed/17074538?html5ui;autoplay=1"
        case v9 = "https://issrttapi.com/LiveTVURLs.json"
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
