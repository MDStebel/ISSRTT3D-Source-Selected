//
//  AstroCalculations.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 02/26/2021.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// A set of functions that provide solar position calculations
struct AstroCalculations {
    
    
    /// Convert a given Gregorian date to a Julian date
    /// - Parameter date: Gregorian date to convert as a Date
    /// - Returns: Julian date as a Double
    static func jDFromDate(date: Date) -> Double {
        
        let jD = Globals.julianDateForJan011970At0000GMT + date.timeIntervalSince1970 / Globals.numberOfSecondsInADay
        
        return jD
        
    }


    /// Convert a given Julian date to a Gregorian date
    /// - Parameter jd: Julian date as a Double
    /// - Returns: Standard date as a NSDate
    static func dateFromJd(jd : Double) -> NSDate {
        
        let gD = NSDate(timeIntervalSince1970: (jd - Globals.julianDateForJan011970At0000GMT) * Globals.numberOfSecondsInADay)
        
        return gD
        
    }
    
    
    /// Calculate the Julian century since Jan-1-2000
    /// - Parameter date: Gregorian date as a Date
    /// - Returns: Julian century as a Double
    static func julianCenturySinceJan2000(date: Date) -> Double {
        
        let jc = (jDFromDate(date: date) - 2451545) / Globals.numberOfDaysInACentury
        
        return jc
        
    }
    
    
    /// Calculate the orbital eccentricity of the Earth
    ///
    /// The orbital eccentricity of an astronomical object is a dimensionless parameter that determines the amount by which its orbit around another body deviates from a perfect circle.
    /// - Parameter t: Julian century as a Double
    /// - Returns: Eccentricity as a Double
    static func orbitEccentricityOfEarth(t: Double) -> Double {
        
        let ecc = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
        
        return ecc
        
    }
    
    
    /// Calculate the mean anomaly of the Sun for a given date
    ///
    /// The mean anomaly is the angle between lines drawn from the Sun to the perihelion and to a point moving in the orbit at a uniform rate corresponding to the period of revolution of the planet.
    /// If the orbit of the planet were a perfect circle, then the planet as seen from the Sun would move along its orbit at a fixed speed.
    /// Then it would be simple to calculate its position (and also the position of the Sun as seen from the planet).
    /// The position that the planet would have relative to its perihelion if the orbit of the planet were a circle is called the mean anomaly.
    /// - Parameter t: Julian century as a Double
    /// - Returns: The mean anomaly as a Double
    static func meanAnomaly(t: Double) -> Double {
        
        let m = 357.52911 + t * 35999.05029 - t * 0.0001537
        
        return m
        
    }
    
    
    /// Calculate the equation of time for a given date
    ///
    /// The equation of time (EOT) is a formula used in the process of converting between solar time and clock time to compensate for the earth's elliptical orbit around the sun and its axial tilt.
    /// Essentially, the earth does not move perfectly smoothly in a perfectly circular orbit, so the EOT adjusts for that.
    /// - Parameter date: A date as a Date type
    /// - Returns: Equation of time in minutes as a Double
    static func equationOfTime(for date: Date) -> Double {
        
        let vary, ecc, part1, part2, part3, part4, part5: Double
        
        let t              = julianCenturySinceJan2000(date: date)
        let meanGInRadians = geometricMeanLongitudeOfSunAtCurrentTime(t: t) * Double(Globals.degreesToRadians)
        let meanAInRadians = meanAnomaly(t: t) * Double(Globals.degreesToRadians)
        vary               = 0.0430264916545165
        ecc                = orbitEccentricityOfEarth(t: t)
        
        part1              = vary * sin(2 * meanGInRadians)
        part2              = 2 * ecc * sin(meanAInRadians)
        part3              = 4 * ecc * vary * sin(meanAInRadians) * cos(2 * meanGInRadians)
        part4              = 0.5 * vary * vary * sin(4 * meanGInRadians)
        part5              = 1.25 * ecc * ecc * sin(2 * meanAInRadians)
        let eOT            = 4 * (part1 - part2 + part3 - part4 - part5) * Double(Globals.radiansToDegrees)
        
        return eOT
        
    }
    
    
    /// Calculate the Sun equation of Center
    ///
    /// The orbits of the planets are not perfect circles but rather ellipses, so the speed of the planet in its orbit varies, and therefore the apparent speed of the Sun along the ecliptic also varies throughout the planet's year.
    /// The true anomaly is the angular distance of the planet from the perihelion of the planet, as seen from the Sun. For a circular orbit, the mean anomaly and the true anomaly are the same.
    /// The difference between the true anomaly and the mean anomaly is called the Equation of Center.
    /// - Parameter t: Julian century
    /// - Returns: The Sun equation of Center in radians as a Double
    static func sunEquationOfCenter(t: Double) -> Double {
        
        let m = meanAnomaly(t: t)
        let sEOC = sin(m * Double(Globals.degreesToRadians)) * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin(2 * m * Double(Globals.degreesToRadians)) * (0.019993 - 0.000101 * t) + sin(3 * m * Double(Globals.degreesToRadians)) * 0.000289
        
        return sEOC
        
    }
    
    
    /// Calculate the geometric mean longitude of the Sun
    ///
    /// The mean longitude of the Sun, corrected for the aberration of light. Mean longitude is the ecliptic longitude at which an orbiting body could be found if its orbit were circular and free of perturbations.
    /// While nominally a simple longitude, in practice the mean longitude does not correspond to any one physical angle.
    /// - Parameter t: Julian century as a Double
    /// - Returns: The geometric mean longitude in degrees as a Double
    static func geometricMeanLongitudeOfSunAtCurrentTime(t: Double) -> Double {
        
        let sunGeometricMeanLongitude = (280.46646 + t * 36000.76983 + t * t * 0.0003032).truncatingRemainder(dividingBy: Double(Globals.threeSixtyDegrees))
        
        return sunGeometricMeanLongitude
        
    }
    
    
    /// Calculate the exact current latitude of the Sun for a given date
    ///
    /// Uses the geometric mean longitude of the Sun and equation of center.
    /// - Parameter date: A date as a Date type
    /// - Returns: Latitude in degrees as a Double
    static func latitudeOfSun(for date: Date) -> Double {
        
        let jC                       = julianCenturySinceJan2000(date: date)
        
        let geomMeanLongitude        = geometricMeanLongitudeOfSunAtCurrentTime(t: jC)
        let sunTrueLongitude         = geomMeanLongitude + sunEquationOfCenter(t: jC)
        let latitudeOfSun            = asin(sin(sunTrueLongitude * Double(Globals.degreesToRadians)) * sin(Globals.earthTiltInRadians))
        let sunTrueLatitudeInDegrees = latitudeOfSun * Double(Globals.radiansToDegrees)
        
        return sunTrueLatitudeInDegrees
        
    }
    
    
    /// Calculate the exact current longitude of the Sun for a given date
    ///
    /// This is an original algorithm that I based on a given date and the equation of time. This is partially empirical and uses the difference between local and GMT time to determine roughly where noon is.
    /// The algorithm then corrects this based on the equation of time and whether the Sun is east or west of the International Date Line.
    /// - Parameter date: A date as a Date type
    /// - Returns: The subsolar longitude as a Double
    static func subSolarLongitudeOfSunAtCurrentTime(for date: Date) -> Double {
        
        var timeCorrection, dayCorrection, lonCorrection: Double
        
        // Time calculations for the current time
        let eOT            = Double(equationOfTime(for: date))
        let localMins      = Double(Calendar.current.component(.minute, from: date))
        let localHour      = Double(Calendar.current.component(.hour, from: date)) + localMins / Globals.numberOfMinutesInAnHour   // The current time as a decimal value
        let secondsFromGMT = Double(TimeZone.current.secondsFromGMT())
        
        // Correct for time and day relative to GMT and the International Date Line
        if secondsFromGMT <= 0 {
            timeCorrection = 1
            dayCorrection  = 0
        } else {
            timeCorrection = -1
            dayCorrection  = -Globals.numberOfHoursInADay
        }
        
        // Calculate current GMT
        let GMT = (localHour - secondsFromGMT / Globals.numberOfSecondsInAnHour - timeCorrection * Globals.numberOfHoursInADay.truncatingRemainder(dividingBy: Globals.numberOfHoursInADay)).truncatingRemainder(dividingBy: Globals.numberOfHoursInADay)
        
        // Now, calculate the difference between current GMT and noontime in hours
        let noonHourDelta = min(Globals.noonTime - GMT - eOT / Globals.numberOfMinutesInAnHour + dayCorrection, 12.0).truncatingRemainder(dividingBy: Globals.numberOfHoursInADay)  // Force to <= 12
        
        // The subsolar longitude is the difference in hours times the number of degrees per hour (360/24 = 15 deg/hr)
        let subSolarLon = noonHourDelta * Globals.degreesLongitudePerHour
        
        // Now, determine if we've crossed the international date line. If so, we need to add 180 degrees.
        if subSolarLon < -Globals.oneEightyDegrees && GMT <= Globals.noonTime {
            lonCorrection = Globals.oneEightyDegrees
        } else if subSolarLon < -Globals.oneEightyDegrees && GMT >= Globals.noonTime {
            lonCorrection = localHour >= GMT ? 0 : Globals.oneEightyDegrees
        } else if GMT >= Globals.numberOfHoursInADay {
            lonCorrection = Globals.oneEightyDegrees
        } else {
            lonCorrection = 0
        }

        let subSolarLongitudeActual = subSolarLon + lonCorrection
        
        return subSolarLongitudeActual
        
    }
    
    
    /// Get the subsolar coordinates at the current date and time
    /// 
    /// The subsolar point is the position on Earth where the Sun is at the zenith.
    /// - Returns: The subsolar coordinates (latitude and longitude) as a tuple of Floats
    static func getSubSolarCoordinates() -> (latitude: Float, longitude: Float) {
        
        let now = Date()
        let lat = Float(latitudeOfSun(for: now))
        let lon = Float(subSolarLongitudeOfSunAtCurrentTime(for: now))
        
        return (lat, lon)
        
    }
    
}
