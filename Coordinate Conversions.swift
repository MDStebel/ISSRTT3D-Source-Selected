//
//  Coordinate Conversions.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 11/20/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation

/// A set of format converters for latitude and longitude coordinates
struct CoordinateConversions: ConvertsToDegreesMinutesSeconds {
    
    #if !os(watchOS)
    
    /// Convert coordinates from decimal to degrees, minutes, seconds, and direction
    ///
    /// This is a format conversion only.
    /// - Parameters:
    ///   - latitude: Latitude as a Double.
    ///   - longitude: Longitude as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinates string in deg min sec format.
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String {
        var latSeconds = Int(latitude * Double(Globals.numberOfSecondsInAnHour))
        let latDegrees = latSeconds / Int(Globals.numberOfSecondsInAnHour)
        latSeconds = abs(latSeconds % Int(Globals.numberOfSecondsInAnHour))
        let latMinutes = latSeconds / Int(Globals.numberOfSecondsInAMinute)
        latSeconds %= Int(Globals.numberOfSecondsInAMinute)

        var longSeconds = Int(longitude * Double(Globals.numberOfSecondsInAnHour))
        let longDegrees = longSeconds / Int(Globals.numberOfSecondsInAnHour)
        longSeconds = abs(longSeconds % Int(Globals.numberOfSecondsInAnHour))
        let longMinutes = longSeconds / Int(Globals.numberOfSecondsInAMinute)
        longSeconds %= Int(Globals.numberOfSecondsInAMinute)

        return String(format: format, abs(latDegrees), latMinutes, latSeconds, { latDegrees >= 0 ? "N" : "S" }(), abs(longDegrees), longMinutes, longSeconds, { longDegrees >= 0 ? "E" : "W" }())
    }
    
    #else // watchOS
    
    /// Convert an individual coordinate from decimal to degrees, minutes, seconds, and direction
    ///
    /// This is a format conversion only.
    /// - Parameters:
    ///   - coordinate: An individual coordinate (i.e., lat or lon) as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinate string in deg min sec format.
    static func decimalCoordinatesToDegMinSec(coordinate: Double, format: String, isLatitude: Bool) -> String {
        
        var cardinal: String
        
        var seconds = Int(coordinate * Double(Globals.numberOfSecondsInAnHour))
        let degrees = seconds / Int(Globals.numberOfSecondsInAnHour)
        seconds = abs(seconds % Int(Globals.numberOfSecondsInAnHour))
        let minutes = seconds / Int(Globals.numberOfSecondsInAMinute)
        seconds %= Int(Globals.numberOfSecondsInAMinute)
        
        if isLatitude {
            cardinal = degrees >= 0 ? "N" : "S"
        } else {
            cardinal = degrees >= 0 ? "E" : "W"
        }

        let coordinateText = String(format: format, abs(degrees), minutes, seconds, cardinal)
        return coordinateText
    }
    
    #endif
    
    
    /// Convert coordinates from decimal to degrees, minutes, and direction
    ///
    /// This is a format conversion only.
    /// - Parameters:
    ///   - latitude: Latitude as a Double.
    ///   - longitude: Longitude as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinates string in deg min format.
    static func decimalCoordinatesToDegMin(latitude: Double, longitude: Double, format: String) -> String {
        var latSeconds = Int(latitude * Double(Globals.numberOfSecondsInAnHour))
        let latDegrees = latSeconds / Int(Globals.numberOfSecondsInAnHour)
        latSeconds = abs(latSeconds % Int(Globals.numberOfSecondsInAnHour))
        let latMinutes = latSeconds / Int(Globals.numberOfSecondsInAMinute)
        latSeconds %= Int(Globals.numberOfSecondsInAMinute)

        var longSeconds = Int(longitude * Double(Globals.numberOfSecondsInAnHour))
        let longDegrees = longSeconds / Int(Globals.numberOfSecondsInAnHour)
        longSeconds = abs(longSeconds % Int(Globals.numberOfSecondsInAnHour))
        let longMinutes = longSeconds / Int(Globals.numberOfSecondsInAMinute)
        longSeconds %= Int(Globals.numberOfSecondsInAMinute)

        return String(format: format, abs(latDegrees), latMinutes, { latDegrees >= 0 ? "N" : "S" }(), abs(longDegrees), longMinutes, { longDegrees >= 0 ? "E" : "W" }())
    }
    
    /// Convert coordinates from degrees, minutes, seconds, and direction to decimal
    ///
    /// This is a format conversion only.
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
