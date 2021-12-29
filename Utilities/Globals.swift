//
//  Globals.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/26/2022.
//  Copyright © 2016-2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

/// Struct used as a namespace to hold global variables and constants
struct Globals {
    
    // MARK: - Global Variables
    
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
    static var blackScreenInHDEVExplanationPopsUp            = true
    static var buildNumber                                   = ""
    static var cameraAltitude: Float                         = 1.85
    static var copyrightString                               = ""
    static var displayGlobe                                  = true
    static var displayZoomFactorBelowMarkerIsOn              = true
    static var footprintDiameter                             = ISSMarkerWidth * 2.25 
    static var globeBackgroundImageDefaultSelectionSegment   = 0
    static var globeBackgroundImageSelection                 = 0
    static var globeBackgroundWasChanged                     = true
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
    static var pulseSatelliteMarkerForGlobe                  = true
    static var showCoordinatesIsOn                           = true
    static var showWhatsNewUponNextStartup                   = false
    static var thisDevice                                    = ""
    static var versionNumber                                 = ""
    static var zoomFactorDefaultValue: Float                 = 0
    static var zoomFactorLastValue: Float                    = 0
    static var zoomFactorWasResetInSettings                  = false
    static var zoomRangeFactorSelection                      = 2
    
    
    // MARK: - Global Constants
    
#if os(watchOS) // watchOS-specific settings
    
    static let ambientLightIntensity: CGFloat                = 200
    static let defaultCameraFov: CGFloat                     = 40
    static let coordinatesStringFormat                       = "%3d°%02d'%02d\"%@"
    static let globeRadiusMultiplierToPlaceOnSurface: Float  = 0.962
    static let globeSegments                                 = 128
    static let ISSMarkerWidth: CGFloat                       = 0.15
    static let pipeSegments                                  = 64
    static let ringSegments                                  = 128
    static let sunlightIntensity: CGFloat                    = 3600
    
#else           // iOS and iPadOS-specific settings
    
    static let ambientLightIntensity: CGFloat                = 100
    static let coordinatesStringFormat                       = "%3d°%02d'%02d\"%@, %3d°%02d'%02d\"%@"
    static let defaultCameraFov: CGFloat                     = 30
    static let globeRadiusMultiplierToPlaceOnSurface: Float  = 0.949
    static let globeSegments                                 = 1000
    static let ISSMarkerWidth: CGFloat                       = 0.16
    static let pipeSegments                                  = 128
    static let ringSegments                                  = 256
    static let sunlightIntensity: CGFloat                    = 3200
    
#endif
    
    static let ISSAltitudeFactor: Float                      = ISSOrbitalAltitudeFactor * 1.015
    static let ISSAvgAltitudeInKM: Float                     = 428
    static let ISSIconFor3DGlobeView                         = "ISS-mds-1350px"
    static let ISSIconForMapView                             = "ISS-mds-75px-Template-Image"
    static let ISSOrbitAltitudeInScene                       = ISSOrbitalAltitudeFactor
    static let ISSOrbitInclinationInDegrees: Float           = 51.6
    static let ISSOrbitInclinationInRadians: Float           = ISSOrbitInclinationInDegrees * Float(degreesToRadians)
    static let ISSOrbitalAltitudeFactor                      = globeRadiusFactor * (1 + ISSAvgAltitudeInKM / earthRadiusInKM) * 1.02
    static let ISSRTT3DWebsite                               = "https://www.issrtt.com"
    static let ISSViewingCircleGraphic                       = "iss_4_visibility_circle"
    static let TSSAltitudeFactor: Float                      = TSSOrbitalAltitudeFactor * 1.015
    static let TSSIconFor3DGlobeView                         = "Tiangong-mds-1200px"
    static let TSSMarkerWidth: CGFloat                       = 0.07
    static let TSSMinAltitudeInKM: Float                     = 370
    static let TSSOrbitAltitudeInScene                       = TSSOrbitalAltitudeFactor
    static let TSSOrbitInclinationInDegrees: Float           = 41.5
    static let TSSOrbitInclinationInRadians: Float           = TSSOrbitInclinationInDegrees * Float(degreesToRadians)
    static let TSSOrbitalAltitudeFactor                      = globeRadiusFactor * (1 + TSSMinAltitudeInKM / earthRadiusInKM) * 1.01
    static let TSSViewingCircleGraphic                       = "TSS-Visibility-Circle"
    static let azimuthFormat                                 = "%3.0f"
    static let blackBackgroundImage                          = "blackBackgroundImage"
    static let coordinatesStringFormatShortForm              = "%3d° %02d' %@  %3d° %02d' %@"
    static let dateFormatStringEuropeanForm                  = "yyyy-MM-dd"
    static let degreesLongitudePerHour: Double               = 15
    static let degreesToRadians: Double                      = .pi / 180
    static let e                                             = M_E
    static let earthRadiusInKM: Float                        = 6378
    static let earthTiltInDegrees: Double                    = 23.43715
    static let earthTiltInRadians: Double                    = earthTiltInDegrees * degreesToRadians
    static let eclipticTiltFromGalacticPlaneInDegrees: Float = 60.5
    static let eclipticTiltFromGalacticPlaneInRadians: Float = eclipticTiltFromGalacticPlaneInDegrees * Float(degreesToRadians)
    static let elevationFormat                               = "%2.1f"
    static let floatingPointWithThreePlusOneDecimalPlace     = "%3.1f"
    static let floatingPointWithTwoPlusOneDecimalPlace       = "%2.1f"
    static let globeRadiusFactor: Float                      = 0.555
    static let helpChar                                      = "?"
    static let hubbleAltitudeFactor: Float                   = hubbleOrbitalAltitudeFactor * 1.015
    static let hubbleDeepField                               = "Hubble Legacy Field Crop 2800px"
    static let hubbleIconFor3DGlobeView                      = "HST-Image"
    static let hubbleMarkerWidth: CGFloat                    = 0.06
    static let hubbleMaxAltitudeInKM: Float                  = 550
    static let hubbleOrbitAltitudeInScene                    = hubbleOrbitalAltitudeFactor
    static let hubbleOrbitInclinationInDegrees: Float        = 28.5
    static let hubbleOrbitInclinationInRadians: Float        = hubbleOrbitInclinationInDegrees * Float(degreesToRadians)
    static let hubbleOrbitalAltitudeFactor: Float            = globeRadiusFactor * (1 + hubbleMaxAltitudeInKM / earthRadiusInKM) * 1.05
    static let hubbleViewingCircleGraphic                    = "Hubble-Viewing-Circle-1"
    static let julianDateForJan011970At0000GMT               = 2440587.5
    static let kilometersToMiles                             = 0.621371192
    static let milkyWay                                      = "Milky Way Correct Rotation in the Sky Square"
    static let newLine                                       = "\n"
    static let ninetyDegrees: Float                          = 90
    static let noonTime: Double                              = 12
    static let numberOfDaysInACentury: Double                = 36525
    static let numberOfDaysInAYear: Double                   = 365
    static let numberOfHoursInADay: Double                   = 24
    static let numberOfMinutesInADay: Double                 = 1440
    static let numberOfMinutesInAYear: Double                = numberOfDaysInAYear * numberOfMinutesInADay
    static let numberOfMinutesInAnHour: Double               = 60
    static let numberOfSecondsInADay: Double                 = 86400
    static let numberOfSecondsInAMinute: Double              = 60
    static let numberOfSecondsInAYear: Double                = numberOfSecondsInADay * numberOfDaysInAYear
    static let numberOfSecondsInAnHour: Double               = 3600
    static let oneEightyDegrees: Double                      = 180
    static let orionNebula                                   = "Orion Nebula.png"
    static let outputDateFormatString                        = "MMM-dd-YYYY 'at' hh:mma"
    static let outputDateFormatStringShortForm               = "MMM-dd-yyyy"
    static let outputDateOnlyFormatString                    = "MMM-dd-YYY"
    static let outputTimeOnlyFormatString                    = "hh:mma"
    static let radiansToDegrees: Double                      = 1 / degreesToRadians
    static let settingsChar                                  = "⚙"
    static let spacer                                        = "  "
    static let tarantulaNebula                               = "Tarantula Nebula in the Large Magellanic Cloud"
    static let threeSixtyDegrees: Float                      = 360
    static let twoPi: Double                                 = .pi * 2
    static let zero: Float                                   = 0.0
    
}
