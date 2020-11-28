//
//  Globals.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Struct used as a namespace to hold global variables and constants
struct Globals {
    
    static var isIPad                                           = false {
        didSet {
            if isIPad {
                Theme.navigationBarTitleFontSize = Theme.navigationBarTitleFontSizeForIPad
            } else {
                Theme.navigationBarTitleFontSize = Theme.navigationBarTitleFontSizeForIPhone
            }
        }
    }
    
    static var autoRotateGlobeEnabled                           = true
    static var globeBackgroundWasChanged                        = true
    static var blackScreenInHDEVExplanationPopsUp               = true
    static var buildNumber                                      = ""
    static var cameraAltitude: Float                            = 1.85
    static var copyrightString                                  = ""
    static var defaultCameraFov: CGFloat                        = 30
    static var displayGlobe                                     = true
    static var displayZoomFactorBelowMarkerIsOn                 = true
    static var globeBackgroundImageSelection                    = 0
    static var globeBackgroundImageDefaultSelectionSegment      = 0
    static var globeRadiusFactor: Float                         = 0.555
    static var lastDateAndTimeSettingsWereSaved                 = ""
    static var mapScrollingAndZoomIsEnabled                     = false
    static var mapTypeSelection                                 = 2
    static var markerType                                       = 0
    static var maxFov: CGFloat                                  = defaultCameraFov * 1.5
    static var minFov: CGFloat                                  = defaultCameraFov * 0.5
    static var numberOfDaysOfPassesDefaultSelectionSegment      = 2
    static var numberOfDaysOfPassesSelectedSegment              = 0
    static var numberOfZoomFactors                              = 4
    static var orbitGroundTrackLineEnabled                      = true
    static var pulseISSMarkerForGlobe                           = true
    static var showCoordinatesIsOn                              = true
    static var showWhatsNewUponNextStartup                      = false
    static var thisDevice                                       = ""
    static var versionNumber                                    = ""
    static var zoomFactorDefaultValue: Float                    = 0
    static var zoomFactorLastValue: Float                       = 0
    static var zoomFactorWasResetInSettings                     = false
    static var zoomRangeFactorSelection                         = 2

    static let ISSAltitudeFactor: Float                         = orbitalAltitudeFactor * 1.015
    static let ISSAltitudeInKM: Float                           = 425
    static let ISSOrbitAltitudeInScene                          = orbitalAltitudeFactor
    static let ISSOrbitInclinationInDegrees: Float              = 51.64
    static let ISSOrbitInclinationInRadians: Float              = ISSOrbitInclinationInDegrees * degreesToRadians
    static let azimuthFormat                                    = "%3.0f"
    static let coordinatesStringFormat                          = "%3d°%02d'%02d\" %@  %3d°%02d'%02d\" %@"
    static let dateFormatStringEuropeanForm                     = "yyyy-MM-dd"
    static let degreesLongitudePerHour: Float                   = 360.0 / 24.0
    static let degreesToRadians: Float                          = .pi / 180
    static let e                                                = M_E
    static let earthRadiusInKM: Float                           = 6371
    static let earthTiltInDegrees: Float                        = 23.447
    static let earthTiltInRadians: Float                        = earthTiltInDegrees * degreesToRadians
    static let eclipticTiltFromGalacticPlaneInDegrees: Float    = 60.5
    static let eclipticTiltFromGalacticPlaneInRadians: Float    = eclipticTiltFromGalacticPlaneInDegrees * degreesToRadians
    static let elevationFormat                                  = "%2.1f"
    static let floatingPointWithThreePlusOneDecimalPlace        = "%3.1f"
    static let floatingPointWithTwoPlusOneDecimalPlace          = "%2.1f"
    static let hubbleDeepField                                  = "Hubble Legacy Field Crop 2800px.png"
    static let issrttWebsite                                    = "https://www.issrtt.com"
    static let milkyWay                                         = "Milky Way Correct Rotation in the Sky Square.png"
    static let noonTime: Float                                  = 12.00
    static let numberOfDaysInAYear                              = 365.0
    static let numberOfDaysInCentury                            = 36525
    static let numberOfHoursInADay                              = 24.0
    static let numberOfMinutesInAnHour                          = 60.0
    static let numberOfSecondsInADay                            = numberOfSecondsInAnHour * numberOfHoursInADay
    static let numberOfSecondsInAnHour                          = 3600.0
    static let numberOfSecondsInAMinute                         = 60.0
    static let orbitalAltitudeFactor                            = globeRadiusFactor * (1 + ISSAltitudeInKM / earthRadiusInKM) * 1.02
    static let orionNebula                                      = "Orion Nebula.png"
    static let outputDateFormatString                           = "MMM-dd-YYYY 'at' hh:mma"
    static let outputDateFormatStringShortForm                  = "MMM-dd-yyyy"
    static let outputDateOnlyFormatString                       = "MMM-dd-YYY"
    static let outputTimeOnlyFormatString                       = "hh:mma"
    static let radiansToDegrees: Float                          = 1 / degreesToRadians
    static let spacer                                           = "  "
    static let tarantulaNebula                                  = "Tarantula Nebula in the Large Magellanic Cloud.png"
    
}
