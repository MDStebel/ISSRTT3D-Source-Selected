//
//  Coordinate Conversions.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 11/20/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Format converters for coordinates
struct CoordinateConversions: ConvertsToDegreesMinutesSeconds {
    
    /// Convert coordinates from decimal to degrees, minutes, seconds, and direction
    ///
    /// This is a format conversion.
    /// - Parameters:
    ///   - latitude: Latitude as a Double.
    ///   - longitude: Longitude as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinates string in deg min sec format.
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String {
        
        var latSeconds  = Int(latitude * Double(Globals.numberOfSecondsInAnHour))
        let latDegrees  = latSeconds / Int(Globals.numberOfSecondsInAnHour)
        latSeconds      = abs(latSeconds % Int(Globals.numberOfSecondsInAnHour))
        let latMinutes  = latSeconds / Int(Globals.numberOfSecondsInAMinute)
        latSeconds %= Int(Globals.numberOfSecondsInAMinute)
        
        var longSeconds = Int(longitude * Double(Globals.numberOfSecondsInAnHour))
        let longDegrees = longSeconds / Int(Globals.numberOfSecondsInAnHour)
        longSeconds     = abs(longSeconds % Int(Globals.numberOfSecondsInAnHour))
        let longMinutes = longSeconds / Int(Globals.numberOfSecondsInAMinute)
        longSeconds %= Int(Globals.numberOfSecondsInAMinute)
        
        return String(format: format, abs(latDegrees), latMinutes, latSeconds, {return latDegrees >= 0 ? "N" : "S"}(), abs(longDegrees), longMinutes, longSeconds, {return longDegrees >= 0 ? "E" : "W"}())
        
    }
    
    
    /// Convert coordinates from degrees, minutes, seconds, and direction to decimal
    /// - Parameters:
    ///   - degrees: Degrees as a Double.
    ///   - minutes: Minutes as a Double.
    ///   - seconds: Seconds as a Double.
    ///   - direction: Direction as a String (either "N" or "S").
    /// - Returns: Decimal representation of coordinates as a Double
    static func degMinSecCoordinatesToDecimal(degrees: Double, minutes: Double, seconds: Double, direction: String) -> Double {
        
        let sign = (direction == "S" || direction == "W") ? -1.0 : 1.0
        
        return (degrees + (minutes + seconds / Double(Globals.numberOfSecondsInAMinute)) / Double(Globals.numberOfSecondsInAMinute)) * sign
        
    }
    
}
