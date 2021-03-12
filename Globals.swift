//
//  Globals.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/26/2021.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Struct used as a namespace to hold global variables and constants
struct Globals {
    
    static var isIPad                                        = false {
        didSet {
            if isIPad {
                Theme.navigationBarTitleFontSize             = Theme.navigationBarTitleFontSizeForIPad
            } else {
                Theme.navigationBarTitleFontSize             = Theme.navigationBarTitleFontSizeForIPhone
            }
        }
    }
    
    static var autoRotateGlobeEnabled                        = true
    static var globeBackgroundWasChanged                     = true
    static var blackScreenInHDEVExplanationPopsUp            = true
    static var buildNumber                                   = ""
    static var cameraAltitude: Float                         = 1.85
    static var copyrightString                               = ""
    static var defaultCameraFov: CGFloat                     = 30
    static var displayGlobe                                  = true
    static var displayZoomFactorBelowMarkerIsOn              = true
    static var globeBackgroundImageSelection                 = 0
    static var globeBackgroundImageDefaultSelectionSegment   = 0
    static var globeRadiusFactor: Float                      = 0.555
    static var lastDateAndTimeSettingsWereSaved              = ""
    static var mapScrollingAndZoomIsEnabled                  = false
    static var mapTypeSelection                              = 2
    static var markerType                                    = 0
    static var maxFov: CGFloat                               = defaultCameraFov * 1.5
    static var minFov: CGFloat                               = defaultCameraFov * 0.5
    static var numberOfDaysOfPassesDefaultSelectionSegment   = 2
    static var numberOfDaysOfPassesSelectedSegment           = 0
    static var numberOfZoomFactors                           = 4
    static var orbitGroundTrackLineEnabled                   = true
    static var pulseISSMarkerForGlobe                        = true
    static var showCoordinatesIsOn                           = true
    static var showWhatsNewUponNextStartup                   = false
    static var thisDevice                                    = ""
    static var versionNumber                                 = ""
    static var zoomFactorDefaultValue: Float                 = 0
    static var zoomFactorLastValue: Float                    = 0
    static var zoomFactorWasResetInSettings                  = false
    static var zoomRangeFactorSelection                      = 2

    static let azimuthFormat                                 = "%3.0f"
    static let coordinatesStringFormat                       = "%3d°%02d'%02d\" %@  %3d°%02d'%02d\" %@"
    static let dateFormatStringEuropeanForm                  = "yyyy-MM-dd"
    static let degreesLongitudePerHour: Double               = 15
    static let degreesToRadians: Double                      = .pi / 180
    static let e                                             = M_E
    static let earthRadiusInKM: Float                        = 6378
    static let earthTiltInDegrees: Double                    = 23.43715
    static let earthTiltInRadians: Double                    = 0.40905543478
    static let eclipticTiltFromGalacticPlaneInDegrees: Float = 60.5
    static let eclipticTiltFromGalacticPlaneInRadians: Float = eclipticTiltFromGalacticPlaneInDegrees * Float(degreesToRadians)
    static let elevationFormat                               = "%2.1f"
    static let floatingPointWithThreePlusOneDecimalPlace     = "%3.1f"
    static let floatingPointWithTwoPlusOneDecimalPlace       = "%2.1f"
    static let helpChar                                      = "(?)"
    static let hubbleDeepField                               = "Hubble Legacy Field Crop 2800px.png"
    static let ISSAltitudeFactor: Float                      = orbitalAltitudeFactor * 1.015
    static let ISSAltitudeInKM: Float                        = 425
    static let ISSOrbitAltitudeInScene                       = orbitalAltitudeFactor
    static let ISSIcon                                       = "New-ISS-Marker-2400px-1"
    static let ISSOrbitInclinationInDegrees: Float           = 51.64
    static let ISSOrbitInclinationInRadians: Float           = ISSOrbitInclinationInDegrees * Float(degreesToRadians)
    static let issrttWebsite                                 = "https://www.issrtt.com"
    static let julianDateForJan011970At0000GMT               = 2440587.5
    static let milkyWay                                      = "Milky Way Correct Rotation in the Sky Square.png"
    static let ninetyDegrees: Float                          = 90
    static let noonTime: Double                              = 12
    static let numberOfDaysInACentury: Double                = 36525
    static let numberOfDaysInAYear: Double                   = 365
    static let numberOfHoursInADay: Double                   = 24
    static let numberOfMinutesInADay: Double                 = 1440
    static let numberOfMinutesInAnHour: Double               = 60
    static let numberOfMinutesInAYear: Double                = numberOfDaysInAYear * numberOfMinutesInADay
    static let numberOfSecondsInADay: Double                 = 86400
    static let numberOfSecondsInAnHour: Double               = 3600
    static let numberOfSecondsInAMinute: Double              = 60
    static let numberOfSecondsInAYear: Double                = numberOfSecondsInADay * numberOfDaysInAYear
    static let oneEightyDegrees: Double                      = 180
    static let orbitalAltitudeFactor                         = globeRadiusFactor * (1 + ISSAltitudeInKM / earthRadiusInKM) * 1.02
    static let orionNebula                                   = "Orion Nebula.png"
    static let outputDateFormatString                        = "MMM-dd-YYYY 'at' hh:mma"
    static let outputDateFormatStringShortForm               = "MMM-dd-yyyy"
    static let outputDateOnlyFormatString                    = "MMM-dd-YYY"
    static let outputTimeOnlyFormatString                    = "hh:mma"
    static let radiansToDegrees: Double                      = 1 / degreesToRadians
    static let settingsChar                                  = "⚙"
    static let spacer                                        = "  "
    static let tarantulaNebula                               = "Tarantula Nebula in the Large Magellanic Cloud.png"
    static let threeSixtyDegrees: Float                      = 360
    static let twoPi: Double                                 = .pi * 2
    static let viewingCircleGraphic                          = "iss_4_visibility_circle"
    
}
