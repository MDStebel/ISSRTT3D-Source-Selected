//
//  Globals.swift
//  ISS Tracker
//
//  Created by Michael Stebel on 6/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

/// Static struct used as a namespace to hold global variables and constants
struct Globals {
    
    static var thisDevice                                   = ""
    static var isIPad                                       = false {
        didSet {
            if isIPad {
                navigationBarTitleFontSize = navigationBarTitleFontSizeForIPad
            } else {
                navigationBarTitleFontSize = navigationBarTitleFontSizeForIPhone
            }
        }
    }
    
    static var copyrightString                              = ""
    static var versionNumber                                = ""
    static var buildNumber                                  = ""
    static var mapTypeSelection                             = 2
    static var numberOfZoomFactors                          = 4
    static var zoomRangeFactorSelection                     = 2
    static var numberOfDaysOfPassesDefaultSelectionSegment  = 2
    static var numberOfDaysOfPassesSelectedSegment          = 0
    static var markerType                                   = 0
    static var orbitGroundTrackLineEnabled                  = true
    static var showCoordinatesIsOn                          = true
    static var blackScreenInHDEVExplanationPopsUp           = true
    static var displayZoomFactorBelowMarkerIsOn             = true
    static var zoomFactorWasResetInSettings                 = false
    static var lastDateAndTimeSettingsWereSaved             = ""
    static var showWhatsNewUponNextStartup                  = false
    static var mapScrollingAndZoomIsEnabled                 = false
    static var lastBackgroundColorWas: UIColor              = .white
    static var navigationBarTitleFontSize: CGFloat          = 0
    static var whatsNewTitleFontSize: CGFloat               = 36
    static var themeFont                                    = "nasalization"

    static let numberOfSecondsInADay                        = 3600.0 * 24.0
    static let coordinatesStringFormat                      = "%3d°%02d'%02d\" %@  %3d°%02d'%02d\" %@"
    static let outputDateFormatString                       = "MMM-dd-YYYY 'at' hh:mma"
    static let floatingPointWithThreePlusOneDecimalPlace    = "%3.1f"
    static let floatingPointWithTwoPlusOneDecimalPlace      = "%2.1f"
    static let azimuthFormat                                = "%3.0f"
    static let elevationFormat                              = "%2.1f"
    static let outputDateOnlyFormatString                   = "MMM-dd-YYY"
    static let outputTimeOnlyFormatString                   = "hh:mma"
    static let outputDateFormatStringShortForm              = "MMM-dd-yyyy"
    static let dateFormatStringEuropeanForm                 = "yyyy-MM-dd"
    static let spacer                                       = "  "
    static let navigationBarTitleFontSizeForIPad: CGFloat   = 24
    static let navigationBarTitleFontSizeForIPhone: CGFloat = 20
    static let appFont                                      = "Avenir Book"
    static let appFontBold                                  = "Avenir Next Medium"
    static let cellBackgroundColorAlpha: CGFloat            = 0.15
    static let issrttWebsite                                = "https://www.issrtt.com"
    
    static let numberOfDaysDictionary = [
        0 : "2",
        1 : "5",
        2 : "10",
        3 : "15",
        4 : "20",
        5 : "30"
    ]
    
}
