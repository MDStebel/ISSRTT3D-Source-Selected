//
//  CoordinateConversions.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 2/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//


import SceneKit


/// A set of methods that provide solar coordinates and Julian-based dates.
struct CoordinateConversions {
    
    
    /// Convert coordinates from lat, lon, altitude to SceneKit xyz cooridates
    /// - Parameters:
    ///   - lat: Latitude as a decimal
    ///   - lon: Longitude as a decimal
    ///   - alt: altitude
    /// - Returns: Position as a SCNVector3
    static func convertLatLonCoordinatesToXYZ(_ lat: Float, _ lon: Float, alt: Float) -> SCNVector3 {
        
        let cosLat = cosf(lat * Globals.degreesToRadians)
        let sinLat = sinf(lat * Globals.degreesToRadians)
        let cosLon = cosf(lon * Globals.degreesToRadians)
        let sinLon = sinf(lon * Globals.degreesToRadians)
        let x = alt * cosLat * cosLon
        let y = alt * cosLat * sinLon
        let z = alt * sinLat
        let sceneKitX = -x
        let sceneKitY = z
        let sceneKitZ = y
        
        let position = SCNVector3(x: sceneKitX, y: sceneKitY, z: sceneKitZ )
        return position
        
    }
    
    
    /// Convert a Gregorian date to a Julian date
    /// - Parameter date: Gregorian date to convert
    /// - Returns: Julian date as a Double
    static func julianDate(date : Date) -> Double {
        
        let JD_JAN_1_1970_0000GMT = 2440587.5
        
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
        
    }
    
    
    /// Calculate the Julian century from a Gregorian date
    /// - Parameter date: Gregorian date
    /// - Returns: Julian century as a Double
    static func julianCentury(date: Date) -> Double {
        
        let jc = (julianDate(date: date) - 2451545) / Double(Globals.numberOfDaysInCentury)
        
        return jc
        
    }
    
    
    /// Calculate the exact latitude where the Sun is currently over
    /// - Returns: Latitude in degrees as a Float
    static func getLatitudeOfSunAtCurrentTime() -> Float {
        
        let meanLongitude = getGeometricMeanLongitudeOfSunAtCurrentTime()
        let latitudeOfSun = asin(sin(meanLongitude * Globals.degreesToRadians) * sin(Globals.earthTiltInDegrees * Globals.degreesToRadians)) * Globals.radiansToDegrees
        
        return latitudeOfSun
        
    }
    
    
    /// Calculate the exact geometric mean longitude of the Sun at the current time
    /// - Returns: The geometric mean longitude in degrees as a Float
    static func getGeometricMeanLongitudeOfSunAtCurrentTime() -> Float {
     
        let now = Date()
        let jC = julianCentury(date: now)

        let sunLongitude = Float((280.46646 + jC * (36000.76983 + jC * 0.0003032))).truncatingRemainder(dividingBy: 360)
        
        return Float(sunLongitude)
        
    }
    
    
    /// Calculate longitude where Sun is currently over
    /// This method uses an algorithm that's based on finding the longitude where it's approximately 12 noon on Earth.
    /// - Returns: Longitude in degrees as a Float
    static func getLongitudeOfSunAtCurrentTime() -> Float {

        var trueLon: Float
        
        // This block determines where on the Earth noon is currently in units of time displacement
        let localMins = Float(Calendar.current.component(.minute, from: Date()))
        let localHour = Float(Calendar.current.component(.hour, from: Date())) + Float(localMins / 60)
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let noonHour = 12 - localHour + Float(secondsFromGMT / 3600)
        
        // This corrects for timezone
        if noonHour <= 0 {
            trueLon = (noonHour * Globals.degreesLongitudePerHour).truncatingRemainder(dividingBy: 180)
        } else {
            trueLon = 180 + (noonHour * Globals.degreesLongitudePerHour).truncatingRemainder(dividingBy: 180)
        }
        
        return trueLon
        
    }
    
    
    /// Compute the Sun's equation of center
    /// - Parameter t: The number of Julian centuries since 2000
    /// - Returns: The Sun center in radians.
    public func sunEquationOfCenter(t: Double) -> Double {
        
        let m = (357.52911 + t * (35999.05029 - t * 0.0001537))             // The Sun mean anomaly
        let c = sin(m) * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin(2 * m) * (0.019993 - 0.000101 * t) + sin(3 * m) * 0.000289
        let cInRadians = c * .pi/180
        
        return cInRadians
        
    }
    
    
    /// Convert coordinates from decimal to degrees, minutes, seconds, and direction.
    /// - Parameters:
    ///   - latitude: Latitude as a Double.
    ///   - longitude: Longitude as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinates string in deg min sec format.
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
    
    
    /// Convert coordinates from degrees, minutes, seconds, and direction to decimal.
    /// - Parameters:
    ///   - degrees: Degrees as a Double.
    ///   - minutes: Minutes as a Double.
    ///   - seconds: Seconds as a Double.
    ///   - direction: Direction as a String (either "N" or "S").
    /// - Returns: Decimal representation of coordinates as a Double
    static func degMinSecCoordinatesToDecimal(degrees: Double, minutes: Double, seconds: Double, direction: String) -> Double {
        
        let sign = (direction == "S" || direction == "W") ? -1.0 : 1.0
        return (degrees + (minutes + seconds / 60.0) / 60.0) * sign
        
    }
    
}
