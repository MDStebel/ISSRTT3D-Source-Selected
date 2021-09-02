//
//  TSSOrbitalPosition.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/7/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// TSSOrbitalPosition model
///
/// Represents the JSON-returned data from Tiangong (TSS) Position API
/// A position is in a struct named Positions. Array of Positions is named positions[].
struct TSSOrbitalPosition: Decodable {
    
    var info: Info
    var positions: [Positions]
    
    struct Info: Decodable {
        
        var satid: Int
        var satname: String
        var transactionscount: Int
        let passescount: Int
        
    }
    
    struct Positions: Decodable {
        
        var azimuth: Double
        var dec: Double
        var eclipsed: Bool
        var elevation: Double
        var ra: Double
        var sataltitude: Double
        var satlatitude: Double
        var satlongitude: Double
        var timestamp: Int
        
    }
    
}
