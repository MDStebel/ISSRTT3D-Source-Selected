//
//  SettingsHandler.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 8/5/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation

// Extension to save and restore user settings
extension TrackingViewController {
    
    
    // MARK: - Types
    
    
    /// Constants for the user defaults keys
    private struct UserSettingsPropertyKeys {
        
        static let displayZoomFactorKey                             = "Display Zoom Factor"
        static let mapTypeKey                                       = "Map Type"
        static let groundTrackOverlayKey                            = "Ground Track Overlay"
        static let numberOfDaysOfPassesToReportKey                  = "Number of Days of Passes to Report"
        static let showCoordinatesKey                               = "Show Coordinates"
        static let markerTypePropertyKey                            = "Marker Type"
        static let zoomRangeFactorKey                               = "Zoom Range Factor"
        static let zoomValueKey                                     = "Zoom Value"
        static let lastSavedDateAndTimeKey                          = "Last Saved"
        static let showWhatsNewPopupKey                             = "Show Whats New"
        static let enableMapScrollingAndZoomKey                     = "Map Scrolling and Zoom"
        static let blackScreenInEHDCExplanationPopupWillAppearKey   = "Black Screen"
        
    }
    
    
    // MARK: - Methods
    
    
    /// This method is called by AppDelegate when app is about to resign and first saves all user settings on the device, which are restored upon reloading this view controller.
    func saveUserSettings() {
        
        /// An instance of NSUserDefaults to save user settings
        let defaults = UserDefaults.standard
        
        if Globals.showCoordinatesIsOn {
            
            defaults.set(true, forKey: UserSettingsPropertyKeys.showCoordinatesKey)
            
        } else {
            
            defaults.set(false, forKey: UserSettingsPropertyKeys.showCoordinatesKey)
            
        }
        
        if Globals.displayZoomFactorBelowMarkerIsOn {
            
            defaults.set(true, forKey: UserSettingsPropertyKeys.displayZoomFactorKey)
            
        } else {
            
            defaults.set(false, forKey: UserSettingsPropertyKeys.displayZoomFactorKey)
            
        }

        
        if Globals.showWhatsNewUponNextStartup {
            
            defaults.set(true, forKey: UserSettingsPropertyKeys.showWhatsNewPopupKey)
            
        } else {
            
            defaults.set(false, forKey: UserSettingsPropertyKeys.showWhatsNewPopupKey)
            
        }
        
        if Globals.mapScrollingAndZoomIsEnabled {
            
            defaults.set(true, forKey: UserSettingsPropertyKeys.enableMapScrollingAndZoomKey)
            
        } else {
            
            defaults.set(false, forKey: UserSettingsPropertyKeys.enableMapScrollingAndZoomKey)
            
        }
        
        if Globals.orbitGroundTrackLineEnabled {
            
            defaults.set(true, forKey: UserSettingsPropertyKeys.groundTrackOverlayKey)
            
        } else {
            
            defaults.set(false, forKey: UserSettingsPropertyKeys.groundTrackOverlayKey)
            
        }
        
        defaults.set(Globals.mapTypeSelection, forKey: UserSettingsPropertyKeys.mapTypeKey)
        
        defaults.set(Globals.zoomRangeFactorSelection, forKey: UserSettingsPropertyKeys.zoomRangeFactorKey)
        
        defaults.set(Globals.numberOfDaysOfPassesSelectedSegment, forKey: UserSettingsPropertyKeys.numberOfDaysOfPassesToReportKey)
        
        defaults.set(Globals.markerType, forKey: UserSettingsPropertyKeys.markerTypePropertyKey)
        
        defaults.set(zoomSlider?.value, forKey: UserSettingsPropertyKeys.zoomValueKey)
        
        defaults.setValue(dateFormatter?.getCurrentDateAndTimeInAString(forCurrent: Date(), withOutputFormat: Globals.outputDateFormatString), forKey: UserSettingsPropertyKeys.lastSavedDateAndTimeKey)
        
        defaults.setValue(Globals.blackScreenInHDEVExplanationPopsUp, forKey: UserSettingsPropertyKeys.blackScreenInEHDCExplanationPopupWillAppearKey)
        
    }
    
    
    /// Restore user settings to their saved values. Also called as a from AppDelegate when app returns to foreground
    func restoreUserSettings() {
        
        /// An instance of NSUserDefaults
        let defaults = UserDefaults.standard
        
        // If persistent data exists, then restore settings to last time app was used
        
        if defaults.object(forKey: UserSettingsPropertyKeys.showCoordinatesKey) != nil {
            
            Globals.showCoordinatesIsOn = defaults.bool(forKey: UserSettingsPropertyKeys.showCoordinatesKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.displayZoomFactorKey) != nil {
            
            Globals.displayZoomFactorBelowMarkerIsOn = defaults.bool(forKey: UserSettingsPropertyKeys.displayZoomFactorKey)
            
        }

        
        if defaults.object(forKey: UserSettingsPropertyKeys.enableMapScrollingAndZoomKey) != nil {
            
            Globals.mapScrollingAndZoomIsEnabled = defaults.bool(forKey: UserSettingsPropertyKeys.enableMapScrollingAndZoomKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.mapTypeKey) != nil {
            
            Globals.mapTypeSelection = defaults.integer(forKey: UserSettingsPropertyKeys.mapTypeKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.groundTrackOverlayKey) != nil {
            
            Globals.orbitGroundTrackLineEnabled = defaults.bool(forKey: UserSettingsPropertyKeys.groundTrackOverlayKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.zoomRangeFactorKey) != nil {
            
            Globals.zoomRangeFactorSelection = defaults.integer(forKey: UserSettingsPropertyKeys.zoomRangeFactorKey)
            
        }

        
        if defaults.object(forKey: UserSettingsPropertyKeys.numberOfDaysOfPassesToReportKey) != nil {
            
            Globals.numberOfDaysOfPassesSelectedSegment = defaults.integer(forKey: UserSettingsPropertyKeys.numberOfDaysOfPassesToReportKey)
            
        } else {
            
            Globals.numberOfDaysOfPassesSelectedSegment = Globals.numberOfDaysOfPassesDefaultSelectionSegment
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.markerTypePropertyKey) != nil {
            
            Globals.markerType = defaults.integer(forKey: UserSettingsPropertyKeys.markerTypePropertyKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.zoomValueKey) != nil {
            
            zoomSlider?.value = defaults.float(forKey: UserSettingsPropertyKeys.zoomValueKey)
            
        } else {
            
            zoomSlider?.value = Float(zoomFactorDefaultValue)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.lastSavedDateAndTimeKey) != nil {
            
            Globals.lastDateAndTimeSettingsWereSaved = defaults.object(forKey: UserSettingsPropertyKeys.lastSavedDateAndTimeKey) as! String
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.showWhatsNewPopupKey) != nil {
            
            Globals.showWhatsNewUponNextStartup = defaults.bool(forKey: UserSettingsPropertyKeys.showWhatsNewPopupKey)
            
        }
        
        if defaults.object(forKey: UserSettingsPropertyKeys.blackScreenInEHDCExplanationPopupWillAppearKey) != nil {
            
            Globals.blackScreenInHDEVExplanationPopsUp = defaults.bool(forKey: UserSettingsPropertyKeys.blackScreenInEHDCExplanationPopupWillAppearKey)
            
        }
        
    } 
    
}
