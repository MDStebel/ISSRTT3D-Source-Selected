//
//  Globals.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 6/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Static struct used as a namespace to hold global variables and constants
struct Globals {
    
    static var isIPad                                       = false {
        didSet {
            if isIPad {
                Theme.navigationBarTitleFontSize = Theme.navigationBarTitleFontSizeForIPad
            } else {
                Theme.navigationBarTitleFontSize = Theme.navigationBarTitleFontSizeForIPhone
            }
        }
    }
    
    static var autoRotateGlobeEnabled                       = true
    static var blackScreenInHDEVExplanationPopsUp           = true
    static var buildNumber                                  = ""
    static var copyrightString                              = ""
    static var displayGlobe                                 = true
    static var displayZoomFactorBelowMarkerIsOn             = true
    static var lastDateAndTimeSettingsWereSaved             = ""
    static var mapScrollingAndZoomIsEnabled                 = false
    static var mapTypeSelection                             = 2
    static var markerType                                   = 0
    static var numberOfDaysOfPassesDefaultSelectionSegment  = 2
    static var numberOfDaysOfPassesSelectedSegment          = 0
    static var numberOfZoomFactors                          = 4
    static var orbitGroundTrackLineEnabled                  = true
    static var showCoordinatesIsOn                          = true
    static var showWhatsNewUponNextStartup                  = false
    static var thisDevice                                   = ""
    static var versionNumber                                = ""
    static var zoomFactorWasResetInSettings                 = false
    static var zoomRangeFactorSelection                     = 2

    static let ISSAltitudeFactor                            = Float(globeRadiusFactor * 1.17)
    static let ISSOrbitAltitudeInScene                      = orbitalAltitudeFactor
    static let ISSOrbitInclinationInDegrees: Float          = 51.64
    static let ISSOrbitInclinationInRadians: Float          = ISSOrbitInclinationInDegrees * degreesToRadians
    static let azimuthFormat                                = "%3.0f"
    static let coordinatesStringFormat                      = "%3d°%02d'%02d\" %@  %3d°%02d'%02d\" %@"
    static let dateFormatStringEuropeanForm                 = "yyyy-MM-dd"
    static let degreesLongitudePerHour: Float               = 360 / 24
    static let degreesToRadians: Float                      = .pi / 180
    static let earthTiltInDegrees: Float                    = 23.447
    static let earthTiltInRadians: Float                    = earthTiltInDegrees * degreesToRadians
    static let elevationFormat                              = "%2.1f"
    static let floatingPointWithThreePlusOneDecimalPlace    = "%3.1f"
    static let floatingPointWithTwoPlusOneDecimalPlace      = "%2.1f"
    static let globeRadiusFactor: Float                     = 0.5
    static let issrttWebsite                                = "https://www.issrtt.com"
    static let numberOfDaysInAYear                          = 365.0
    static let numberOfDaysInCentury                        = 36525
    static let numberOfSecondsInADay                        = 3600.0 * 24.0
    static let orbitalAltitudeFactor                        = Float(globeRadiusFactor * 1.15)
    static let outputDateFormatString                       = "MMM-dd-YYYY 'at' hh:mma"
    static let outputDateFormatStringShortForm              = "MMM-dd-yyyy"
    static let outputDateOnlyFormatString                   = "MMM-dd-YYY"
    static let outputTimeOnlyFormatString                   = "hh:mma"
    static let radiansToDegrees: Float                      = 1 / degreesToRadians
    static let spacer                                       = "  "
    
}
