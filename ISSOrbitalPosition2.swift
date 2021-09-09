//
//  ISSOrbitalPosition2.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/7/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// ISSOrbitalPosition2 model
///
/// Represents the JSON-returned data from the API
/// A position is in a struct named Positions. Array of Positions is named positions[].
struct ISSOrbitalPosition2: Decodable {
    
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
