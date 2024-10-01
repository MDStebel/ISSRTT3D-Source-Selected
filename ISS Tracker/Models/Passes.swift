//
//  Passes.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/12/18.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// Passes model
///
/// Represents the JSON-returned data from Pass Predictions API
/// A pass is in a struct named Pass. Array of Passes is named passes[].
struct Passes: Decodable, Hashable {
    
    let info: Info
    let passes: [Pass]
    
    struct Info: Decodable, Hashable {
        let satid: Int
        let satname: String
        let transactionscount: Int
        let passescount: Int
    }
    
    struct Pass: Decodable, Hashable {
        let startAz: Double
        let startAzCompass: String
        let startEl: Double
        let startUTC: Double
        let maxAz: Double
        let maxAzCompass: String
        let maxEl: Double
        let maxUTC: Double
        let endAz: Double
        let endAzCompass: String
        let endUTC: Double
        let endEl: Double?          // The ending elevation isn't always returned for some reason
        let mag: Double
        let duration: Int
        let startVisibility: Double
    }
    
    /// Number of days to project that can be in the API request. Used in segmented switch in settings, etc.
    static let numberOfDaysDictionary = [
        0 : "2",
        1 : "5",
        2 : "10",
        3 : "15",
        4 : "20",
        5 : "30"
    ]
}
