//
//  CoordinatesConversions.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 2/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


struct CoordinatesConversions {
    
    /// Convert map coordinates from decimal to degrees, minutes, seconds, and direction
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String {
        
        var latSeconds = Int(latitude * 3600)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        
        return String(format: format, abs(latDegrees), latMinutes, latSeconds, {return latDegrees >= 0 ? "N" : "S"}(), abs(longDegrees), longMinutes, longSeconds, {return longDegrees >= 0 ? "E" : "W"}())
        
    }
    
    
    /// Convert map coordinates from degrees, minutes, seconds, and direction to decimal
    static func degMinSecCoordinatesToDecimal(degrees: Double, minutes: Double, seconds: Double, direction: String) -> Double {
        
        let sign = (direction == "S" || direction == "W") ? -1.0 : 1.0
        
        return (degrees + (minutes + seconds / 60.0) / 60.0) * sign
        
    }
    
}
