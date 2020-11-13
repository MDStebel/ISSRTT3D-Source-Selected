//
//  CoordinateCalculations.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/26/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//


import SceneKit


/// A set of functions that provide astronomical calculations for solar coordinates.
struct CoordinateCalculations {
    
    /// Convert coordinates from lat, lon, altitude to SceneKit xyz cooridates
    /// - Parameters:
    ///   - lat: Latitude as a decimal
    ///   - lon: Longitude as a decimal
    ///   - alt: altitude
    /// - Returns: Position as a SCNVector3
    static func convertLatLonCoordinatesToXYZ(lat: Float, lon: Float, alt: Float) -> SCNVector3 {
        
        let cosLat    = cosf(lat * Globals.degreesToRadians)
        let sinLat    = sinf(lat * Globals.degreesToRadians)
        let cosLon    = cosf(lon * Globals.degreesToRadians)
        let sinLon    = sinf(lon * Globals.degreesToRadians)
        let x         = alt * cosLat * cosLon
        let y         = alt * cosLat * sinLon
        let z         = alt * sinLat
        
        // Map to position on a sphere
        let sceneKitX = -x
        let sceneKitY = z
        let sceneKitZ = y
        
        let position  = SCNVector3(x: sceneKitX, y: sceneKitY, z: sceneKitZ )
        return position
        
    }
    
    
    /// Convert a Gregorian date to a Julian date
    /// - Parameter date: Gregorian date to convert
    /// - Returns: Julian date as a Double
    static func julianDate(date : Date) -> Double {
        
        let julianDateForJan011970 = 2440587.5
        
        return julianDateForJan011970 + date.timeIntervalSince1970 / 86400
        
    }
    
    
    /// Calculate the Julian century from a Gregorian date
    /// - Parameter date: Gregorian date
    /// - Returns: Julian century as a Double
    static func julianCentury(date: Date) -> Double {
        
        let jc = (julianDate(date: date) - 2451545) / Double(Globals.numberOfDaysInCentury)
        
        return jc
        
    }
    
    
    /// Calculate the Sun equation of Center
    /// - Parameter t: Julian century
    /// - Returns: The Sun equation of Center in radians
    static func sunEquationOfCenter(t: Double) -> Double {

        let m = ((357.52911 + t * (35999.05029 - t * 0.0001537)))           // The Sun geometric mean anomaly in degrees
        let cInRadians = sin(m * Double(Globals.degreesToRadians)) * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin(2 * m * Double(Globals.degreesToRadians)) * (0.019993 - 0.000101 * t) + sin(3 * m * Double(Globals.degreesToRadians)) * 0.000289

        return cInRadians
        
    }
        
    
    /// Calculate the exact geometric mean longitude of the Sun at the current time
    ///
    /// The mean longitude of the Sun, corrected for the aberration of light, is: The mean anomaly of the Sun (actually, of the Earth in its orbit around the Sun, but it is convenient to pretend the Sun orbits the Earth), is: Put and. in the range 0° to 360° by adding or subtracting multiples of 360° as needed.
    /// - Returns: The geometric mean longitude in degrees as a Float
    static func getGeometricMeanLongitudeOfSunAtCurrentTime() -> Float {
     
        let now = Date()
        let jC = julianCentury(date: now)

        let sunGeometricMeanLongitude = Float((280.46646 + jC * (36000.76983 + jC * 0.0003032))).truncatingRemainder(dividingBy: 360)
        
        return Float(sunGeometricMeanLongitude)
        
    }
    
    
    /// Calculate the current latitude of the Sun
    ///
    /// Based on the geometric mean longitude of the Sun
    /// - Returns: Latitude in degrees as a Float
    static func getLatitudeOfSunAtCurrentTime() -> Float {
        
        let geomMeanLongitude = getGeometricMeanLongitudeOfSunAtCurrentTime()
        let latitudeOfSun = asin(sin(geomMeanLongitude * Globals.degreesToRadians) * sin(Globals.earthTiltInDegrees * Globals.degreesToRadians)) * Globals.radiansToDegrees

        return latitudeOfSun
        
    }
    
    
    /// Compute the Sun's current subsolar point longitude
    ///
    /// The subsolar point is the location on the Earth where the Sun is directly overhead.
    /// - Returns: The subsolar longitude as a Float
    static func getSubSolarLongitudeOfSunAtCurrentTime() -> Float {
        
        var timeCorrection: Float
        var dayCorrection: Float
        var lonCorrection: Float
        
        // This determines current local and GMT time
        let localMins      = Float(Calendar.current.component(.minute, from: Date()))
        let localHour      = Float(Calendar.current.component(.hour, from: Date())) + localMins / Float(Globals.numberOfMinutesInAnHour)
        let secondsFromGMT = Float(TimeZone.current.secondsFromGMT())
        
        // Correct for time and day relative to GMT and the International Date Line
        if secondsFromGMT < 0 {
            timeCorrection = 1
            dayCorrection  = 0
        } else {
            timeCorrection = -1
            dayCorrection  = -Float(Globals.numberOfHoursInADay)
        }
        
        // Calculate GMT
        let GMT = localHour - Float(secondsFromGMT / Float(Globals.numberOfSecondsInAnHour) - timeCorrection *  Float(Globals.numberOfHoursInADay)).truncatingRemainder(dividingBy: Float(Globals.numberOfHoursInADay))
        
        // Now, calculate the displacement between current GMT and noontime in hours
        let noonHourDisplacement = Globals.noonTime - GMT + dayCorrection
     
        // The subsolar longitude is the displacement in hours times the number of degrees per hour (360/24=15)
        let subSolarLon = noonHourDisplacement * Globals.degreesLongitudePerHour
        
        // Now, determine if we've crossed the international date line. If so, we need to add 180 degrees
        if subSolarLon < -179.9999 && GMT <= Globals.noonTime {
            lonCorrection = 180
        } else if subSolarLon < -179.9999 && GMT >= Globals.noonTime {
            lonCorrection = localHour >= GMT ? 0 : 180
        } else if GMT >= Float(Globals.numberOfHoursInADay) {
            lonCorrection = 180
        } else {
            lonCorrection = 0
        }

        return subSolarLon.truncatingRemainder(dividingBy: 180) + lonCorrection
        
    }
 
    
    /// Convert coordinates from decimal to degrees, minutes, seconds, and direction
    ///
    /// This is a format conversion.
    /// - Parameters:
    ///   - latitude: Latitude as a Double.
    ///   - longitude: Longitude as a Double.
    ///   - format: String containing the format to use in the conversion.
    /// - Returns: The coordinates string in deg min sec format.
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String {
        
        var latSeconds  = Int(latitude * 3600)
        let latDegrees  = latSeconds / 3600
        latSeconds      = abs(latSeconds % 3600)
        let latMinutes  = latSeconds / 60
        latSeconds %= 60
        
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds     = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        
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
        
        return (degrees + (minutes + seconds / 60.0) / 60.0) * sign
        
    }
    
}
