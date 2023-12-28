//
//  SatelliteOrbitPosition.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 9/13/21.
//  Copyright © 2022-2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// Satellite orbit position model
///
/// Represents the JSON-returned data from the API
/// A position is in a struct named Positions. Array of Positions is named positions[].
struct SatelliteOrbitPosition: Decodable {
    
    var info: Info
    var positions: [Positions]
    
    struct Info: Decodable {
        
        var satid: Int
        var satname: String
        var transactionscount: Int
        
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
