//
//  AstroCalculations.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 02/26/2022.
//  Copyright © 2020-2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// A set of functions that provide solar position calculations
public struct AstroCalculations {
    
    /// Convert a given Gregorian date to a Julian date
    /// - Parameter date: Gregorian date to convert as a Date
    /// - Returns: Julian date as a Double
    static func jDFromDate(date: Date) -> Double {
        return Globals.julianDateForJan011970At0000GMT + date.timeIntervalSince1970 / Globals.numberOfSecondsInADay
    }

    /// Convert a given Julian date to a Gregorian date
    /// - Parameter jd: Julian date as a Double
    /// - Returns: Standard date as a NSDate
    static func dateFromJd(jd : Double) -> NSDate {
        return NSDate(timeIntervalSince1970: (jd - Globals.julianDateForJan011970At0000GMT) * Globals.numberOfSecondsInADay)
    }
    
    /// Calculate the Julian century since Jan-1-2000
    /// - Parameter date: Gregorian date as a Date
    /// - Returns: Julian century as a Double
    static func julianCenturySinceJan2000(date: Date) -> Double {
       return (jDFromDate(date: date) - 2451545) / Globals.numberOfDaysInACentury
    }
    
    /// Calculate the Orbital Eccentricity of the Earth
    ///
    /// The orbital eccentricity of an astronomical object is a dimensionless parameter that determines the amount by which its orbit around another body deviates from a perfect circle.
    /// - Parameter t: Julian century as a Double
    /// - Returns: Eccentricity as a Double
    static func orbitEccentricityOfEarth(t: Double) -> Double {
        return 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
    }
    
    /// Calculate the Mean Anomaly of the Sun for a given date
    ///
    /// The mean anomaly is the angle between lines drawn from the Sun to the perihelion and to a point moving in the orbit at a uniform rate corresponding to the period of revolution of the planet.
    /// If the orbit of the planet were a perfect circle, then the planet as seen from the Sun would move along its orbit at a fixed speed.
    /// Then it would be simple to calculate its position (and also the position of the Sun as seen from the planet).
    /// The position that the planet would have relative to its perihelion if the orbit of the planet were a circle is called the mean anomaly.
    /// - Parameter t: Julian century as a Double
    /// - Returns: The mean anomaly as a Double
    static func meanAnomaly(t: Double) -> Double {
       return 357.52911 + t * 35999.05029 - t * 0.0001537
    }
    
    /// Calculate the Equation of Time for a given date
    ///
    /// The Equation of Time (EOT) is a formula used to convert between solar time and clock time, accounting for the Earth’s elliptical orbit around the Sun and its axial tilt.
    /// Essentially, the Earth does not move perfectly smoothly in a perfectly circular orbit, so the EOT adjusts for that.
    /// - Parameter date: A date as a Date type
    /// - Returns: Equation of time in minutes as a Double
    static func equationOfTime(for date: Date) -> Double {
        let t = julianCenturySinceJan2000(date: date)
        let meanLongitudeSunRadians = geometricMeanLongitudeOfSunAtCurrentTime(t: t) * Globals.degreesToRadians
        let meanAnomalySunRadians = meanAnomaly(t: t) * Globals.degreesToRadians
        let eccentricity = orbitEccentricityOfEarth(t: t)
        let obliquity = 0.0430264916545165 
        
        let term1 = obliquity * sin(2 * meanLongitudeSunRadians)
        let term2 = 2 * eccentricity * sin(meanAnomalySunRadians)
        let term3 = 4 * eccentricity * obliquity * sin(meanAnomalySunRadians) * cos(2 * meanLongitudeSunRadians)
        let term4 = 0.5 * obliquity * obliquity * sin(4 * meanLongitudeSunRadians)
        let term5 = 1.25 * eccentricity * eccentricity * sin(2 * meanAnomalySunRadians)
        
        let equationOfTime = 4 * (term1 - term2 + term3 - term4 - term5) * Globals.radiansToDegrees
        
        return equationOfTime
    }
    
    /// Calculate the Sun Equation of Center
    ///
    /// The orbits of the planets are not perfect circles, but rather ellipses, so the speed of the planet in its orbit varies, and therefore the apparent speed of the Sun along the ecliptic also varies throughout the planet's year.
    /// The true anomaly is the angular distance of the planet from the perihelion of the planet, as seen from the Sun. For a circular orbit, the mean anomaly and the true anomaly are the same.
    /// The difference between the true anomaly and the mean anomaly is called the Equation of Center.
    /// - Parameter t: Julian century
    /// - Returns: The Sun equation of Center in radians as a Double
    static func sunEquationOfCenter(t: Double) -> Double {
        let m = meanAnomaly(t: t)
       
        return sin(m * Double(Globals.degreesToRadians)) * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin(2 * m * Double(Globals.degreesToRadians)) * (0.019993 - 0.000101 * t) + sin(3 * m * Double(Globals.degreesToRadians)) * 0.000289
    }
    
    /// Calculate the Geometric Mean Longitude of the Sun
    ///
    /// The mean longitude of the Sun, corrected for the aberration of light. Mean longitude is the ecliptic longitude at which an orbiting body could be found if its orbit were circular and free of perturbations.
    /// While nominally a simple longitude, in practice the mean longitude does not correspond to any one physical angle.
    /// - Parameter t: Julian century as a Double
    /// - Returns: The geometric mean longitude in degrees as a Double
    static func geometricMeanLongitudeOfSunAtCurrentTime(t: Double) -> Double {
        return (280.46646 + t * 36000.76983 + t * t * 0.0003032).truncatingRemainder(dividingBy: Double(Globals.threeSixtyDegrees))
    }
    
    /// Calculate the exact current latitude of the Sun for a given date
    ///
    /// Uses the geometric mean longitude of the Sun and equation of center.
    /// - Parameter date: A date as a Date type
    /// - Returns: Latitude in degrees as a Double
    static func latitudeOfSunAtCurrentTime(for date: Date) -> Double {
        
        let jC                       = julianCenturySinceJan2000(date: date)
        
        let geomMeanLongitude        = geometricMeanLongitudeOfSunAtCurrentTime(t: jC)
        let sunTrueLongitude         = geomMeanLongitude + sunEquationOfCenter(t: jC)
        let latitudeOfSun            = asin(sin(sunTrueLongitude * Double(Globals.degreesToRadians)) * sin(Globals.earthTiltInRadians))
        
        return latitudeOfSun * Double(Globals.radiansToDegrees)
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
        let eOT            = equationOfTime(for: date)
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
        if subSolarLon < -Globals.oneEightyDegrees && GMT < Globals.noonTime {
            lonCorrection = Globals.oneEightyDegrees
        } else if subSolarLon < -Globals.oneEightyDegrees && GMT >= Globals.noonTime {
            lonCorrection = 0               //localHour >= GMT ? 0 : Globals.oneEightyDegrees
        } else if GMT >= Globals.numberOfHoursInADay {
            lonCorrection = Globals.oneEightyDegrees
        } else {
            lonCorrection = 0
        }

        return subSolarLon + lonCorrection
    }
    
    /// Get the subsolar coordinates at the current date and time
    /// 
    /// The subsolar point is the position on Earth where the Sun is at the zenith.
    /// - Returns: The subsolar coordinates (latitude and longitude) as a tuple of Floats
    static func getSubSolarCoordinates() -> (latitude: Float, longitude: Float) {
        
        let now = Date()
        let lat = Float(latitudeOfSunAtCurrentTime(for: now))
        let lon = Float(subSolarLongitudeOfSunAtCurrentTime(for: now))
        
        return (lat, lon)
    }
}
